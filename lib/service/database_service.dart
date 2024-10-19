import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/models/chat.dart';
import 'package:learning1/service/auth_service.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference<UserProfile> _collectionReference;
  late CollectionReference<Chat> _chatCollectionReference;
  late AuthService _authService;

  DatabaseService() {
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _authService = _getIt.get<AuthService>();
    _collectionReference =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshot, _) =>
                  UserProfile.fromJson(snapshot.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );

    _chatCollectionReference =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile profile}) async {
    try {
      await _collectionReference.doc(profile.uid).set(profile);
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Stream<List<UserProfile?>> getUserProfile() {
    return _collectionReference
        .where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      } else {
        return [];
      }
    });
  }

  // Function to check if a chat exists
  Future<bool> checkChatExist(String uid1, String uid2) async {
    try {
      String chatId = generateChatId(uid1, uid2);
      final snapshot = await _chatCollectionReference.doc(chatId).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking chat exist: $e');
      return false;
    }
  }

  String generateChatId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // Function to create a chat
  Future<void> createChat(String uid1, String uid2) async {
    try {
      String chatId = generateChatId(uid1, uid2);
      final chat = Chat(
        id: chatId,
        participants: [uid1, uid2],
        messages: [],
      );
      await _chatCollectionReference.doc(chatId).set(chat);
    } catch (e) {
      print('Error creating chat: $e');
    }
  }

  // Function to send a chat message
  Future<void> sendMessage(
      String currentUserId, String otherUserId, Message message) async {
    final chatId = generateChatId(currentUserId, otherUserId);
    final chatDoc = _chatCollectionReference.doc(chatId);

    await chatDoc.update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
    });
  }

  // Function to get the list of chats
  Stream<List<Chat>> getChats() {
    return _chatCollectionReference
        .where('participants', arrayContains: _authService.user!.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      } else {
        return [];
      }
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatsData(String uid1, String uid2) {
    String chatId = generateChatId(uid1, uid2);
    return _chatCollectionReference.doc(chatId).snapshots();
  }
}
