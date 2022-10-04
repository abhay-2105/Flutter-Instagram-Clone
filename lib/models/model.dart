import 'package:flutter/material.dart';

class CurrentUser extends ChangeNotifier {
  String? userId;
  String? profileImageUrl;
  String? name;
  String? username;
  String? bio;
  int? postCount;
  bool notify = false;

  void setProfileImageUrl(String? path) {
    profileImageUrl = path;
    notifyListeners();
  }

  void setUserId(String id) {
    userId = id;
  }

  void setName(String? accName) {
    name = accName;
    notifyListeners();
  }

  void setUsername(String userName) {
    username = userName;
    notifyListeners();
  }

  void setBio(String? accbio) {
    bio = accbio;
    notifyListeners();
  }

  void setNotify(bool val) {
    notify = val;
    notifyListeners();
  }

  void tellListener() {
    notifyListeners();
  }
}
