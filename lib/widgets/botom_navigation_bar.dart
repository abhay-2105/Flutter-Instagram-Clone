import 'package:flutter/material.dart';
import 'package:instagram/models/model.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(this.updateFn, {super.key});

  final void Function(int index) updateFn;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  final List<Map<String, IconData>> _icons = [
    {'unselected': Icons.home_outlined, 'selected': Icons.home},
    {'unselected': Icons.search, 'selected': Icons.search_rounded},
    {'unselected': Icons.favorite_border, 'selected': Icons.favorite},
    {'unselected': Icons.person_outline, 'selected': Icons.person},
  ];
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (value) => setState(
        () {
          _currentIndex = value;
          widget.updateFn(value);
        },
      ),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      currentIndex: _currentIndex,
      items: _icons
          .map((data) => BottomNavigationBarItem(
                label: '',
                icon: Column(
                  children: [
                    Icon(
                      _currentIndex == _icons.indexOf(data)
                          ? data['selected']
                          : data['unselected'],
                      color: Colors.white,
                      size: 31,
                    ),
                    Consumer<CurrentUser>(
                      builder: (context, value, child) => CircleAvatar(
                        backgroundColor:
                            (data['unselected'] == Icons.favorite_border &&
                                    value.notify)
                                ? Colors.red
                                : Colors.black,
                        radius: 3,
                      ),
                    )
                  ],
                ),
              ))
          .toList(),
    );
  }
}
