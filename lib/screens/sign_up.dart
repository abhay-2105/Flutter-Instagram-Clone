import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/model.dart';
import 'package:provider/provider.dart';
import '../models/shared_prefs.dart';
import '../widgets/preview_camera.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  File? _pickedimage;
  late int _index;
  late TextEditingController _controller;
  bool _isEnabled = false;
  String _email = '';
  String _userName = '';
  String _password = '';
  bool _isLoading = false;
  late UserCredential authResult;

  @override
  void initState() {
    super.initState();
    _index = 0;
    _controller = TextEditingController();
    _controller.addListener(() {
      if (_controller.text != '') {
        setState(() {
          _isEnabled = true;
        });
      }
      if (_controller.text == '') {
        setState(() {
          _isEnabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void setImage(File? imageFile) {
    setState(() {
      _pickedimage = imageFile;
    });
  }

  Widget _addProfilePhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              )),
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                _pickedimage == null ? null : FileImage(_pickedimage!),
            backgroundColor: Colors.black,
            child: _pickedimage == null
                ? const Icon(
                    CupertinoIcons.camera,
                    color: Colors.white,
                    size: 44,
                  )
                : null,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        const Text(
          'Add profile photo',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: 250,
          child: Text(
            'Add a profile photo so your friends know it\'s you',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 35,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)),
            ),
            onPressed: _pickedimage == null
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PreviewCamera(setImage)))
                : () async {
                    CurrentUser user =
                        Provider.of<CurrentUser>(context, listen: false);
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      final auth = FirebaseAuth.instance;
                      await auth
                          .createUserWithEmailAndPassword(
                              email: _email, password: _password)
                          .then((authResult) {
                        Future.delayed(const Duration(milliseconds: 300))
                            .then((value) async {
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('user_image')
                              .child('${authResult.user!.uid}.jpg');

                          await ref.putFile(_pickedimage!);
                          final url = await ref.getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(authResult.user!.uid)
                              .set({
                            'userName': _userName.trim(),
                            'email': _email.trim(),
                            'profilePhoto': url,
                            'followers': 0,
                            'following': 0,
                            'followersCount': 0,
                            'followingCount': 0
                          });
                          user.setUserId(auth.currentUser!.uid);
                          user.setUsername(_userName);
                          user.setProfileImageUrl(url);
                          final _auth = FirebaseAuth.instance;
                          await SharedPrefs.setUserId(_auth.currentUser!.uid);
                          await SharedPrefs.setLogin(true);
                        });
                      });
                    } on PlatformException catch (err) {
                      var message =
                          'An error Occured,Please check your username and password';
                      if (err.message != null) {
                        message = err.message!;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Theme.of(context).errorColor,
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                        _index = 1;
                        _pickedimage = null;
                      });
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.toString()),
                        backgroundColor: Theme.of(context).errorColor,
                      ));
                      setState(() {
                        _isLoading = false;
                        _index = 1;
                        _pickedimage = null;
                      });
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _pickedimage == null ? 'Add a photo' : 'Complete Sign Up',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        if (_isLoading == false)
          TextButton(
              onPressed: () async {
                CurrentUser user =
                    Provider.of<CurrentUser>(context, listen: false);
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  final auth = FirebaseAuth.instance;
                  authResult = await auth.createUserWithEmailAndPassword(
                      email: _email.trim(), password: _password.trim());
                  if (!mounted) return;
                  user.setUserId(auth.currentUser!.uid);
                  user.setUsername(_userName);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(authResult.user!.uid)
                      .set({
                    'userName': _userName.trim(),
                    'email': _email.trim(),
                  });
                } on PlatformException catch (err) {
                  var message =
                      'An error Occured,Please check your username and password';
                  if (err.message != null) {
                    message = err.message!;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Theme.of(context).errorColor,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                    _index = 1;
                    _pickedimage = null;
                  });
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error.toString()),
                    backgroundColor: Theme.of(context).errorColor,
                  ));
                  setState(() {
                    _isLoading = false;
                    _index = 1;
                    _pickedimage = null;
                  });
                }
              },
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 16),
              ))
      ],
    );
  }

  Widget _showOnScreen(
      String title, String subtitle, String hintText, var onTap) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: 250,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        TextFormField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          cursorWidth: 0.5,
          cursorColor: Colors.white,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5)),
              filled: true,
              fillColor: const Color.fromARGB(255, 69, 68, 68),
              hintStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400),
              hintText: hintText),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.transparent,
              disabledBackgroundColor: const Color.fromARGB(255, 26, 31, 93),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)),
            ),
            onPressed: _isEnabled ? onTap : null,
            child: _isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Next',
                    style: TextStyle(
                      color: _isEnabled ? Colors.white : Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_index == 0)
              _showOnScreen(
                'Choose username',
                'You can always change it later.',
                'Username',
                () {
                  setState(() {
                    _index = 1;
                    _userName = _controller.text;
                    print(_userName);
                    _controller.text = '';
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
            if (_index == 1)
              _showOnScreen('Enter your email',
                  'We need your email for sign up.', 'Email', () {
                setState(() {
                  _index = 2;
                  _email = _controller.text;
                  print(_email);
                  _controller.text = '';
                });
                FocusScope.of(context).unfocus();
              }),
            if (_index == 2)
              _showOnScreen(
                'Choose Password',
                'For security, your password must be 6 characters or more.',
                'Password',
                () {
                  setState(() {
                    _index = 3;
                    _password = _controller.text;
                    print(_password);
                    _controller.text = '';
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
            if (_index == 3) _addProfilePhoto(),
          ],
        ),
      ),
    );
  }
}
