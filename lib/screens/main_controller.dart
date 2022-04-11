import 'package:fitness_app/screens/diary.dart';
import 'package:fitness_app/screens/homepage.dart';
import 'package:fitness_app/screens/myinfo.dart';
import 'package:fitness_app/screens/recipes.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class MainController extends StatefulWidget {
  const MainController({Key? key}) : super(key: key);

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  final PageController pageController = PageController();
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness alkalmazás'),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: BuildDrawer(),
      ),
      body: PageView(
          controller: pageController,
          onPageChanged: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [Homepage(), Diary(), Recipes(), Myinfo()]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Kezdőlap"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Napló"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Receptjeim"),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Adataim"),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      pageController.jumpToPage(index);
    }
  }
}
