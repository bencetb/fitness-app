import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class Diary extends StatefulWidget {
  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  bool _isLoading = false;
  DateTime date = DateTime.now();
  int mealCount = 1;
  int offset = 0;
  String docId = "";
  List<String> meals = [""];

  @override
  void initState() {
    //getUserDetailsAndMeals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            offset--;
                          });
                        },
                      ),
                      Text(
                        DateFormat.yMMMEd()
                            .format(DateTime.now().add(Duration(days: offset))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            offset++;
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: mealCount,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(meals[index]),
                          );
                        }),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: getUserDetailsAndMeals,
                      child: Text('Load'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> getUserDetailsAndMeals() async {
    _isLoading = true;
    docId = DateTime.now().add(Duration(days: offset)).year.toString() +
        DateTime.now().add(Duration(days: offset)).month.toString() +
        DateTime.now().add(Duration(days: offset)).day.toString();
    try {
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
        mealCount = data2?.length as int;
        setState(() {
          for (int i = 0; i < mealCount; i++) {
            meals.add(
                data2?.values.elementAt(i)['protein'].toString() as String);
          }
        });
      }
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
    _isLoading = false;
  }
}
