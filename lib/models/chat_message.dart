import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderAlias;
  final String? senderPhotoUrl;
  final String text;
  final DateTime timestamp;
  final bool isEdited;
  final bool isDeleted;
  final List<String> reactions;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderAlias,
    this.senderPhotoUrl,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.isDeleted = false,
    this.reactions = const [],
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      groupId: data['groupId'],
      senderId: data['senderId'],
      senderAlias: data['senderAlias'],
      senderPhotoUrl: data['senderPhotoUrl'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      reactions: List<String>.from(data['reactions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderAlias': senderAlias,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'reactions': reactions,
    };
  }
}

class ChatGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> memberIds;
  final int maxMembers;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberIds,
    this.maxMembers = 50,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatGroup(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      category: data['category'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 50,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
    };
  }
}

