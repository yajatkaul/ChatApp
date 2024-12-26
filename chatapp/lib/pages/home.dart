import 'package:chatapp/pages/navBar/chat/chat.dart';
import 'package:chatapp/pages/navBar/home.dart';
import 'package:chatapp/pages/navBar/profile.dart';
import 'package:chatapp/pages/navBar/search.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [
    const Home(),
    const Search(),
    const Chat(),
    const Profile()
  ];

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        controller: _pageController,
        children: pages,
      ),
      bottomNavigationBar: GNav(
          haptic: true,
          onTabChange: (index) {
            setState(() {
              _currentPage = index;
              _pageController.animateToPage(_currentPage,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear);
            });
          },
          selectedIndex: _currentPage,
          tabs: const [
            GButton(
              icon: LineIcons.home,
              text: 'Home',
            ),
            GButton(
              icon: LineIcons.search,
              text: 'Search',
            ),
            GButton(
              icon: LineIcons.facebookMessenger,
              iconSize: 30,
              text: 'DM',
            ),
            GButton(
              icon: LineIcons.user,
              text: 'Profile',
            )
          ]),
    );
  }
}
