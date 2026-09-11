import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../calls/call_services.dart';
import '../../models/call_model.dart';

class WebRTCService {
  WebRTCService._();

  static final WebRTCService instance = WebRTCService._();

  final CallService _callService = CallService.instance;

  RTCPeerConnection? _peerConnection;

  MediaStream? _localStream;
  MediaStream? _remoteStream;

  void Function(MediaStream stream)? _remoteStreamHandler;
  void Function(RTCPeerConnectionState state)? _connectionStateHandler;
  StreamSubscription<CallModel?>? _callSubscription;
  StreamSubscription? _remoteCandidateSubscription;

  final List<RTCIceCandidate> _pendingRemoteCandidates = [];

  bool _remoteDescriptionSet = false;
  bool _disposed = false;
  bool _isSpeakerOn = true;

  RTCPeerConnection? get peerConnection => _peerConnection;

  MediaStream? get localStream => _localStream;

  MediaStream? get remoteStream => _remoteStream;

  // ============================================================
  // CALLER
  // ============================================================

  Future<void> startAsCaller({
    required String callId,
    required bool isVideo,
  }) async {
    debugPrint('📞 Starting as CALLER');
    debugPrint('📞 Call ID: $callId');
    debugPrint('📞 Video: $isVideo');

    await _createConnection(callId: callId, isVideo: isVideo, isCaller: true);

    if (_peerConnection == null) {
      throw Exception('Peer connection was not created');
    }

    // Start listeners BEFORE saving the offer.
    _listenForAnswer(callId);
    _listenForReceiverCandidates(callId);

    debugPrint('📡 Creating offer...');

    final offerConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': isVideo,
      },
      'optional': [],
    };

    final offer = await _peerConnection!.createOffer(offerConstraints);

    debugPrint('📤 OFFER HAS AUDIO: ${offer.sdp?.contains('m=audio')}');

    if (isVideo) {
      debugPrint('📤 OFFER HAS VIDEO: ${offer.sdp?.contains('m=video')}');
    }

    await _peerConnection!.setLocalDescription(offer);

    debugPrint('📡 Local description set');

    await _callService.saveOffer(callId, {
      'type': offer.type,
      'sdp': offer.sdp,
    });

    debugPrint('📤 OFFER SAVED TO FIRESTORE');
  }

  // ============================================================
  // RECEIVER
  // ============================================================

  Future<void> startAsReceiver({
    required String callId,
    required bool isVideo,
  }) async {
    debugPrint('📞 Starting as RECEIVER');
    debugPrint('📞 Call ID: $callId');
    debugPrint('📞 Video: $isVideo');

    await _createConnection(callId: callId, isVideo: isVideo, isCaller: false);

    if (_peerConnection == null) {
      throw Exception('Peer connection was not created');
    }

    // Start listening before processing the offer.
    _listenForCallerCandidates(callId);

    debugPrint('📡 Waiting for offer...');

    final call = await _waitForOffer(callId);

    if (call.offer == null) {
      throw Exception('Call offer not available');
    }

    final offer = call.offer!;

    debugPrint('📥 OFFER RECEIVED');

    final offerSdp = offer['sdp'] as String?;
    final offerType = offer['type'] as String?;

    if (offerSdp == null || offerType == null) {
      throw Exception('Invalid offer received');
    }

    debugPrint('📥 OFFER HAS AUDIO: ${offerSdp.contains('m=audio')}');

    if (isVideo) {
      debugPrint('📥 OFFER HAS VIDEO: ${offerSdp.contains('m=video')}');
    }

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offerSdp, offerType),
    );

    _remoteDescriptionSet = true;

    debugPrint('📡 Remote description set on Receiver');

    await _flushPendingRemoteCandidates();

    debugPrint('📡 Creating answer...');

    final answerConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': isVideo,
      },
      'optional': [],
    };

    final answer = await _peerConnection!.createAnswer(answerConstraints);

    debugPrint('📤 ANSWER HAS AUDIO: ${answer.sdp?.contains('m=audio')}');

    if (isVideo) {
      debugPrint('📤 ANSWER HAS VIDEO: ${answer.sdp?.contains('m=video')}');
    }

    await _peerConnection!.setLocalDescription(answer);

    debugPrint('📡 Local answer description set');

    await _callService.saveAnswer(callId, {
      'type': answer.type,
      'sdp': answer.sdp,
    });

    debugPrint('📤 ANSWER SAVED TO FIRESTORE');
  }

  // ============================================================
  // CREATE PEER CONNECTION
  // ============================================================

  Future<void> _createConnection({
    required String callId,
    required bool isVideo,
    required bool isCaller,
  }) async {
    await dispose();

    _disposed = false;
    _remoteDescriptionSet = false;
    _pendingRemoteCandidates.clear();

    debugPrint('🔧 Creating peer connection with STUN/TURN servers...');

    final Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
            'stun:stun3.l.google.com:19302',
            'stun:stun4.l.google.com:19302',
            'stun:stun.cloudflare.com:3478',
            'stun:stun.services.mozilla.com',
          ],
        },
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        {
          'urls': 'turn:openrelay.metered.ca:443',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        {
          'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
      ],
      'sdpSemantics': 'unified-plan',
    };

    _peerConnection = await createPeerConnection(configuration);

    if (_peerConnection == null) {
      throw Exception('Failed to create peer connection');
    }

    // ==========================================================
    // PEER CONNECTION STATE
    // ==========================================================

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('📞 PEER CONNECTION STATE: $state');
      _connectionStateHandler?.call(state);

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        enableSpeakerphone(_isSpeakerOn);
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('🧊 ICE CONNECTION STATE: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        enableSpeakerphone(_isSpeakerOn);
      }
    };

    _peerConnection!.onSignalingState = (RTCSignalingState state) {
      debugPrint('📡 SIGNALING STATE: $state');
    };

    // ==========================================================
    // ICE CANDIDATES
    // ==========================================================

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
      if (_disposed) return;

      if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
        return;
      }

      debugPrint('🧊 LOCAL ICE CANDIDATE GATHERED: ${candidate.candidate}');

      final data = {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      };

      try {
        if (isCaller) {
          await _callService.addCallerIceCandidate(callId, data);
          debugPrint('🧊 Caller ICE candidate saved to Firestore');
        } else {
          await _callService.addReceiverIceCandidate(callId, data);
          debugPrint('🧊 Receiver ICE candidate saved to Firestore');
        }
      } catch (error) {
        debugPrint('❌ Failed to save ICE candidate: $error');
      }
    };

    // ==========================================================
    // REMOTE TRACK
    // ==========================================================

    _peerConnection!.onTrack = (RTCTrackEvent event) async {
      if (_disposed) return;

      debugPrint(
        '📥 REMOTE TRACK RECEIVED: '
        'kind=${event.track.kind}, '
        'id=${event.track.id}, '
        'enabled=${event.track.enabled}',
      );

      // Force-enable the received track
      event.track.enabled = true;

      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      } else {
        _remoteStream ??= await createLocalMediaStream('remote_stream_track');
        _remoteStream!.addTrack(event.track);
      }

      final remoteAudioTracks = _remoteStream!.getAudioTracks();
      final remoteVideoTracks = _remoteStream!.getVideoTracks();

      debugPrint('🔊 REMOTE AUDIO TRACK COUNT: ${remoteAudioTracks.length}');
      debugPrint('🎥 REMOTE VIDEO TRACK COUNT: ${remoteVideoTracks.length}');

      for (final track in remoteAudioTracks) {
        track.enabled = true;
        try {
          track.enableSpeakerphone(_isSpeakerOn);
        } catch (_) {}
        debugPrint(
          '🔊 REMOTE AUDIO: '
          'id=${track.id}, '
          'enabled=${track.enabled}',
        );
      }

      _remoteStreamHandler?.call(_remoteStream!);
      await enableSpeakerphone(_isSpeakerOn);
    };

    // Legacy stream callback
    _peerConnection!.onAddStream = (MediaStream stream) async {
      if (_disposed) return;
      debugPrint('📥 REMOTE STREAM ADDED via onAddStream');
      _remoteStream = stream;
      for (final track in stream.getAudioTracks()) {
        track.enabled = true;
        try {
          track.enableSpeakerphone(_isSpeakerOn);
        } catch (_) {}
      }
      _remoteStreamHandler?.call(_remoteStream!);
      await enableSpeakerphone(_isSpeakerOn);
    };

    // ==========================================================
    // GET LOCAL MEDIA
    // ==========================================================

    debugPrint('🎤 Requesting local media stream (microphone/camera)...');

    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'highpassFilter': true,
      },
      'video': isVideo ? {'facingMode': 'user'} : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
    } catch (e) {
      debugPrint(
        '⚠️ getUserMedia with advanced constraints failed, trying basic: $e',
      );
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': isVideo ? {'facingMode': 'user'} : false,
      });
    }

    if (_localStream == null) {
      throw Exception('Could not create local media stream');
    }

    // ==========================================================
    // VERIFY & ENABLE AUDIO
    // ==========================================================

    final audioTracks = _localStream!.getAudioTracks();
    debugPrint('🎤 LOCAL AUDIO TRACK COUNT: ${audioTracks.length}');

    for (final track in audioTracks) {
      track.enabled = true;
      debugPrint(
        '🎤 LOCAL AUDIO: '
        'id=${track.id}, '
        'enabled=${track.enabled}',
      );
    }

    // ==========================================================
    // VERIFY & ENABLE VIDEO
    // ==========================================================

    final videoTracks = _localStream!.getVideoTracks();
    debugPrint('🎥 LOCAL VIDEO TRACK COUNT: ${videoTracks.length}');

    for (final track in videoTracks) {
      track.enabled = true;
      debugPrint(
        '🎥 LOCAL VIDEO: '
        'id=${track.id}, '
        'enabled=${track.enabled}',
      );
    }

    // ==========================================================
    // ADD TRACKS TO PEER CONNECTION
    // ==========================================================

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);

      if (track.kind == 'audio') {
        debugPrint('🎤 LOCAL AUDIO TRACK ADDED TO PEER CONNECTION');
      }

      if (track.kind == 'video') {
        debugPrint('🎥 LOCAL VIDEO TRACK ADDED TO PEER CONNECTION');
      }
    }

    debugPrint('✅ Local media setup complete');
  }

  // ============================================================
  // WAIT FOR OFFER
  // ============================================================

  Future<CallModel> _waitForOffer(String callId) async {
    final existingCall = await _callService.getCall(callId);

    if (existingCall != null && existingCall.offer != null) {
      return existingCall;
    }

    final completer = Completer<CallModel>();
    StreamSubscription<CallModel?>? subscription;

    subscription = _callService
        .listenToCall(callId)
        .listen(
          (call) {
            if (call == null) return;
            if (call.offer == null) return;

            if (!completer.isCompleted) {
              completer.complete(call);
            }

            subscription?.cancel();
          },
          onError: (error, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
            subscription?.cancel();
          },
        );

    try {
      return await completer.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          throw TimeoutException('Timed out waiting for call offer');
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  // ============================================================
  // CALLER → ANSWER
  // ============================================================

  void _listenForAnswer(String callId) {
    _callSubscription = _callService.listenToCall(callId).listen((call) async {
      if (_disposed) return;
      if (call == null) return;
      if (call.answer == null) return;
      if (_remoteDescriptionSet) return;

      try {
        final answer = call.answer!;
        final sdp = answer['sdp'] as String?;
        final type = answer['type'] as String?;

        if (sdp == null || type == null) {
          debugPrint('❌ Invalid answer received');
          return;
        }

        debugPrint('📥 ANSWER RECEIVED FROM RECEIVER');
        debugPrint('📥 ANSWER HAS AUDIO: ${sdp.contains('m=audio')}');

        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(sdp, type),
        );

        _remoteDescriptionSet = true;
        debugPrint('📡 Remote answer description set on Caller');

        await _flushPendingRemoteCandidates();
      } catch (error, stackTrace) {
        debugPrint('❌ Error processing answer: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  // ============================================================
  // CALLER LISTENS FOR RECEIVER ICE
  // ============================================================

  void _listenForReceiverCandidates(String callId) {
    _remoteCandidateSubscription = _callService
        .listenToReceiverCandidates(callId)
        .listen((snapshot) async {
          if (_disposed) return;

          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) {
              continue;
            }

            final data = change.doc.data();
            if (data == null || data['candidate'] == null) {
              continue;
            }

            final sdpMLineIndex = data['sdpMLineIndex'] is int
                ? data['sdpMLineIndex'] as int
                : (data['sdpMLineIndex'] as num?)?.toInt() ?? 0;

            final candidate = RTCIceCandidate(
              data['candidate']?.toString(),
              data['sdpMid']?.toString(),
              sdpMLineIndex,
            );

            debugPrint('🧊 REMOTE RECEIVER ICE RECEIVED');
            await _handleRemoteCandidate(candidate);
          }
        });
  }

  // ============================================================
  // RECEIVER LISTENS FOR CALLER ICE
  // ============================================================

  void _listenForCallerCandidates(String callId) {
    _remoteCandidateSubscription = _callService
        .listenToCallerCandidates(callId)
        .listen((snapshot) async {
          if (_disposed) return;

          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) {
              continue;
            }

            final data = change.doc.data();
            if (data == null || data['candidate'] == null) {
              continue;
            }

            final sdpMLineIndex = data['sdpMLineIndex'] is int
                ? data['sdpMLineIndex'] as int
                : (data['sdpMLineIndex'] as num?)?.toInt() ?? 0;

            final candidate = RTCIceCandidate(
              data['candidate']?.toString(),
              data['sdpMid']?.toString(),
              sdpMLineIndex,
            );

            debugPrint('🧊 REMOTE CALLER ICE RECEIVED');
            await _handleRemoteCandidate(candidate);
          }
        });
  }

  // ============================================================
  // HANDLE REMOTE ICE
  // ============================================================

  Future<void> _handleRemoteCandidate(RTCIceCandidate candidate) async {
    if (_disposed) return;

    if (!_remoteDescriptionSet) {
      debugPrint('⏳ Remote description not ready. Queueing ICE candidate.');
      _pendingRemoteCandidates.add(candidate);
      return;
    }

    try {
      await _peerConnection?.addCandidate(candidate);
      debugPrint('🧊 REMOTE ICE CANDIDATE ADDED TO PEER CONNECTION');
    } catch (error) {
      debugPrint('❌ Failed to add remote ICE: $error');
    }
  }

  // ============================================================
  // FLUSH QUEUED ICE
  // ============================================================

  Future<void> _flushPendingRemoteCandidates() async {
    if (_peerConnection == null || !_remoteDescriptionSet) {
      return;
    }

    if (_pendingRemoteCandidates.isEmpty) {
      return;
    }

    debugPrint(
      '🧊 Adding ${_pendingRemoteCandidates.length} queued ICE candidates...',
    );

    final candidates = List<RTCIceCandidate>.from(_pendingRemoteCandidates);
    _pendingRemoteCandidates.clear();

    for (final candidate in candidates) {
      try {
        await _peerConnection!.addCandidate(candidate);
        debugPrint('🧊 Queued ICE candidate added');
      } catch (error) {
        debugPrint('❌ Failed to add queued ICE: $error');
      }
    }
  }

  // ============================================================
  // REMOTE STREAM HANDLER
  // ============================================================

  void setRemoteStreamHandler(void Function(MediaStream stream) handler) {
    _remoteStreamHandler = handler;

    if (_remoteStream != null) {
      handler(_remoteStream!);
    }
  }

  void setConnectionStateHandler(
    void Function(RTCPeerConnectionState state) handler,
  ) {
    _connectionStateHandler = handler;
  }

  // ============================================================
  // MUTE / UNMUTE
  // ============================================================

  Future<void> setMuted(bool muted) async {
    final tracks = _localStream?.getAudioTracks() ?? [];

    for (final track in tracks) {
      track.enabled = !muted;
    }

    try {
      if (tracks.isNotEmpty) {
        Helper.setMicrophoneMute(muted, tracks.first);
      }
    } catch (_) {}

    debugPrint(muted ? '🔇 Microphone muted' : '🎤 Microphone unmuted');
  }

  // ============================================================
  // SPEAKERPHONE ROUTING
  // ============================================================

  Future<void> enableSpeakerphone(bool enable) async {
    _isSpeakerOn = enable;
    try {
      await Helper.setSpeakerphoneOn(enable);
      for (final track
          in _remoteStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
        try {
          track.enableSpeakerphone(enable);
        } catch (_) {}
      }
      for (final track
          in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
        try {
          track.enableSpeakerphone(enable);
        } catch (_) {}
      }
      debugPrint(enable ? '🔊 Speakerphone enabled' : '📱 Earpiece enabled');
    } catch (e) {
      debugPrint('⚠️ Error setting speakerphone: $e');
    }
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> setCameraEnabled(bool enabled) async {
    final tracks = _localStream?.getVideoTracks() ?? [];

    for (final track in tracks) {
      track.enabled = enabled;
    }

    debugPrint(enabled ? '📷 Camera enabled' : '📷 Camera disabled');
  }

  // ============================================================
  // SWITCH CAMERA
  // ============================================================

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? [];

    if (tracks.isEmpty) {
      debugPrint('⚠️ No video track available');
      return;
    }

    try {
      await Helper.switchCamera(tracks.first);
      debugPrint('🔄 Camera switched');
    } catch (error) {
      debugPrint('❌ Failed to switch camera: $error');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    _disposed = true;

    debugPrint('🧹 Disposing WebRTC...');

    try {
      await _callSubscription?.cancel();
    } catch (_) {}

    try {
      await _remoteCandidateSubscription?.cancel();
    } catch (_) {}

    _callSubscription = null;
    _remoteCandidateSubscription = null;
    _remoteDescriptionSet = false;
    _pendingRemoteCandidates.clear();

    // Stop local tracks.
    try {
      for (final track in _localStream?.getTracks() ?? []) {
        try {
          await track.stop();
        } catch (error) {
          debugPrint('⚠️ Error stopping track: $error');
        }
      }
    } catch (_) {}

    // Dispose local stream.
    try {
      await _localStream?.dispose();
    } catch (error) {
      debugPrint('⚠️ Local stream dispose error: $error');
    }

    // Dispose remote stream.
    try {
      await _remoteStream?.dispose();
    } catch (error) {
      debugPrint('⚠️ Remote stream dispose error: $error');
    }

    // Close peer connection.
    try {
      await _peerConnection?.close();
    } catch (error) {
      debugPrint('⚠️ Peer connection close error: $error');
    }

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _remoteStreamHandler = null;
    _connectionStateHandler = null;

    debugPrint('✅ WebRTC disposed');
  }
}
