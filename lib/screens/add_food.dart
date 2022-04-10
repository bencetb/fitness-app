import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/food.dart';

class AddFood extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddFood> {
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final searchController = TextEditingController();

  final List<Food> foodList = [
    Food.named(5, 20, 4, 'Kenyér'),
    Food.named(24, 4, 2, 'Csirkemell'),
    Food.named(5, 12, 3, 'Vörösbab'),
    Food.named(20, 4, 8, 'Marhahús'),
  ];

  List<String> get foodListItems {
    List<String> list = [];
    foodList.forEach((item) {
      list.add(item.name);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Étkezés hozzáadása'),
        centerTitle: true,
      ),
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
                  searchInputDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Keresés',
                  ),
                  onTap: (x) {
                    foodList.forEach((item) {
                      if (item.name == x) {
                        proteinController.text = item.protein.toString();
                        carbsController.text = item.carbs.toString();
                        fatController.text = item.fat.toString();
                      }
                    });
                  },
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Fehérje'),
                controller: proteinController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                //onSubmitted: () {},
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Széndhidrát'),
                controller: carbsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                //onSubmitted: (_) => submitData(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Zsír'),
                controller: fatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                //onSubmitted: (_) => submitData(),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: () {
                    addMeal(
                        double.parse(proteinController.text).round(),
                        double.parse(carbsController.text).round(),
                        double.parse(fatController.text).round());
                    Navigator.pop(context);
                  },
                  child: Text('Hozzáadás'),
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
          "meal": <String, int>{"protein": protein, "carbs": carbs, "fat": fat}
        });
      } else {
        await coll.doc(docId).update({
          "meal": <String, int>{"protein": protein, "carbs": carbs, "fat": fat}
        });
      }
    } catch (e) {
      return;
    }
  }
}
