import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/widgets/bottom_sheet.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  late String imageUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
  late TextEditingController _controllerName;
  late TextEditingController _controllerUserName;
  late TextEditingController _controllerBio;

  @override
  void initState() {
    super.initState();
    fetchData();
    _controllerName = TextEditingController();
    _controllerUserName = TextEditingController();
    _controllerBio = TextEditingController();
  }

  Future fetchData() async {
    final dataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(SharedPrefs.getUserId())
        .get();
    final data = dataSnapshot.data();

    if (data!['Accname'] != null) {
      _controllerName.text = data['Accname'];
    }
    if (data['userName'] != null) {
      _controllerUserName.text = data['userName']!;
    }
    if (data['Bio'] != null) {
      _controllerBio.text = data['Bio'];
    }
    setState(() {
      imageUrl = data['profilePhoto'];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerName.dispose();
    _controllerUserName.dispose();
    _controllerBio.dispose();
  }

  Widget showPhoto(Widget? childWidget) {
    return Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          image: (imageUrl != null && imageUrl != "")
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              size: 30,
              color: Colors.red,
            ),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontSize: 23),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc('${SharedPrefs.getUserId()}')
                    .update({
                  'Accname': _controllerName.text.trim(),
                  'Bio': _controllerBio.text.trim(),
                  'userName': _controllerUserName.text.trim(),
                });
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              icon: isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ))
                  : const Icon(
                      Icons.done,
                      size: 30,
                      color: Colors.blue,
                    ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => ShowBottonSheet.changeProfilePhoto(context),
                child: showPhoto(
                  (imageUrl != null && imageUrl != "")
                      ? null
                      : ClipOval(
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
                ),
              ),
              TextButton(
                onPressed: () => ShowBottonSheet.changeProfilePhoto(context),
                child: const Text(
                  'Change Profile Photo',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextField(
                controller: _controllerName,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                cursorColor: Colors.white,
                cursorWidth: 1.5,
                cursorHeight: 18,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 18, color: Colors.white70),
                    hoverColor: Colors.white),
              ),
              TextField(
                controller: _controllerUserName,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                cursorColor: Colors.white,
                cursorWidth: 1.5,
                cursorHeight: 18,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(fontSize: 18, color: Colors.white70),
                    hoverColor: Colors.white),
              ),
              TextField(
                controller: _controllerBio,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                cursorColor: Colors.white,
                cursorWidth: 1.5,
                cursorHeight: 18,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Bio',
                    labelStyle: TextStyle(fontSize: 18, color: Colors.white70),
                    hoverColor: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
