import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';

class ShowBottonSheet {
  static Widget _createRow(
    IconData? icon,
    String text,
    var onTap,
  ) {
    return InkWell(
      highlightColor: const Color.fromARGB(255, 73, 72, 72),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: TextStyle(
                  color:
                      (text == 'Remove Profile photo' || text == 'Delete Post')
                          ? Colors.red
                          : Colors.white,
                  fontSize: 17),
            )
          ],
        ),
      ),
    );
  }

  static void showMenuContent(context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 38, 38, 38),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                child: Divider(
                  thickness: 5,
                  color: Colors.white54,
                ),
              ),
              _createRow(Icons.settings, 'Settings', () {}),
              _createRow(Icons.archive_outlined, 'Archive', () {}),
              _createRow(Icons.av_timer, 'Your Activity', () {}),
              _createRow(Icons.qr_code, 'QR code', () {}),
              _createRow(Icons.saved_search, 'Saved', () {}),
              _createRow(Icons.ramp_right, 'Digital collectibles', () {}),
              _createRow(Icons.menu_open, 'Close Friends', () {}),
              _createRow(Icons.star_border, 'Favorites', () {}),
              _createRow(Icons.logout, 'Log Out', () async {
                Navigator.pop(context);
                try {
                  await SharedPrefs.deletePrefs();
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  print(e);
                }
              }),
            ],
          ),
        );
      },
    );
  }

  static void showCreateContent(context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 38, 38, 38),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                child: Divider(
                  thickness: 5,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Create',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              const SizedBox(height: 3),
              Divider(
                color: Colors.grey[800]!,
                thickness: 0,
              ),
              _createRow(CupertinoIcons.video_camera, 'Reel', () {}),
              _createRow(Icons.grid_on, 'Post', () {}),
              _createRow(Icons.add_circle_rounded, 'Story', () {}),
              _createRow(Icons.history_toggle_off, 'Story Highlight', () {}),
              _createRow(Icons.signal_cellular_alt_outlined, 'Live', () {})
            ],
          ),
        );
      },
    );
  }

  static void changeProfilePhoto(BuildContext context) {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 38, 38, 38),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  child: Divider(
                    thickness: 5,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Text(
                        'Change profile photo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Divider(
                  color: Colors.grey[800]!,
                  thickness: 0,
                ),
                InkWell(
                  highlightColor: const Color.fromARGB(255, 73, 72, 72),
                  onTap: () async {
                    CurrentUser user =
                        Provider.of<CurrentUser>(context, listen: false);
                    ImagePicker picker = ImagePicker();
                    Navigator.of(context).pop();
                    await picker
                        .pickImage(source: ImageSource.gallery)
                        .then((image) async {
                      if (image != null) {
                        Fluttertoast.showToast(
                            timeInSecForIosWeb: 1,
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor:
                                const Color.fromARGB(255, 38, 38, 38),
                            msg: 'Uploading image...');
                        File imageFile = File(image.path);
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('user_image')
                            .child('${user.userId}.jpg');
                        await ref.putFile(imageFile);
                        final url = await ref.getDownloadURL();
                        user.setProfileImageUrl(url);
                        Fluttertoast.showToast(
                            timeInSecForIosWeb: 1,
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor:
                                const Color.fromARGB(255, 38, 38, 38),
                            msg: 'Profile photo updated.');
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.userId)
                            .update({'profilePhoto': url});
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      children: const [
                        Text(
                          'New profile photo',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: const Color.fromARGB(255, 73, 72, 72),
                  onTap: () async {
                    var user = Provider.of<CurrentUser>(context, listen: false);
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                        timeInSecForIosWeb: 1,
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: (user.profileImageUrl == null ||
                                user.profileImageUrl == "")
                            ? Colors.red
                            : const Color.fromARGB(255, 38, 38, 38),
                        msg: (user.profileImageUrl == null ||
                                user.profileImageUrl == "")
                            ? 'No Profile photo'
                            : 'Profile photo removed');
                    if (user.profileImageUrl != null &&
                        user.profileImageUrl != "") {
                      user.setProfileImageUrl(null);
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.userId)
                          .update({'profilePhoto': null});
                      FirebaseStorage.instance
                          .ref()
                          .child('user_image')
                          .child('${user.userId}.jpg')
                          .delete();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      children: const [
                        Text(
                          'Remove profile photo',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static showFolderFromGallery(
      BuildContext context1, List<Album> album, var func) {
    return showModalBottomSheet<dynamic>(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context1).size.height -
              MediaQuery.of(context1).padding.top),
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 38, 38, 38),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        topLeft: Radius.circular(20),
      )),
      context: context1,
      builder: (context1) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < album.length; i++)
                ShowBottonSheet._createRow(null, album[i].name!, () {
                  func(album[i].name!);
                  Navigator.of(context1).pop();
                })
            ],
          ),
        );
      },
    );
  }

  static Future<void> deletePost(String docId, BuildContext ctx) async {
    Navigator.of(ctx).pop();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(SharedPrefs.getUserId())
        .collection('posts')
        .doc(docId)
        .delete();

    Fluttertoast.showToast(
        timeInSecForIosWeb: 1,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: const Color.fromARGB(255, 38, 38, 38),
        msg: 'Post deleted successfully');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(SharedPrefs.getUserId())
        .update({'postCount': FieldValue.increment(-1)});
  }

  static editPost(BuildContext context1, String postDoc) {
    return showModalBottomSheet<dynamic>(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context1).size.height -
              MediaQuery.of(context1).padding.top),
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 38, 38, 38),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        topLeft: Radius.circular(20),
      )),
      context: context1,
      builder: (context1) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            _createRow(null, 'Edit Post', () {}),
            _createRow(
                null, 'Delete Post', () => deletePost(postDoc, context1)),
            const SizedBox(
              height: 20,
            )
          ],
        );
      },
    );
  }
}
