import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:instagram/models/shared_prefs.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/loading_screen.dart';
import 'package:instagram/screens/notification_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/widgets/appbar.dart';
import 'package:provider/provider.dart';
import '../widgets/botom_navigation_bar.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  bool isLoading = false;
  int _currentIndex = 0;
  late final userId;

  @override
  void initState() {
    super.initState();
    userId = SharedPrefs.getUserId();
    if (userId != null) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    currentUser.setUserId(userId);
    currentUser.username = (userData.data()!['userName']);
    currentUser.bio = (userData.data()!['Bio']);
    currentUser.profileImageUrl = (userData.data()!['profilePhoto']);
    await SharedPrefs.setProfileUrl(userData.data()!['profilePhoto']);
    currentUser.name = (userData.data()!['Accname']);
    currentUser.postCount = (userData.data()!['postCount']);
    setState(() {
      isLoading = false;
    });
  }

  void updateIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  bool checkScaffoldBehindAppbar(int index) {
    if (index == 1 || index == 2) {
      return true;
    }
    return false;
  }

  final List<Widget> _screens = [
    FutureBuilder(
        future: FirebaseFirestore.instance.collectionGroup('posts').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const LoadingScreen();
          }
          final snapData = snapshot.data!.docs;
          snapData.sort((a, b) => b['Time'].compareTo(a['Time']));
          return HomeScreen(snapData);
        }),
    const SearchUser(),
    StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(SharedPrefs.getUserId())
          .collection('posts')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const LoadingScreen();
        }
        final postDocs = snapshot.data!.docs;
        // Provider.of<CurrentUser>(context).notify = true;
        // Provider.of<CurrentUser>(context, listen: false).setNotify(true);
        List<dynamic> likedData = [];
        Map<List, String> imageUrl = {};
        List<String> likedUsersUserId = [];
        for (int i = 0; i < postDocs.length; i++) {
          likedUsersUserId = postDocs[i]['likedUsers'].keys.toList();
          List<dynamic> likedUsersData =
              postDocs[i]['likedUsers'].values.toList();
          for (int j = 0; j < likedUsersData.length; j++) {
            if (SharedPrefs.getUserId() != likedUsersUserId[j]) {
              imageUrl[likedUsersData[j]] = postDocs[i]['imageUrl'];
              likedData.add(likedUsersData[j]);
            }
          }
        }
        likedData.sort((a, b) => b[1].compareTo(a[1]));
        print(likedData);
        return NotifiationScreen(
          likedData,
          imageUrl,
        );
      },
    ),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: checkScaffoldBehindAppbar(_currentIndex),
        appBar: (isLoading || _currentIndex == 1)
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Appbars(_currentIndex)),
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavBar(updateIndex),
        body: isLoading ? const LoadingScreen() : _screens[_currentIndex]);
  }
}
