import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/view_all_posts.dart';
import 'package:instagram/widgets/complete_profile.dart';
import 'package:provider/provider.dart';

class PostContent extends StatelessWidget {
  PostContent({super.key});
  late final CurrentUser currentUser;

  final List<Widget> _tabView = [
    CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 250,
                child: Text(
                  'When you share photos and videos, they\'ll appear on your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Share your first photo or video',
                    style: TextStyle(fontSize: 15),
                  )),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: CompleteProfile(
          key: const PageStorageKey('one'),
        ),
      )
    ]),
    CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 150,
                child: Text(
                  'Photos and videos of you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 250,
                child: Text(
                  'When people tag you in photos and videos, they\'ll appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: CompleteProfile(
          key: const PageStorageKey('two'),
        ),
      ),
    ]),
  ];

  List<Widget> _tabView2(List<QueryDocumentSnapshot<Object?>> postDocs) {
    return [
      CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            delegate: SliverChildBuilderDelegate(
              childCount: postDocs.length,
              (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewAllPosts(
                          // postDocs,
                          index,
                          currentUser.username!,
                          currentUser.profileImageUrl,
                          currentUser.userId!))),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 8) / 3,
                    height: 100,
                    margin: EdgeInsets.only(
                        left: 2, top: 2, right: (index + 1) / 3 == 0 ? 2 : 0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          postDocs[index]['imageUrl'],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: CompleteProfile(
              key: const PageStorageKey('two'),
            ),
          )
        ],
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 150,
                    child: Text(
                      'Photos and videos of you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      'When people tag you in photos and videos, they\'ll appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CompleteProfile(
              key: const PageStorageKey('two'),
            ),
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<CurrentUser>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(SharedPrefs.getUserId())
          .collection('posts')
          .orderBy('Time', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
              strokeWidth: 2,
            ),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return TabBarView(children: _tabView);
        }
        final postDocs = snapshot.data!.docs;
        return TabBarView(children: _tabView2(postDocs));
      },
    );
  }
}
