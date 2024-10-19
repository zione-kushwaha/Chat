import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/models/user_profile.dart';
import 'package:learning1/service/media_service.dart';
import 'package:learning1/service/storage_service.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();

    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.userProfile.uid!,
        firstName: widget.userProfile.name,
        profileImage: widget.userProfile.pfpURL!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile.name!,
            style: const TextStyle(color: Colors.white)),
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return StreamBuilder<DocumentSnapshot<Chat>>(
        stream: _databaseService.getChatsData(
            _authService.user!.uid, widget.userProfile.uid!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final chatData = snapshot.data!.data();
          List<ChatMessage> messages = [];
          if (chatData != null && chatData.messages != null) {
            messages = generateChatMessages(chatData.messages!);
          }

          return DashChat(
            currentUser: currentUser!,
            messages: messages,
            onSend: onSend,
            inputOptions: InputOptions(
              alwaysShowSend: true,
              sendOnEnter: true,
              trailing: [_mediaMessageButton()],
              sendButtonBuilder: (onSend) {
                return IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: onSend,
                );
              },
            ),
          );
        });
  }

  // Function to send a message
  void onSend(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendMessage(
            _authService.user!.uid, widget.userProfile.uid!, message);
      }
    } else {
      Message messageToSend = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      await _databaseService.sendMessage(
          _authService.user!.uid, widget.userProfile.uid!, messageToSend);
    }
  }

  List<ChatMessage> generateChatMessages(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((e) {
      if (e.messageType == MessageType.Image) {
        return ChatMessage(
          user: e.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: e.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: e.content!,
              fileName: '',
              type: MediaType.image,
            )
          ],
        );
      } else {
        return ChatMessage(
          text: e.content!,
          user: e.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: e.sentAt!.toDate(),
        );
      }
    }).toList();

    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        icon: Icon(Icons.image, color: Theme.of(context).primaryColor),
        onPressed: () async {
          File? file = await _mediaService.getImageFromGallery();
          if (file != null) {
            String chatId = _databaseService.generateChatId(
                _authService.user!.uid, widget.userProfile.uid!);
            final downloadUrl =
                await _storageService.uploadChatImage(file, chatId);

            if (downloadUrl != null) {
              ChatMessage message = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                    url: downloadUrl,
                    fileName: '',
                    type: MediaType.image,
                  )
                ],
              );
              onSend(message);
            }
          }
        });
  }
}
