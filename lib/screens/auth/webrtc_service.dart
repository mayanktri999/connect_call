import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/call_model.dart';
import '../calls/call_services.dart';

class WebRTCService {
  WebRTCService._();

  static final WebRTCService instance = WebRTCService._();

  final CallService _callService = CallService.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  StreamSubscription? _callSubscription;
  StreamSubscription? _remoteCandidateSubscription;

  RTCPeerConnection? get peerConnection => _peerConnection;

  MediaStream? get localStream => _localStream;

  // ============================================================
  // CALLER
  // ============================================================

  Future<void> startAsCaller({
    required String callId,
    required bool isVideo,
  }) async {
    await _createConnection(callId: callId, isVideo: isVideo, isCaller: true);

    final offer = await _peerConnection!.createOffer();

    await _peerConnection!.setLocalDescription(offer);

    await _callService.saveOffer(callId, {
      'type': offer.type,
      'sdp': offer.sdp,
    });

    _listenForAnswer(callId);

    _listenForReceiverCandidates(callId);
  }

  // ============================================================
  // RECEIVER
  // ============================================================

  Future<void> startAsReceiver({
    required String callId,
    required bool isVideo,
  }) async {
    await _createConnection(callId: callId, isVideo: isVideo, isCaller: false);

    final call = await _callService.getCall(callId);

    if (call == null) {
      throw Exception('Call not found');
    }

    if (call.offer == null) {
      throw Exception('Call offer not available');
    }

    final offer = call.offer!;

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    final answer = await _peerConnection!.createAnswer();

    await _peerConnection!.setLocalDescription(answer);

    await _callService.saveAnswer(callId, {
      'type': answer.type,
      'sdp': answer.sdp,
    });

    _listenForCallerCandidates(callId);
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

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ],
    });

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': isVideo,
    });

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onIceCandidate = (candidate) async {
      if (candidate.candidate == null) {
        return;
      }

      final data = {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      };

      if (isCaller) {
        await _callService.addCallerIceCandidate(callId, data);
      } else {
        await _callService.addReceiverIceCandidate(callId, data);
      }
    };
  }

  // ============================================================
  // CALLER → ANSWER
  // ============================================================

  void _listenForAnswer(String callId) {
    _callSubscription = _callService.listenToCall(callId).listen((call) async {
      if (call == null) return;

      if (call.answer == null) return;

      final currentDescription = await _peerConnection?.getRemoteDescription();

      if (currentDescription != null) {
        return;
      }

      final answer = call.answer!;

      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
    });
  }

  // ============================================================
  // CALLER LISTENS FOR RECEIVER ICE
  // ============================================================

  void _listenForReceiverCandidates(String callId) {
    _remoteCandidateSubscription = _callService
        .listenToReceiverCandidates(callId)
        .listen((snapshot) async {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) {
              continue;
            }

            final data = change.doc.data();

            if (data == null) continue;

            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );

            await _peerConnection?.addCandidate(candidate);
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
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) {
              continue;
            }

            final data = change.doc.data();

            if (data == null) continue;

            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );

            await _peerConnection?.addCandidate(candidate);
          }
        });
  }

  // ============================================================
  // REMOTE VIDEO
  // ============================================================

  void setRemoteStreamHandler(void Function(MediaStream stream) handler) {
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        handler(event.streams.first);
      }
    };
  }

  // ============================================================
  // MUTE
  // ============================================================

  Future<void> setMuted(bool muted) async {
    final tracks = _localStream?.getAudioTracks() ?? [];

    for (final track in tracks) {
      track.enabled = !muted;
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
  }

  // ============================================================
  // SWITCH CAMERA
  // ============================================================

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? [];

    if (tracks.isEmpty) {
      return;
    }

    await Helper.switchCamera(tracks.first);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _callSubscription?.cancel();
    await _remoteCandidateSubscription?.cancel();

    _callSubscription = null;
    _remoteCandidateSubscription = null;

    for (final track in _localStream?.getTracks() ?? []) {
      await track.stop();
    }

    await _localStream?.dispose();

    await _peerConnection?.close();

    _localStream = null;
    _peerConnection = null;
  }
}
