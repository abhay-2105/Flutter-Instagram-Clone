import 'package:flutter/material.dart';

class Language extends StatelessWidget {
  const Language({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: const Color.fromARGB(255, 69, 68, 68),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SELECT YOUR LANGUAGE',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const Divider(
                color: Colors.white54,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      size: 31,
                      Icons.search,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      cursorColor: Colors.white,
                      cursorWidth: 0.7,
                      cursorHeight: 25,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.white60,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
