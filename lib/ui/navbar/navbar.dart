import 'package:flutter/material.dart';
import 'package:fourleggedlove/ui/auth/edit_profile.dart';
import 'package:fourleggedlove/ui/home/homescreen.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final Common _common = Common();
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _common.background,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: _common.purple,
              hoverColor: _common.purple,
              gap: 8,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              color: _common.purple,
              haptic: true,
              activeColor: _common.purple,
              tabBackgroundColor: Color(0xff31343c),
              tabs: [
                GButton(
                  icon: LineIcons.podcast,
                  text: 'Feed',
                  iconColor: _common.purple,
                  textColor: _common.purple,
                ),
                GButton(
                  icon: LineIcons.edit,
                  text: 'Profile',
                  iconColor: _common.purple,
                  textColor: _common.purple,
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                setState(() => selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    EditProfile(),
  ];
}
