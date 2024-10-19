import 'package:flutter/material.dart';
import 'package:learning1/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.onTap, required this.userProfile});
  final UserProfile userProfile;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        trailing: const Icon(Icons.chat),
        onTap: () {
          onTap();
        },
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(userProfile.pfpURL!),
        ),
        title: Text(userProfile.name!),
      ),
    );
  }
}
