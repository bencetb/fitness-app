import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuildDrawer extends StatefulWidget {
  const BuildDrawer({Key? key}) : super(key: key);

  @override
  _BuildDrawerState createState() => _BuildDrawerState();
}

class _BuildDrawerState extends State<BuildDrawer> {
  TextStyle drawerText = const TextStyle(
    fontSize: 18,
  );
  String loggedInUsername = "";

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Bejelentkezve: ' + loggedInUsername,
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
            ),
            ListTile(
              title: Text('Kijelentkezés', style: drawerText),
              onTap: () => {
                logOut(),
              },
            ),
          ],
        ),
      );
    });
  }
}
