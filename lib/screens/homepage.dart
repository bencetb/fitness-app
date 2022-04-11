import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int dailyCalorieIntake = 0;
  int caloriesToday = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;
  int currentProtein = 0;
  int currentCarbs = 0;
  int currentFat = 0;
  bool isLoading = true;

  @override
  void initState() {
    getUserDetailsAndMeals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/add_food'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> getUserDetailsAndMeals() async {
    try {
      var result = await FirebaseFirestore.instance
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

      String docId = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString();

      var coll = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("meals");
      var doc = await coll.doc(docId).get();
      if (doc.exists == false) {
        await coll.doc(docId).set({});
      } else {
        var result2 = await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("meals")
            .doc(docId)
            .get();
        var data2 = result2.data();
        int x = data2?.length as int;
        setState(() {
          for (int i = 0; i < x; i++) {
            currentProtein += data2?.values.elementAt(i)["protein"] as int;
            currentFat += data2?.values.elementAt(i)["fat"] as int;
            currentCarbs += data2?.values.elementAt(i)["carbs"] as int;
          }
          caloriesToday +=
              currentCarbs * 4 + currentFat * 9 + currentProtein * 4;
        });
      }
    } catch (e) {
      print("ERROR: " + e.toString());
      return;
    }
    isLoading = false;
  }
}
