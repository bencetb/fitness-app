import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/drawer.dart';
import '../model/food.dart';
import 'add_food.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Food food;
  int dailyCalorieIntake = 0;
  int caloriesToday = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;
  bool isLoading = true;

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness alkalmazás'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: BuildDrawer(),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Ma:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    caloriesToday.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    'Kalória\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Cél:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    dailyCalorieIntake.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add_food'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> getUserDetails() async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var data = result.data();
    setState(() {
      dailyCalorieIntake = data?["dailyCalorieIntake"];
      protein = data?["protein"];
      fat = data?["fat"];
      carbs = data?["carbs"];
    });
    isLoading = false;
  }
}
