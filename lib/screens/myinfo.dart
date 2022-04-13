import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

class Myinfo extends StatefulWidget {
  @override
  State<Myinfo> createState() => _MyinfoState();
}

class _MyinfoState extends State<Myinfo> {
  String activityLevel = '1.2';
  String goal = '+';
  String dob = '';
  int height = 0;
  double weight = 0;
  String gender = '';

  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController dobController;

  bool isLoading = true;

  Future<void> getUserDetails() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var data = result.data();
    setState(() {
      activityLevel = data?['activityLevel'];
      goal = data?['goal'];
      dob = data?['dateOfBirth'];
      height = data?['height'] as int;
      weight = data?['weight'] as double;
      gender = data?['gender'];
      heightController = TextEditingController(text: height.toString());
      weightController = TextEditingController(text: weight.toString());
      dobController = TextEditingController(text: dob);
    });
    isLoading = false;
  }

  Future<void> saveUserDetails(String dob, int height, double weight,
      String activityLevel, String goal) async {
    int age = calculateAge(dob);
    int g = gender == 'male' ? 5 : -161;
    double gm = gender == 'male' ? 0.85 : 0.9;
    int dailyCalorieIntake = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;
    if (goal == '-') {
      dailyCalorieIntake = (((10 * weight + 6.25 * height - 5 * age + g) *
                  double.parse(activityLevel)) *
              gm)
          .round();
      protein = ((dailyCalorieIntake * 0.4) / 4).round();
      carbs = ((dailyCalorieIntake * 0.4) / 4).round();
      fat = ((dailyCalorieIntake * 0.2) / 9).round();
    } else if (goal == '+') {
      dailyCalorieIntake = (((10 * weight + 6.25 * height - 5 * age + g) *
                  double.parse(activityLevel)) +
              500)
          .round();
      protein = ((dailyCalorieIntake * 0.3) / 4).round();
      carbs = ((dailyCalorieIntake * 0.4) / 4).round();
      fat = ((dailyCalorieIntake * 0.3) / 9).round();
    } else {
      dailyCalorieIntake = ((10 * weight + 6.25 * height - 5 * age + g) *
              double.parse(activityLevel))
          .round();
      protein = ((dailyCalorieIntake * 0.3) / 4).round();
      carbs = ((dailyCalorieIntake * 0.4) / 4).round();
      fat = ((dailyCalorieIntake * 0.3) / 9).round();
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'height': height,
        'weight': weight,
        'dateOfBirth': dob,
        'age': age,
        'activityLevel': activityLevel,
        'goal': goal,
        'dailyCalorieIntake': dailyCalorieIntake,
        'protein': protein,
        'carbs': carbs,
        'fat': fat
      });
    } catch (e) {
      return;
    }
    Fluttertoast.showToast(
        msg: 'infoModified'.tr(),
        backgroundColor: Color.fromARGB(255, 95, 95, 95));
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              child: ListView(children: [
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'dateOfBirth'.tr()),
                      controller: dobController,
                      keyboardType: TextInputType.datetime,
                      maxLength: 10,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'height'.tr()),
                      controller: heightController,
                      keyboardType: TextInputType.numberWithOptions(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'weight'.tr()),
                      controller: weightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'activityLevel'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    DropdownButton(
                        value: activityLevel,
                        items: [
                          DropdownMenuItem(
                              child: Text('activ1'.tr()), value: '1.2'),
                          DropdownMenuItem(
                              child: Text('activ2'.tr()), value: '1.375'),
                          DropdownMenuItem(
                              child: Text('activ3'.tr()), value: '1.55'),
                          DropdownMenuItem(
                              child: Text('activ4'.tr()), value: '1.725'),
                          DropdownMenuItem(
                              child: Text('activ5'.tr()), value: '1.9')
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            activityLevel = newValue!;
                          });
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'goal'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    DropdownButton(
                        value: goal,
                        items: [
                          DropdownMenuItem(
                              child: Text('maintainWeight'.tr()), value: '='),
                          DropdownMenuItem(
                              child: Text('loseWeight'.tr()), value: '-'),
                          DropdownMenuItem(
                              child: Text('gainWeight'.tr()), value: '+'),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            goal = newValue!;
                          });
                        }),
                    Container(
                      padding: EdgeInsets.only(top: 35),
                      child: ElevatedButton(
                        onPressed: () {
                          saveUserDetails(
                              dobController.text,
                              int.parse(heightController.text),
                              double.parse(weightController.text),
                              activityLevel,
                              goal);
                        },
                        child: Text('save'.tr()),
                      ),
                    )
                  ],
                ),
              ]),
            ),
    );
  }

  int calculateAge(String dob) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - int.parse(dob.substring(0, 4));
    int month1 = currentDate.month;
    int month2 = int.parse(dob.substring(5, 7));
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      if (int.parse(dob.substring(8, 10)) > currentDate.day) age--;
    }
    return age;
  }
}
