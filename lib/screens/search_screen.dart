import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/another_user_profile.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  String prevValue = '';
  late TextEditingController _controller;
  List<QueryDocumentSnapshot> searchList = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()
      ..addListener(() {
        if (_controller.text != prevValue) {
          setState(() {});
          prevValue = _controller.text;
        }
      });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: _controller.text.trim())
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot;
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Accname', isEqualTo: _controller.text.trim())
          .get();
    }
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    cursorWidth: 1,
                    cursorHeight: 20,
                    cursorColor: Colors.grey[300],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 38, 38, 38),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
            body: _controller.text == ""
                ? null
                : FutureBuilder(
                    future: fetchData(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final data = snapshot.data!.docs;
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AnotherUserProfile(
                                            data[index]['userName'],
                                            data[index]['postCount'],
                                            data[index]['profilePhoto'],
                                            data[index]['Accname'],
                                            data[index]['Bio'],
                                            data[index].id,
                                            data[index]['followingCount'],
                                            data[index]['followersCount'],
                                          )),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(
                                    data[index]['profilePhoto'] == ""
                                        ? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'
                                        : data[index]['profilePhoto'],
                                  ),
                                ),
                                title: Text(
                                  data[index]['userName'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  data[index]['Accname'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          });
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
