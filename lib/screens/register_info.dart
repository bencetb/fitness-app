import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterInfo extends StatefulWidget {
  RegisterInfo({Key? key}) : super(key: key);

  @override
  State<RegisterInfo> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends State<RegisterInfo> {
  final _formKey = GlobalKey<FormState>();
  int val = 1;
  String selectedValue = '1.2';
  String selectedValue2 = '=';
  String gender = 'male';
  String activityLevel = '1.2';
  String goal = '=';
  int dailyCalorieIntake = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;

  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('enterInfo'.tr()),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'name'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'required'.tr();
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: Text('male'.tr()),
                          value: 1,
                          groupValue: val,
                          onChanged: (int? value) {
                            setState(() {
                              val = value!;
                              gender = 'male';
                            });
                          }),
                    ),
                    Flexible(
                      child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: Text('female'.tr()),
                          value: 2,
                          groupValue: val,
                          onChanged: (int? value) {
                            setState(() {
                              val = value!;
                              gender = 'female';
                            });
                          }),
                    )
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'dateOfBirth'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  controller: dobController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                        locale:
                            (EasyLocalization.of(context)?.locale.toString() ==
                                        "hu" ||
                                    EasyLocalization.of(context)
                                            ?.locale
                                            .toString() ==
                                        "hu_HU")
                                ? Locale('hu')
                                : Locale('en'),
                        context: context,
                        initialDate: DateTime(2010),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2010));
                    if (pickedDate != null) {
                      setState(() {
                        dobController.text =
                            DateFormat("yyyy-MM-dd").format(pickedDate);
                      });
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'required'.tr();
                    }
                  },
                ),
                SizedBox(
                  height: 7,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'height'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  controller: heightController,
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'required'.tr();
                    }
                  },
                ),
                SizedBox(
                  height: 7,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'weight'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'required'.tr();
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'activityLevel'.tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                DropdownButton(
                    value: selectedValue,
                    items: [
                      DropdownMenuItem(
                          child: Text('activ1'.tr()), value: '1.2'),
                      DropdownMenuItem(
                          child: Text('activ2'.tr()), value: '1.375'),
                      DropdownMenuItem(
                          child: Text('activ3'.tr()), value: '1.55'),
                      DropdownMenuItem(
                          child: Text('activ4'.tr()), value: '1.725'),
                      DropdownMenuItem(child: Text('activ5'.tr()), value: '1.9')
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                        activityLevel = selectedValue;
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
                    value: selectedValue2,
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
                        selectedValue2 = newValue!;
                        goal = selectedValue2;
                      });
                    }),
                Container(
                  padding: EdgeInsets.only(top: 35),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveUserDetails(
                            nameController.text,
                            dobController.text,
                            gender,
                            int.parse(heightController.text),
                            double.parse(weightController.text),
                            activityLevel,
                            goal);
                        Navigator.of(context)
                            .pushReplacementNamed('/main_controller');
                      }
                    },
                    child: Text('save'.tr()),
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> saveUserDetails(String name, String dob, String gender,
      int height, double weight, String activityLevel, String goal) async {
    int age = calculateAge(dob);
    int g = gender == 'male' ? 5 : -161;
    if (goal == '-') {
      dailyCalorieIntake = (((10 * weight + 6.25 * height - 5 * age + g) *
                  double.parse(activityLevel)) *
              0.85)
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      'name': name,
      'height': height,
      'weight': weight,
      'gender': gender,
      'dateOfBirth': dob,
      'age': age,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieIntake': dailyCalorieIntake,
      'protein': protein,
      'carbs': carbs,
      'fat': fat
    });
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
