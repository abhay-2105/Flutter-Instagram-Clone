import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/another_user_profile.dart';
import 'package:instagram/screens/loading_screen.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen(this.likedUsers, {super.key});
  final Map likedUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(CupertinoIcons.arrow_left)),
        backgroundColor: Colors.black,
        title: const Text(
          'Likes',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: ListView.builder(
        itemCount: likedUsers.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(likedUsers.values.toList()[index][2])
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                final data = snapshot.data;
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AnotherUserProfile(
                          data!['userName'],
                          data['postCount'],
                          data['profilePhoto'],
                          data['Accname'],
                          data['Bio'],
                          data.id,
                          data['followingCount'],
                          data['followersCount']))),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black,
                      backgroundImage: NetworkImage(data!['profilePhoto']),
                    ),
                    title: Text(
                      likedUsers.values.toList()[index][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(data['Accname'],
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              });
        },
      ),
    );
  }
}
