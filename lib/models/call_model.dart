import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType {
  audio,
  video,
}

enum CallStatus {
  ringing,
  accepted,
  rejected,
  ended,
  missed,
}

class CallModel {
  final String callId;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;

  // WebRTC signaling data
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;

  const CallModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
    this.offer,
    this.answer,
  });

  factory CallModel.fromMap(
    String callId,
    Map<String, dynamic> map,
  ) {
    return CallModel(
      callId: callId,
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      type: map['type'] == 'video'
          ? CallType.video
          : CallType.audio,
      status: _statusFromString(
        map['status'] ?? 'ringing',
      ),
      createdAt: _dateFromTimestamp(
        map['createdAt'],
      ),
      answeredAt: _nullableDate(
        map['answeredAt'],
      ),
      endedAt: _nullableDate(
        map['endedAt'],
      ),

      // WebRTC offer
      offer: map['offer'] != null
          ? Map<String, dynamic>.from(
              map['offer'],
            )
          : null,

      // WebRTC answer
      answer: map['answer'] != null
          ? Map<String, dynamic>.from(
              map['answer'],
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type == CallType.video
          ? 'video'
          : 'audio',
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(
        createdAt,
      ),
      'answeredAt': answeredAt != null
          ? Timestamp.fromDate(
              answeredAt!,
            )
          : null,
      'endedAt': endedAt != null
          ? Timestamp.fromDate(
              endedAt!,
            )
          : null,

      // WebRTC signaling
      'offer': offer,
      'answer': answer,
    };
  }

  static CallStatus _statusFromString(
    String value,
  ) {
    switch (value) {
      case 'accepted':
        return CallStatus.accepted;

      case 'rejected':
        return CallStatus.rejected;

      case 'ended':
        return CallStatus.ended;

      case 'missed':
        return CallStatus.missed;

      default:
        return CallStatus.ringing;
    }
  }

  static String _statusToString(
    CallStatus status,
  ) {
    switch (status) {
      case CallStatus.ringing:
        return 'ringing';

      case CallStatus.accepted:
        return 'accepted';

      case CallStatus.rejected:
        return 'rejected';

      case CallStatus.ended:
        return 'ended';

      case CallStatus.missed:
        return 'missed';
    }
  }

  static DateTime _dateFromTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }

  static DateTime? _nullableDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}