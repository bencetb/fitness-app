import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterInfo extends StatefulWidget {
  RegisterInfo({Key? key}) : super(key: key);

  @override
  State<RegisterInfo> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends State<RegisterInfo> {
  int val = 1;
  String selectedValue = "1.2";
  String selectedValue2 = "=";
  String gender = "male";
  String activityLevel = "1.2";
  String goal = "=";
  int dailyCalorieIntake = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;

  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final dobController = TextEditingController();

  Future<void> saveUserDetails(String name, String dob, String gender,
      int height, double weight, String activityLevel, String goal) async {
    int age = calculateAge(dob);
    int g = gender == "male" ? 5 : -161;
    if (goal == "-") {
      dailyCalorieIntake = (((10 * weight + 6.25 * height - 5 * age + g) *
                  double.parse(activityLevel)) *
              0.85)
          .round();
      protein = ((dailyCalorieIntake * 0.4) / 4).round();
      carbs = ((dailyCalorieIntake * 0.4) / 4).round();
      fat = ((dailyCalorieIntake * 0.2) / 9).round();
    } else if (goal == "+") {
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
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      "name": name,
      "height": height,
      "weight": weight,
      "gender": gender,
      "dateOfBirth": dob,
      "age": age,
      "activityLevel": activityLevel,
      "goal": goal,
      "dailyCalorieIntake": dailyCalorieIntake,
      "protein": protein,
      "carbs": carbs,
      "fat": fat
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adatok megadása'),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: ListView(children: [
          Column(
            children: [
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Név'),
                controller: nameController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: RadioListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text("Férfi"),
                        value: 1,
                        groupValue: val,
                        onChanged: (int? value) {
                          setState(() {
                            val = value!;
                            gender = "male";
                          });
                        }),
                  ),
                  Flexible(
                    child: RadioListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text("Nő"),
                        value: 2,
                        groupValue: val,
                        onChanged: (int? value) {
                          setState(() {
                            val = value!;
                            gender = "female";
                          });
                        }),
                  )
                ],
              ),
              TextField(
                decoration:
                    InputDecoration(labelText: 'Születési dátum (éééé-HH-nn)'),
                controller: dobController,
                keyboardType: TextInputType.datetime,
                maxLength: 10,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Magasság (cm)'),
                controller: heightController,
                keyboardType: TextInputType.numberWithOptions(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Testsúly (kg)'),
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Aktivitási szint",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              DropdownButton(
                  value: selectedValue,
                  items: [
                    DropdownMenuItem(
                        child:
                            Text("Alacsony (kevés, vagy semennyi testmozgás)"),
                        value: "1.2"),
                    DropdownMenuItem(
                        child: Text("Könnyű testmozgás/sport 1-3 nap hetente"),
                        value: "1.375"),
                    DropdownMenuItem(
                        child: Text("Közepes testmozgás/sport 3-5 nap hetente"),
                        value: "1.55"),
                    DropdownMenuItem(
                        child: Text("Nehéz testmozgás/sport 6-7 nap hetente"),
                        value: "1.725"),
                    DropdownMenuItem(
                        child: Text("Extrém testmozgás/sport 6-7 nap hetente"),
                        value: "1.9")
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
                  "Cél",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              DropdownButton(
                  value: selectedValue2,
                  items: [
                    DropdownMenuItem(
                        child: Text("Jelenlegi testsúly megtartása"),
                        value: "="),
                    DropdownMenuItem(child: Text("Fogyás"), value: "-"),
                    DropdownMenuItem(child: Text("Tömegnövelés"), value: "+"),
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
                    //_returnHome(context);
                    saveUserDetails(
                        nameController.text,
                        dobController.text,
                        gender,
                        int.parse(heightController.text),
                        double.parse(weightController.text),
                        activityLevel,
                        goal);
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: Text('Mentés'),
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
