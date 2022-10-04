import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/view_all_posts.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AnotherUserProfile extends StatelessWidget {
  final String userName;
  final int postCount;
  final int followersCount;
  final int followingCount;
  final String? profileImageUrl;
  final String? accName;
  final String? userBio;
  final String userId;
  const AnotherUserProfile(
      this.userName,
      this.postCount,
      this.profileImageUrl,
      this.accName,
      this.userBio,
      this.userId,
      this.followingCount,
      this.followersCount,
      {super.key});

  final List<Tab> _tabs = const [
    Tab(
        icon: Icon(
      Icons.grid_on_outlined,
      size: 28,
    )),
    Tab(
        icon: Icon(
      Icons.person_pin_outlined,
      size: 28,
    ))
  ];

  Widget showPhoto(Widget? childWidget, String? imageUrl) {
    return Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl), fit: BoxFit.cover)
              : null,
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: childWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: NestedScrollView(
            physics: const NeverScrollableScrollPhysics(),
            body: TabBarView(children: [
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('posts')
                      .orderBy('Time', descending: true)
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.grey[300],
                        ),
                      );
                    }
                    final postDocs = snapshot.data!.docs;
                    if (postDocs.isNotEmpty) {
                      return CustomScrollView(
                        slivers: [
                          SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            delegate: SliverChildBuilderDelegate(
                              childCount: postDocs.length,
                              (context, index) {
                                return GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => ViewAllPosts(
                                              // postDocs,
                                              index,
                                              userName,
                                              profileImageUrl,
                                              userId))),
                                  child: Container(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  8) /
                                              3,
                                      height: 100,
                                      margin: EdgeInsets.only(
                                          left: 2,
                                          top: 2,
                                          right: (index + 1) / 3 == 0 ? 2 : 0),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          postDocs[index]['imageUrl'],
                                        ),
                                      ))),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)),
                            child: const Icon(
                              size: 45,
                              CupertinoIcons.camera,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'No posts Yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white)),
                      child: const Icon(
                        size: 45,
                        CupertinoIcons.camera,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('No posts Yet',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ]),
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data = snapshot.data;
                          return Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          (data!['profilePhoto'] != null &&
                                                  data['profilePhoto'] != "")
                                              ? showPhoto(null, profileImageUrl)
                                              : showPhoto(
                                                  Stack(
                                                    fit: StackFit.expand,
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      ClipOval(
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          children: const [
                                                            Positioned(
                                                              bottom: -17,
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .white,
                                                                size: 100,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  null,
                                                ),
                                          const SizedBox(height: 5),
                                          if (accName != null && accName != "")
                                            Text(
                                              accName!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            data['postCount'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          const Text('Posts',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              )),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            data['followersCount'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          const Text('Followers',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            data['followingCount'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            'Following',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                if (userBio != null && userBio != "")
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Text(
                                      userBio!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                if (userId != SharedPrefs.getUserId())
                                  Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  !(data['followers']
                                                              as List<dynamic>)
                                                          .contains(SharedPrefs
                                                              .getUserId())
                                                      ? Colors.blue
                                                      : const Color.fromARGB(
                                                          255, 38, 38, 38),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () async {
                                            if (!(data['followers']
                                                    as List<dynamic>)
                                                .contains(
                                                    SharedPrefs.getUserId())) {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userId)
                                                  .update({
                                                'followers':
                                                    FieldValue.arrayUnion([
                                                  SharedPrefs.getUserId()
                                                ]),
                                                'followersCount':
                                                    FieldValue.increment(1)
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(SharedPrefs.getUserId())
                                                  .update({
                                                'following':
                                                    FieldValue.arrayUnion(
                                                        [userId]),
                                                'followingCount':
                                                    FieldValue.increment(1)
                                              });
                                              return;
                                            }
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .update({
                                              'followers':
                                                  FieldValue.arrayRemove([
                                                SharedPrefs.getUserId()
                                              ]),
                                              'followersCount':
                                                  FieldValue.increment(-1)
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(SharedPrefs.getUserId())
                                                .update({
                                              'following':
                                                  FieldValue.arrayRemove(
                                                      [userId]),
                                              'followingCount':
                                                  FieldValue.increment(-1)
                                            });
                                            return;
                                          },
                                          child: Text(
                                            (data['followers'] as List<dynamic>)
                                                    .contains(
                                                        SharedPrefs.getUserId())
                                                ? 'Unfollow'
                                                : 'Follow',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          )),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                  ),
                  SliverPinnedHeader(
                    child: ColoredBox(
                      color: Colors.black,
                      child: TabBar(
                        indicatorColor: Colors.white,
                        tabs: _tabs,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                      ),
                    ),
                  ),
                ]),
      ),
    );
  }
}
