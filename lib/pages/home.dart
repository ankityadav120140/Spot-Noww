// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:spot_noww/pages/homePage.dart';
import 'package:spot_noww/pages/profile.dart';
import 'package:spot_noww/utilities/global.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool? registered = preferences.getBool("registered");
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    ProfilePage(),
    // PartnerSearchPage(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      //  PageView(
      //   children: _screens,
      //   onPageChanged: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
