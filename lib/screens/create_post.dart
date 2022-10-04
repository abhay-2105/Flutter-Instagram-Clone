import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  final List<File> uploadFiles;
  const CreatePost(this.uploadFiles, {super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  late CurrentUser currentUser;
  bool isLoading = false;
  late TextEditingController textEditingController;
  Future<void> _trySubmit() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    try {
      print(textEditingController.text);
      setState(() {
        isLoading = true;
      });
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_posts')
          .child('${currentUser.username}')
          .child('${currentUser.userId}${currentUser.postCount! + 1}.jpg');
      await ref.putFile(widget.uploadFiles[0]);
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId)
          .collection('posts')
          .doc('${currentUser.userId}${currentUser.postCount! + 1}')
          .set({
        'userName': SharedPrefs.getUserName(),
        'caption': textEditingController.text.trim(),
        'imageUrl': url,
        'likes': 0,
        'Time': DateTime.now(),
        'likedUsers': {},
        'userId': SharedPrefs.getUserId()
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId)
          .update({'postCount': currentUser.postCount! + 1});
      currentUser.postCount = currentUser.postCount! + 1;
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    currentUser = Provider.of<CurrentUser>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _trySubmit,
            icon: isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 28,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 25,
                  backgroundImage: NetworkImage(currentUser.profileImageUrl!),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    enabled: isLoading ? false : true,
                    controller: textEditingController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Write a caption..',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    image: DecorationImage(
                      image: FileImage(widget.uploadFiles[0]),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
