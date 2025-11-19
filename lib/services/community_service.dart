import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../models/user_model.dart';

class CommunityService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChatGroup> _availableGroups = [];
  List<ChatGroup> get availableGroups => _availableGroups;

  List<ChatGroup> _joinedGroups = [];
  List<ChatGroup> get joinedGroups => _joinedGroups;

  List<ChatMessage> _currentGroupMessages = [];
  List<ChatMessage> get currentGroupMessages => _currentGroupMessages;

  String? _currentGroupId;
  String? get currentGroupId => _currentGroupId;

  // Load available community groups
  Future<void> loadAvailableGroups() async {
    try {
      final snapshot = await _firestore
          .collection('communityGroups')
          .orderBy('createdAt', descending: false)
          .get();

      _availableGroups = snapshot.docs
          .map((doc) => ChatGroup.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  // Load groups user has joined
  Future<void> loadJoinedGroups() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('communityGroups')
          .where('memberIds', arrayContains: user.uid)
          .get();

      _joinedGroups = snapshot.docs
          .map((doc) => ChatGroup.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading joined groups: $e');
    }
  }

  // Join a group
  Future<bool> joinGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final groupDoc = _firestore.collection('communityGroups').doc(groupId);
      final group = await groupDoc.get();

      if (!group.exists) return false;

      final groupData = ChatGroup.fromFirestore(group);
      
      // Check if group is full
      if (groupData.memberIds.length >= groupData.maxMembers) {
        debugPrint('Group is full');
        return false;
      }

      // Add user to group
      await groupDoc.update({
        'memberIds': FieldValue.arrayUnion([user.uid]),
      });

      // Update user's joined groups
      await _firestore.collection('users').doc(user.uid).update({
        'joinedGroups': FieldValue.arrayUnion([groupId]),
      });

      await loadJoinedGroups();
      return true;
    } catch (e) {
      debugPrint('Error joining group: $e');
      return false;
    }
  }

  // Leave a group
  Future<bool> leaveGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Remove user from group
      await _firestore.collection('communityGroups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([user.uid]),
      });

      // Update user's joined groups
      await _firestore.collection('users').doc(user.uid).update({
        'joinedGroups': FieldValue.arrayRemove([groupId]),
      });

      await loadJoinedGroups();
      return true;
    } catch (e) {
      debugPrint('Error leaving group: $e');
      return false;
    }
  }

  // Listen to messages in a group (real-time)
  Stream<List<ChatMessage>> getGroupMessagesStream(String groupId) {
    _currentGroupId = groupId;

    return _firestore
        .collection('communityGroups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
      
      _currentGroupMessages = messages;
      return messages;
    });
  }

  // Send message to group
  Future<bool> sendMessage(String groupId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Get user's community alias
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromFirestore(userDoc);
      final alias = userData.communityAlias ?? 'Anonymous';

      final message = ChatMessage(
        id: '',
        groupId: groupId,
        senderId: user.uid,
        senderAlias: alias,
        senderPhotoUrl: userData.photoUrl,
        text: text,
        timestamp: DateTime.now(),
      );

      // Add message to group
      await _firestore
          .collection('communityGroups')
          .doc(groupId)
          .collection('messages')
          .add(message.toFirestore());

      // Update group's last message
      await _firestore.collection('communityGroups').doc(groupId).update({
        'lastMessage': text.length > 50 ? '${text.substring(0, 50)}...' : text,
        'lastMessageTime': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Report message
  Future<bool> reportMessage(String messageId, String groupId, String reason) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('reports').add({
        'messageId': messageId,
        'groupId': groupId,
        'reportedBy': user.uid,
        'reason': reason,
        'timestamp': Timestamp.now(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      debugPrint('Error reporting message: $e');
      return false;
    }
  }

  // Create a new group (admin functionality)
  Future<String?> createGroup({
    required String name,
    required String description,
    required String category,
    int maxMembers = 50,
  }) async {
    try {
      final group = ChatGroup(
        id: '',
        name: name,
        description: description,
        category: category,
        memberIds: [],
        maxMembers: maxMembers,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('communityGroups')
          .add(group.toFirestore());

      await loadAvailableGroups();
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  // Get suggested groups based on user's mental health history
  List<ChatGroup> getSuggestedGroups(List<String> mentalHealthHistory) {
    return _availableGroups.where((group) {
      // Match group category with user's mental health history
      for (var condition in mentalHealthHistory) {
        if (group.category.toLowerCase().contains(condition.toLowerCase())) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  // Search groups
  List<ChatGroup> searchGroups(String query) {
    final lowerQuery = query.toLowerCase();
    return _availableGroups.where((group) {
      return group.name.toLowerCase().contains(lowerQuery) ||
          group.description.toLowerCase().contains(lowerQuery) ||
          group.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

