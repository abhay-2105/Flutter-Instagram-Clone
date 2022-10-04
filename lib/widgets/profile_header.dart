import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'bottom_sheet.dart';

class ProfileHeader extends StatelessWidget {
  ProfileHeader({super.key});
  late String imageUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  late CurrentUser currentUser;
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
    currentUser = Provider.of<CurrentUser>(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(SharedPrefs.getUserId())
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container();
          }
          final data = snapshot.data;
          return Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                ShowBottonSheet.changeProfilePhoto(context),
                            child: (data!['profilePhoto'] != null &&
                                    data['profilePhoto'] != "")
                                ? showPhoto(null, data['profilePhoto'])
                                : showPhoto(
                                    Stack(
                                      fit: StackFit.expand,
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipOval(
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: const [
                                              Positioned(
                                                bottom: -17,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Positioned(
                                        //   bottom: -11,
                                        //   left: 20,
                                        //   child: Container(
                                        //     decoration: BoxDecoration(
                                        //         color: Colors.blue,
                                        //         borderRadius:
                                        //             BorderRadius.circular(5),
                                        //         border: Border.all(
                                        //             color: Colors.black, width: 2)),
                                        //     padding: const EdgeInsets.symmetric(
                                        //         horizontal: 5, vertical: 3),
                                        //     child: const Text(
                                        //       'NEW',
                                        //       style: TextStyle(
                                        //         fontSize: 11,
                                        //         color: Colors.white,
                                        //         fontWeight: FontWeight.w600,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                    null,
                                  ),
                          ),
                          const SizedBox(height: 5),
                          if (data['Accname'] != null && data['Accname'] != "")
                            Text(
                              data['Accname'],
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
                if (data['Bio'] != null && data['Bio'] != "")
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      data['Bio'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 38, 38, 38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const EditProfile()));
                            // .whenComplete(() => setState(() {}));
                          },
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => print('Suggestions'),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 38, 38, 38),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.person_add_outlined,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
