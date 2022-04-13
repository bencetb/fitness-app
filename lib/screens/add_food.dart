import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AddFood extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddFood> {
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final searchController = TextEditingController();

  final List<String> foodList = [];
  List<String> get foodListItems {
    List<String> list = [];
    foodList.forEach((item) {
      list.add(item);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('addFood'.tr()),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popAndPushNamed(context, "/main_controller");
            },
          )),
      body: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: SearchField(
                  controller: searchController,
                  suggestions: foodListItems,
                  //suggestionAction: SuggestionAction.unfocus,
                  searchInputDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'search'.tr(),
                  ),
                  onTap: (x) {},
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'protein'.tr()),
                controller: proteinController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'carbs'.tr()),
                controller: carbsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'fat'.tr()),
                controller: fatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: () {
                    addMeal(
                        double.parse(proteinController.text).round(),
                        double.parse(carbsController.text).round(),
                        double.parse(fatController.text).round());
                    Navigator.popAndPushNamed(context, "/main_controller");
                  },
                  child: Text('add'.tr()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addMeal(int protein, int carbs, int fat) async {
    String docId = DateTime.now().year.toString() +
        DateTime.now().month.toString() +
        DateTime.now().day.toString();
    try {
      var coll = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("meals");
      var doc = await coll.doc(docId).get();

      if (doc.exists == false) {
        await coll.doc(docId).set({});
        await coll.doc(docId).update({
          Uuid().v1(): <String, int>{
            "protein": protein,
            "carbs": carbs,
            "fat": fat
          }
        });
      } else {
        await coll.doc(docId).update({
          Uuid().v1(): <String, int>{
            "protein": protein,
            "carbs": carbs,
            "fat": fat
          }
        });
      }
    } catch (e) {
      print("ERROR: " + e.toString());
      return;
    }
  }
}
