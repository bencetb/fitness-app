import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/meal.dart';

class Diary extends StatefulWidget {
  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  bool _isLoading = false;
  int offset = 0;
  String docId = '';
  List<Meal> meals = [];
  dynamic calories = 0.0;
  dynamic protein = 0.0;
  dynamic carbs = 0.0;
  dynamic fat = 0.0;
  String foodName = '';
  int days = 0;

  @override
  void initState() {
    getMeals();
    getDays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading || days == 1
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {},
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          offset--;
                          days--;
                        });
                        getMeals();
                        _isLoading = true;
                      },
                    ),
              SizedBox(
                width: 15,
              ),
              (EasyLocalization.of(context)?.locale.toString() == "hu")
                  ? Text(
                      DateFormat.yMMMEd('hu')
                          .format(DateTime.now().add(Duration(days: offset))),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    )
                  : Text(
                      DateFormat.yMMMEd()
                          .format(DateTime.now().add(Duration(days: offset))),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
              SizedBox(
                width: 15,
              ),
              _isLoading
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {},
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (DateTime.now().isBefore(
                            DateTime.now().add(Duration(days: offset)))) {
                          return;
                        }
                        setState(() {
                          offset++;
                          days++;
                        });
                        getMeals();
                        _isLoading = true;
                      },
                    ),
            ],
          ),
          Card(
            color: Colors.teal,
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 11, top: 13),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 70.0,
                    lineWidth: 8,
                    percent: 1.0,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          calories.round().toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(fontSize: 19, color: Colors.white),
                        ),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.white,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        child: Column(
                          children: [
                            Text(
                              protein.round().toString() +
                                  'g\n' +
                                  'protein'.tr(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 75,
                        child: Column(
                          children: [
                            Text(
                              carbs.round().toString() + 'g\n' + 'carbs'.tr(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        child: Column(
                          children: [
                            Text(
                              fat.round().toString() + 'g\n' + 'fat'.tr(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Color.fromARGB(255, 18, 180, 151),
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                meals[index].foodName.isNotEmpty
                                    ? meals[index].mealType.tr().toUpperCase() +
                                        ' - ' +
                                        meals[index].foodName.toUpperCase()
                                    : meals[index].mealType.tr().toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        meals[index]
                                                .calories
                                                .round()
                                                .toString() +
                                            '\n' +
                                            'kcal',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        meals[index]
                                                .protein
                                                .round()
                                                .toString() +
                                            'g\n' +
                                            'protein'.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        meals[index].carbs.round().toString() +
                                            'g\n' +
                                            'carbs'.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        meals[index].fat.round().toString() +
                                            'g\n' +
                                            'fat'.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }

  Future<void> getDays() async {
    try {
      var coll = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('meals');

      await coll.get().then((value) {
        days = value.docs.length;
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
  }

  Future<void> getMeals() async {
    docId = DateTime.now().add(Duration(days: offset)).year.toString() +
        DateTime.now().add(Duration(days: offset)).month.toString() +
        DateTime.now().add(Duration(days: offset)).day.toString();
    meals = [];
    calories = 0.0;
    protein = 0.0;
    carbs = 0.0;
    fat = 0.0;
    String mealType = '';
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('meals')
          .doc(docId)
          .get();

      var data = result.data();
      int mealCount = data?.length as int;
      setState(() {
        for (int i = 0; i < mealCount; i++) {
          if (data?.values.elementAt(i)['mealType'] != null) {
            mealType = data?.values.elementAt(i)['mealType'];
          }
          meals.add(Meal(
            mealType,
            data?.values.elementAt(i)['protein'],
            data?.values.elementAt(i)['carbs'],
            data?.values.elementAt(i)['fat'],
            data?.values.elementAt(i)['foodName'],
          ));
          protein += data?.values.elementAt(i)['protein'];
          fat += data?.values.elementAt(i)['fat'];
          carbs += data?.values.elementAt(i)['carbs'];
        }
        calories += carbs * 4 + fat * 9 + protein * 4;
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
    _isLoading = false;
  }
}
