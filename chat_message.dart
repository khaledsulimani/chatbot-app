import 'package:flutter/foundation.dart';

enum MessageType { user, assistant, system }

enum MessageStatus { sending, sent, error }

@immutable
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isAudio;
  final String? audioPath;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.isAudio = false,
    this.audioPath,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isAudio,
    String? audioPath,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isAudio: isAudio ?? this.isAudio,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString(),
      'isAudio': isAudio,
      'audioPath': audioPath,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      isAudio: map['isAudio'] ?? false,
      audioPath: map['audioPath'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, type: $type, timestamp: $timestamp, status: $status, isAudio: $isAudio, audioPath: $audioPath)';
  }
}
