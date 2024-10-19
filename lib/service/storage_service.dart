import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService() {}
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Uploading the user pfp to Firebase Storage
  Future<String?> uploadUserPfps(File file, String uid) async {
    try {
      final ref = _firebaseStorage
          .ref('users/pfp')
          .child('$uid${p.extension(file.path)}');
      UploadTask task = ref.putFile(file);

      // Await the task to complete
      TaskSnapshot snapshot = await task;

      // Check for errors
      if (snapshot.state == TaskState.error) {
        print('Error during upload: ${snapshot.state}');
        return null;
      }

      // Get the download URL
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading user pfp: $e');
      return null;
    }
  }

  // Uploading the chat image to Firebase Storage
  Future<String?> uploadChatImage(File file, String chatId) async {
    try {
      final ref = _firebaseStorage.ref('chats/images/$chatId').child(
          '${DateTime.now().toIso8601String()}${p.extension(file.path)}');
      UploadTask task = ref.putFile(file);

      // Await the task to complete
      TaskSnapshot snapshot = await task;

      // Check for errors
      if (snapshot.state == TaskState.error) {
        print('Error during upload: ${snapshot.state}');
        return null;
      }

      // Get the download URL
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading chat image: $e');
      return null;
    }
  }
}
