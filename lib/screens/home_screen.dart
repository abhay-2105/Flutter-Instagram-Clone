import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/another_user_profile.dart';
import 'package:instagram/screens/likes_screen.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../models/shared_prefs.dart';

class HomeScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> snapData;
  const HomeScreen(this.snapData, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseInstance = FirebaseFirestore.instance;
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      strokeWidth: 2,
      displacement: 30,
      color: Colors.white,
      backgroundColor: Colors.transparent,
      onRefresh: refresh,
      child: Container(
        width: double.infinity,
        child: RawScrollbar(
          radius: const Radius.circular(5),
          thumbColor: Colors.white54,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.snapData.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder(
                                future: firebaseInstance
                                    .collection('users')
                                    .doc(widget.snapData[index]['userId'])
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot1) {
                                  if (snapshot1.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot1.hasData) {
                                    return const CircleAvatar(
                                        backgroundColor: Colors.black);
                                  }
                                  final profilePhoto =
                                      snapshot1.data!['profilePhoto'];
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AnotherUserProfile(
                                                        widget.snapData[index]
                                                            ['userName'],
                                                        snapshot1
                                                            .data!['postCount'],
                                                        snapshot1.data![
                                                            'profilePhoto'],
                                                        snapshot1
                                                            .data!['Accname'],
                                                        snapshot1.data!['Bio'],
                                                        widget.snapData[index]
                                                            ['userId'],
                                                        snapshot1.data![
                                                            'followingCount'],
                                                        snapshot1.data![
                                                            'followersCount']))),
                                        child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.black,
                                            backgroundImage: NetworkImage(
                                                profilePhoto ??
                                                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png')),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      TextButton(
                                          style: TextButton.styleFrom(
                                              padding: const EdgeInsets.only(
                                                  left: 5)),
                                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => AnotherUserProfile(
                                                  widget.snapData[index]
                                                      ['userName'],
                                                  snapshot1.data!['postCount'],
                                                  snapshot1
                                                      .data!['profilePhoto'],
                                                  snapshot1.data!['Accname'],
                                                  snapshot1.data!['Bio'],
                                                  widget.snapData[index]
                                                      ['userId'],
                                                  snapshot1
                                                      .data!['followingCount'],
                                                  snapshot1.data![
                                                      'followersCount']))),
                                          child: Text(
                                            widget.snapData[index]['userName'],
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ))
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                      StreamBuilder(
                          stream: firebaseInstance
                              .collection('users')
                              .doc(widget.snapData[index]['userId'])
                              .collection('posts')
                              .doc(widget.snapData[index].id)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot2) {
                            if (snapshot2.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot2.hasData) {
                              return Container();
                            }
                            final data = snapshot2.data;
                            final likedUsers = data!['likedUsers'];
                            final users =
                                (data['likedUsers'] as Map).keys.toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onDoubleTap: () async {
                                    if (!users
                                        .contains(SharedPrefs.getUserId())) {
                                      likedUsers[SharedPrefs.getUserId()!] = [
                                        SharedPrefs.getUserName(),
                                        Timestamp.now(),
                                        SharedPrefs.getUserId()
                                      ];
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.snapData[index]['userId'])
                                          .collection('posts')
                                          .doc(widget.snapData[index].id)
                                          .update({
                                        'likes': FieldValue.increment(1),
                                        'likedUsers': likedUsers
                                      });
                                    }
                                    return;
                                  },
                                  child: Container(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          widget.snapData[index]['imageUrl']),
                                    )),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          splashRadius: 5,
                                          onPressed: () async {
                                            if (users.contains(
                                                SharedPrefs.getUserId())) {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(data['userId'])
                                                  .collection('posts')
                                                  .doc(data.id)
                                                  .update({
                                                'likes':
                                                    FieldValue.increment(-1),
                                                'likedUsers.${SharedPrefs.getUserId()}':
                                                    FieldValue.delete()
                                              });
                                              return;
                                            }

                                            likedUsers[
                                                SharedPrefs.getUserId()!] = [
                                              SharedPrefs.getUserName(),
                                              Timestamp.now(),
                                              SharedPrefs.getUserId()
                                            ];
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(data['userId'])
                                                .collection('posts')
                                                .doc(data.id)
                                                .update({
                                              'likes': FieldValue.increment(1),
                                              'likedUsers': likedUsers
                                            });
                                          },
                                          icon: Icon(
                                            (users).contains(
                                                    SharedPrefs.getUserId())
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            color: users.contains(
                                                    SharedPrefs.getUserId())
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          splashRadius: 5,
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          splashRadius: 5,
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.send_outlined,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.save_outlined,
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LikesScreen(likedUsers))),
                                    child: Text(
                                      '${data['likes']} likes',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.snapData[index]['userName']} ',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${widget.snapData[index]['caption']}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
