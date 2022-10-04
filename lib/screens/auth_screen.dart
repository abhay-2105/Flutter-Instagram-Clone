import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/widgets/auth_form.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void _trySubmit(String username, String password, BuildContext ctx) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _auth
          .signInWithEmailAndPassword(
        email: username,
        password: password,
      )
          .whenComplete(() async {
        if (!mounted) return;
        CurrentUser currentUser =
            Provider.of<CurrentUser>(context, listen: false);
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        await SharedPrefs.setUserId(_auth.currentUser!.uid);
        await SharedPrefs.setLogin(true);
        Future.delayed(const Duration(milliseconds: 200)).then((_) async {
          currentUser.setUserId(_auth.currentUser!.uid);
          currentUser.setUsername(userData.data()!['userName']);
          currentUser.setBio(userData.data()!['Bio']);
          currentUser.setProfileImageUrl(userData.data()!['profilePhoto']);
          currentUser.setName(userData.data()!['Accname']);
          currentUser.postCount = userData.data()!['postCount'];
          await SharedPrefs.setUserName(userData.data()!['userName']);
        });
      });
    } on PlatformException catch (err) {
      var message = 'An error Occured,Please check your username and password';
      if (err.message != null) {
        message = err.message!;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(_trySubmit, _isLoading);
  }
}
