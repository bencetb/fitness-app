import 'package:fitness_app/screens/diary.dart';
import 'package:fitness_app/screens/homepage.dart';
import 'package:fitness_app/screens/myinfo.dart';
import 'package:fitness_app/screens/recipes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class MainController extends StatefulWidget {
  const MainController({Key? key}) : super(key: key);

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  String loggedInUsername = "";

  final PageController pageController = PageController();
  int _selectedIndex = 0;
  TextStyle drawerText = const TextStyle(
    fontSize: 18,
  );

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'.tr()),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Builder(builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                  ),
                  child: Text(
                    'loggedIn'.tr() + ': ' + loggedInUsername,
                    style: TextStyle(fontSize: 23, color: Colors.white),
                  ),
                ),
                ListTile(
                  title: Text(' ' + 'language'.tr(),
                      style: TextStyle(fontSize: 20)),
                ),
                ListTile(
                  title: Text(
                    'hun'.tr(),
                    style: (EasyLocalization.of(context)?.locale.toString() ==
                            "hu")
                        ? const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)
                        : const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    EasyLocalization.of(context)?.setLocale(const Locale('hu'));
                  },
                ),
                ListTile(
                  title: Text(
                    'eng'.tr(),
                    style: (EasyLocalization.of(context)?.locale.toString() ==
                            "en")
                        ? const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)
                        : const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    EasyLocalization.of(context)?.setLocale(const Locale('en'));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('logout'.tr(), style: drawerText),
                  onTap: () => {
                    logOut(),
                  },
                ),
              ],
            ),
          );
        }),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr()),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'diary'.tr()),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'recipes'.tr()),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'myinfo'.tr()),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      pageController.jumpToPage(index);
    }
  }

  Future<void> getUserName() async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var data = result.data();
    setState(() {
      loggedInUsername = data!["name"];
    });
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      print('Log out error');
      return;
    }
    Navigator.of(context).pushReplacementNamed('/auth_screen');
  }
}
