import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

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
              padding: EdgeInsets.only(top: 5, right: 5, left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Color.fromARGB(255, 18, 180, 151),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: CircularPercentIndicator(
                        backgroundColor: Colors.white,
                        radius: 100.0,
                        lineWidth: 13.0,
                        animation: true,
                        percent: caloriesToday / dailyCalorieIntake,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'today'.tr() + ':',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              caloriesToday.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white),
                            ),
                            Text(
                              '\n',
                              style:
                                  TextStyle(fontSize: 7, color: Colors.white),
                            ),
                            Text(
                              'goal'.tr() + ':',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              dailyCalorieIntake.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        footer: Text(
                          ((caloriesToday / dailyCalorieIntake) * 100)
                                  .round()
                                  .toString() +
                              '%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.white),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.lightGreen,
                      ),
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
    String docId = DateTime.now().year.toString() +
        DateTime.now().month.toString() +
        DateTime.now().day.toString();
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      var data = result.data();
      setState(() {
        dailyCalorieIntake = data?['dailyCalorieIntake'];
        protein = data?['protein'];
        fat = data?['fat'];
        carbs = data?['carbs'];
      });

      var coll = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('meals');
      var doc = await coll.doc(docId).get();
      if (doc.exists == false) {
        await coll.doc(docId).set({});
      } else {
        var result2 = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('meals')
            .doc(docId)
            .get();
        var data2 = result2.data();
        int x = data2?.length as int;
        setState(() {
          for (int i = 0; i < x; i++) {
            currentProtein += data2?.values.elementAt(i)['protein'] as int;
            currentFat += data2?.values.elementAt(i)['fat'] as int;
            currentCarbs += data2?.values.elementAt(i)['carbs'] as int;
          }
          caloriesToday +=
              currentCarbs * 4 + currentFat * 9 + currentProtein * 4;
        });
      }
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
    isLoading = false;
  }
}
