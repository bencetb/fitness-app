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
  double caloriesToday = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;
  double currentProtein = 0;
  double currentCarbs = 0;
  double currentFat = 0;
  bool isLoading = false;
  double caloriesPercent = 0.0;
  double proteinPercent = 0.0;
  double carbsPercent = 0.0;
  double fatPercent = 0.0;

  @override
  void initState() {
    getUserDetailsAndMeals();
    isLoading = true;
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
              padding: EdgeInsets.only(top: 3, right: 1, left: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.teal,
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 13, bottom: 11),
                      child: Column(
                        children: [
                          (EasyLocalization.of(context)?.locale.toString() ==
                                  "hu")
                              ? Text(
                                  DateFormat.yMMMEd('hu')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  DateFormat.yMMMEd().format(DateTime.now()),
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                          SizedBox(
                            height: 13,
                          ),
                          CircularPercentIndicator(
                            backgroundColor: Color.fromARGB(40, 255, 255, 255),
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: caloriesPercent,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  caloriesToday.round().toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.white),
                                ),
                                Divider(
                                  thickness: 4,
                                  indent: 55,
                                  endIndent: 55,
                                  color: Color.fromARGB(40, 255, 255, 255),
                                ),
                                Text(
                                  dailyCalorieIntake.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.white),
                                ),
                                Text(
                                  'kcal',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                            footer: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                ((caloriesToday / dailyCalorieIntake) * 100)
                                        .round()
                                        .toString() +
                                    '%',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.0,
                                    color: Colors.white),
                              ),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.white,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 75,
                                child: Column(
                                  children: [
                                    Text(
                                      'protein'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(height: 2),
                                    LinearPercentIndicator(
                                      alignment: MainAxisAlignment.center,
                                      width: 65.0,
                                      lineHeight: 4.5,
                                      percent: proteinPercent,
                                      progressColor: Colors.white,
                                      backgroundColor:
                                          Color.fromARGB(40, 255, 255, 255),
                                      animation: true,
                                      barRadius: Radius.circular(8),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      currentProtein.round().toString() +
                                          ' / ' +
                                          protein.toString() +
                                          ' g',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80,
                                child: Column(
                                  children: [
                                    Text(
                                      'carbs'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(height: 2),
                                    LinearPercentIndicator(
                                      alignment: MainAxisAlignment.center,
                                      width: 65.0,
                                      lineHeight: 4.5,
                                      percent: carbsPercent,
                                      progressColor: Colors.white,
                                      backgroundColor:
                                          Color.fromARGB(40, 255, 255, 255),
                                      animation: true,
                                      barRadius: Radius.circular(8),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      currentCarbs.round().toString() +
                                          ' / ' +
                                          carbs.toString() +
                                          ' g',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 75,
                                child: Column(
                                  children: [
                                    Text(
                                      'fat'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(height: 2),
                                    LinearPercentIndicator(
                                      alignment: MainAxisAlignment.center,
                                      width: 65.0,
                                      lineHeight: 4.5,
                                      percent: fatPercent,
                                      progressColor: Colors.white,
                                      backgroundColor:
                                          Color.fromARGB(40, 255, 255, 255),
                                      animation: true,
                                      barRadius: Radius.circular(8),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      currentFat.round().toString() +
                                          ' / ' +
                                          fat.toString() +
                                          ' g',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/add_meal'),
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
            currentProtein += data2?.values.elementAt(i)['protein'];
            currentFat += data2?.values.elementAt(i)['fat'];
            currentCarbs += data2?.values.elementAt(i)['carbs'];
          }
          caloriesToday +=
              currentCarbs * 4 + currentFat * 9 + currentProtein * 4;

          caloriesPercent = caloriesToday / dailyCalorieIntake;
          if (caloriesPercent > 1.0) caloriesPercent = 1.0;

          proteinPercent = currentProtein / protein;
          if (proteinPercent > 1.0) proteinPercent = 1.0;

          carbsPercent = currentCarbs / carbs;
          if (carbsPercent > 1.0) carbsPercent = 1.0;

          fatPercent = currentFat / fat;
          if (fatPercent > 1.0) fatPercent = 1.0;
        });
      }
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
    isLoading = false;
  }
}
