import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/select_photo.dart';
import 'package:instagram/widgets/bottom_sheet.dart';
import 'dart:math';

class Appbars extends StatelessWidget {
  final int index;
  const Appbars(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: TextButton(
          child: const Text(
            'Instagram',
            style: TextStyle(
                color: Color.fromARGB(255, 240, 228, 228),
                fontFamily: 'Billabong',
                fontSize: 35,
                fontWeight: FontWeight.w500,
                letterSpacing: 1),
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectPhoto(),
                ),
              );
            },
            icon: const Icon(
              Icons.add_box_outlined,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Transform.rotate(
              angle: (-45) * pi / 180,
              child: const Icon(
                Icons.send,
                size: 30,
              ),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    } else if (index == 2) {
      return AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(SharedPrefs.getUserId())
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return Container();
            }
            final title = snapshot.data!['userName'];
            return Text(
              title ?? '...',
              style: const TextStyle(color: Colors.white),
            );
          }),
      actions: [
        IconButton(
          onPressed: () => ShowBottonSheet.showCreateContent(context),
          icon: const Icon(
            Icons.add_box_outlined,
            size: 30,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
          onPressed: () => ShowBottonSheet.showMenuContent(context),
        ),
      ],
    );
  }
}
