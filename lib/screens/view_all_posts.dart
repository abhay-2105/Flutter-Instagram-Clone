import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/likes_screen.dart';
import 'package:instagram/widgets/bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ViewAllPosts extends StatelessWidget {
  final int index;
  final String userName;
  final String? profileImageUrl;
  final String userId;
  ViewAllPosts(this.index, this.userName, this.profileImageUrl, this.userId,
      {super.key});

  final AutoScrollController _scrollController =
      AutoScrollController(axis: Axis.vertical);

  // @override
  // void initState() {
  //   // currentUser = Provider.of<CurrentUser>(context, listen: false);
  //   _scrollController = AutoScrollController(
  //       // initialScrollOffset: (400 * widget.index).toDouble(),
  //       // viewportBoundaryGetter: () =>
  //       //     Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
  //       axis: Axis.vertical);
  //   // _scrollToIndex(widget.index);

  //   super.initState();
  // }

  // Future<void> _scrollToIndex(index) async {
  //   await _scrollController.scrollToIndex(
  //     index,
  //   );
  //   _scrollController.highlight(index);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Posts',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('posts')
              .orderBy('Time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
            if (snapshot1.connectionState == ConnectionState.waiting ||
                !snapshot1.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.grey[300],
              ));
            }
            final postDocs = snapshot1.data!.docs;
            return RawScrollbar(
              controller: _scrollController,
              radius: const Radius.circular(5),
              thumbColor: Colors.white54,
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: postDocs.length,
                      itemBuilder: (context, index) {
                        final likedUsers = postDocs[index]['likedUsers'];
                        final likes = postDocs[index]['likes'];
                        final users = (postDocs[index]['likedUsers'] as Map)
                            .keys
                            .toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage: (profileImageUrl !=
                                                    null &&
                                                profileImageUrl != "")
                                            ? NetworkImage(profileImageUrl!)
                                            : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        ShowBottonSheet.editPost(
                                            context, postDocs[index].id);
                                      },
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                            GestureDetector(
                              onDoubleTap: () async {
                                if (!users.contains(SharedPrefs.getUserId())) {
                                  likedUsers[SharedPrefs.getUserId()!] = [
                                    SharedPrefs.getUserName(),
                                    Timestamp.now(),
                                    SharedPrefs.getUserId()
                                  ];
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('posts')
                                      .doc(postDocs[index].id)
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
                                  image:
                                      NetworkImage(postDocs[index]['imageUrl']),
                                )),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              .doc(userId)
                                              .collection('posts')
                                              .doc(postDocs[index].id)
                                              .update({
                                            'likes': FieldValue.increment(-1),
                                            'likedUsers.${SharedPrefs.getUserId()}':
                                                FieldValue.delete()
                                          });
                                          return;
                                        }

                                        likedUsers[SharedPrefs.getUserId()!] = [
                                          SharedPrefs.getUserName(),
                                          Timestamp.now(),
                                          SharedPrefs.getUserId()
                                        ];
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .collection('posts')
                                            .doc(postDocs[index].id)
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LikesScreen(likedUsers))),
                                child: Text(
                                  '$likes likes',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(
                                    '$userName ',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${postDocs[index]['caption']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        );
                      })),
            );
          }),
    );
  }
}
