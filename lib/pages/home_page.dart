import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/service/database_service.dart';

import '../models/user_profile.dart';
import '../service/alert_service.dart';
import '../service/auth_service.dart';
import '../service/navigation_service.dart';
import '../widgets/chat_tile.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.logOut();
              _navigationService.pushReplacementNamed('login');
              _alertService.showToast(
                message: 'Logout successfully',
                icon: Icons.check_circle,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20,
        ),
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder<List<UserProfile?>>(
      stream: _databaseService.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data;
        return ListView.builder(
          itemCount: users!.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ChatTile(
              userProfile: user!,
              onTap: () async {
                bool chatExist = await _databaseService.checkChatExist(
                  _authService.user!.uid,
                  user.uid!,
                );
                if (!chatExist) {
                  await _databaseService.createChat(
                    _authService.user!.uid,
                    user.uid!,
                  );
                }
                _navigationService.push(MaterialPageRoute(builder: (context) {
                  return ChatPage(
                    userProfile: user,
                  );
                }));
              },
            );
          },
        );
      },
    );
  }
}
