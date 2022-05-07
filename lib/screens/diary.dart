import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  DateTime currentDate = DateTime.now();
  String firstDate = '';

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
                          currentDate = currentDate.subtract(Duration(days: 1));
                          offset--;
                          days--;
                        });
                        getMeals();
                      },
                    ),
              SizedBox(
                width: 15,
              ),
              TextButton(
                child: Text(
                  (EasyLocalization.of(context)?.locale.toString() == "hu")
                      ? DateFormat.yMMMEd('hu').format(currentDate)
                      : DateFormat.yMMMEd().format(currentDate),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                      locale:
                          (EasyLocalization.of(context)?.locale.toString() ==
                                  "hu")
                              ? Locale('hu')
                              : Locale('en'),
                      context: context,
                      initialDate: currentDate,
                      firstDate: DateTime(2022, 4, 1),
                      lastDate: DateTime.now());
                  if (pickedDate != null) {
                    if (int.parse((pickedDate.year.toString() +
                            pickedDate.month.toString() +
                            pickedDate.day.toString())) <
                        int.parse(firstDate)) {
                      Fluttertoast.showToast(
                          msg: 'error'.tr(),
                          backgroundColor: Color.fromARGB(255, 95, 95, 95));
                      return;
                    }
                    days += daysBetween(currentDate, pickedDate);
                    setState(() {
                      currentDate = pickedDate;
                    });
                    getMeals();
                  }
                },
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
                        if (currentDate
                            .add(Duration(days: 1))
                            .isAfter(DateTime.now())) {
                          return;
                        } else {
                          setState(() {
                            currentDate = currentDate.add(Duration(days: 1));
                            offset++;
                            days++;
                          });
                          getMeals();
                        }
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    meals[index].foodName.isNotEmpty
                                        ? meals[index]
                                                .mealType
                                                .tr()
                                                .toUpperCase() +
                                            ' - ' +
                                            meals[index].foodName.toUpperCase()
                                        : meals[index]
                                            .mealType
                                            .tr()
                                            .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),

                                  /*IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: Text(
                                                  'deleteMeal'.tr(),
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('cancel'.tr()),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteMeal(meals[index]);
                                                      Navigator.pop(
                                                          context, 'OK');
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ));
                                    },
                                  ),*/
                                ],
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
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
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
    _isLoading = true;
    var coll = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('meals');

    await coll.get().then((value) {
      days = value.docs.length;
    });
    _isLoading = false;
  }

  Future<void> getMeals() async {
    _isLoading = true;
    docId = currentDate.year.toString() +
        currentDate.month.toString() +
        currentDate.day.toString();
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

      var asd = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('meals')
          .get();

      firstDate = asd.docs.elementAt(0).id;

      if (result.exists == false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('meals')
            .doc(docId)
            .set({});
        days++;
      }

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
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
    _isLoading = false;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /*Future<void> deleteMeal(Meal meal) async {
    _isLoading = true;
    docId = currentDate.year.toString() +
        currentDate.month.toString() +
        currentDate.day.toString();
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('meals')
          .doc(docId)
          .get();

      var data = result.data();

      var nemtom = data!.values.where()
      print(data.values);
    } catch (e) {
      print('ERROR: ' + e.toString());
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
    Fluttertoast.showToast(
        msg: 'mealDeleted'.tr(),
        backgroundColor: Color.fromARGB(255, 95, 95, 95));
    getMeals();
    _isLoading = false;
  }*/
}
