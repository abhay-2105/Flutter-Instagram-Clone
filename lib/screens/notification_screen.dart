import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:provider/provider.dart';

class NotifiationScreen extends StatefulWidget {
  final Map imageUrl;
  final List<dynamic> likedData;
  const NotifiationScreen(this.likedData, this.imageUrl, {super.key});

  @override
  State<NotifiationScreen> createState() => _NotifiationScreenState();
}

class _NotifiationScreenState extends State<NotifiationScreen> {
  String getTime(currentTime) {
    if ((DateTime.now().difference(currentTime)).inSeconds < 60) {
      return '${((DateTime.now().difference(currentTime)).inSeconds)} sec. ago';
    } else if ((DateTime.now().difference(currentTime)).inMinutes < 60) {
      return '${((DateTime.now().difference(currentTime)).inMinutes)} min. ago';
    } else if ((DateTime.now().difference(currentTime)).inHours < 25) {
      return '${((DateTime.now().difference(currentTime)).inHours)} hours ago';
    }
    return '${((DateTime.now().difference(currentTime)).inDays)} days ago';
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CurrentUser>(context, listen: false).setNotify(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('favourites'),
      itemCount: widget.likedData.length,
      itemBuilder: (context, index) {
        final time = getTime((widget.likedData[index][1]).toDate());
        return ListTile(
          leading: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.likedData[index][2])
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                      ));
                }
                final data = snapshot.data!['profilePhoto'];
                return CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(data ??
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'));
              }),
          trailing: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        widget.imageUrl[widget.likedData[index]]!))),
          ),
          subtitle: Text(
            time,
            style:
                TextStyle(color: Colors.grey[200], fontWeight: FontWeight.w400),
          ),
          title: Row(
            children: [
              Text(
                (widget.likedData[index][0]).toString(),
                style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.w600),
              ),
              const Text(
                ' liked your photo',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        );
      },
    );
  }
}
