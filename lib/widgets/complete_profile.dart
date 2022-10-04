import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/edit_profile.dart';

class CompleteProfile extends StatelessWidget {
  CompleteProfile({super.key});
  int complete = 0;

  Widget _completePofileList(IconData icon, String title, String body,
      String buttonText, BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(left: 15),
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[600]!, width: 0.6)),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black,
              child: Icon(
                icon,
                color: Colors.grey[300],
                size: 30,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(ctx)
                .push(MaterialPageRoute(builder: (ctx) => const EditProfile())),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          complete = 0;
          final data = snapshot.data;
          if (data!['Accname'] != "") {
            complete++;
          }
          if (data['profilePhoto'] != null && data['profilePhoto'] != "") {
            complete++;
          }
          if (data['Bio'] != "") {
            complete++;
          }
          if (data['followingCount'] > 0) {
            complete++;
          }
          return complete < 4
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: 3,
                      ),
                      child: const Text(
                        'Complete your profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text('$complete of 4  ',
                              style: TextStyle(
                                  color: complete == 0
                                      ? Colors.orange
                                      : Colors.green,
                                  fontSize: 12)),
                          Text('Complete',
                              style: TextStyle(
                                  color: Colors.grey[300], fontSize: 12))
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (data['Accname'] == null || data['Accname'] == "")
                            _completePofileList(
                                Icons.person_outline,
                                'Add your name',
                                'Add your full name so your friends know it\'s you.',
                                'Add Name',
                                context),
                          if (data['profilePhoto'] == null ||
                              data['profilePhoto'] == "")
                            _completePofileList(
                                Icons.person_rounded,
                                'Add profle photo',
                                'Choose a profile photo to represnt yourself on Instagram.',
                                'Add Photo',
                                context),
                          if (data['Bio'] == null || data['Bio'] == "")
                            _completePofileList(
                                Icons.person_add,
                                'Add bio',
                                'Tell your followers a little bit about yourself.',
                                'Add bio',
                                context),
                          if (data['followingCount'] == 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: _completePofileList(
                                  Icons.people_outline,
                                  'Find people to follow',
                                  'Follow people and interests you care about',
                                  'Find people',
                                  context),
                            ),
                        ],
                      ),
                    )
                  ],
                )
              : Container();
        });
  }
}
