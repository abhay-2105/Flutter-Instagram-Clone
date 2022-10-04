import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../widgets/post_content.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  final List<Tab> _tabs = const [
    Tab(
        icon: Icon(
      Icons.grid_on_outlined,
      size: 28,
    )),
    Tab(
        icon: Icon(
      Icons.person_pin_outlined,
      size: 28,
    ))
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: _tabs.length,
      child: NestedScrollView(
          body: PostContent(),
          headerSliverBuilder: (context, isScrolled) {
            return [
              SliverToBoxAdapter(
                child: ProfileHeader(),
              ),
              SliverPinnedHeader(
                child: ColoredBox(
                  color: Colors.black,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    tabs: _tabs,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
              ),
            ];
          }),
    );
  }
}
