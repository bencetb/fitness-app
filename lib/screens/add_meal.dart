import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/recipe.dart';
import '../models/ingredient.dart';

class AddMeal extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddMeal> {
  final _formKey = GlobalKey<FormState>();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final searchController = TextEditingController();
  final foodNameController = TextEditingController();
  final recipeScrollController = ScrollController();
  final searchScrollController = ScrollController();
  final amountController = TextEditingController();
  double protein = 0.0;
  double carbs = 0.0;
  double fat = 0.0;
  String foodName = '';
  String mealType = 'Breakfast';
  List<Recipe> recipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    getRecipes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('addFood'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/main_controller');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.book),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                        title: Center(child: Text('recipes2'.tr())),
                        children: [
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Container(
                                  height: height - 400,
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Scrollbar(
                                    controller: recipeScrollController,
                                    isAlwaysShown: true,
                                    child: ListView.builder(
                                        controller: recipeScrollController,
                                        itemCount: recipes.length,
                                        itemBuilder: ((context, index) {
                                          return ListTile(
                                            title: Text(recipes[index].name),
                                            onTap: () => {
                                              proteinController.text =
                                                  recipes[index]
                                                      .protein
                                                      .toString(),
                                              carbsController.text =
                                                  recipes[index]
                                                      .carbs
                                                      .toString(),
                                              fatController.text =
                                                  recipes[index].fat.toString(),
                                              foodNameController.text =
                                                  recipes[index].name,
                                              Navigator.pop(context)
                                            },
                                          );
                                        })),
                                  ),
                                ),
                        ]);
                  });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                foodName = searchController.text.toLowerCase().trim();
                amountController.text = '';
                if (proteinController.text.isEmpty) protein = 0;
                if (carbsController.text.isEmpty) carbs = 0;
                if (fatController.text.isEmpty) fat = 0;
              });
              searchController.text.isEmpty
                  ? Fluttertoast.showToast(
                      msg: 'searchEmpty'.tr(),
                      backgroundColor: Color.fromARGB(255, 95, 95, 95))
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: TextFormField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        controller: amountController,
                                        decoration: InputDecoration(
                                            labelText: 'amount'.tr()),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'enterAmount'.tr();
                                          }
                                        }),
                                  ),
                                  Container(
                                    height: height - 350,
                                    width: double.maxFinite,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('foods')
                                          .where("nameSearchField",
                                              arrayContains: foodName)
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          default:
                                            return Scrollbar(
                                              controller:
                                                  searchScrollController,
                                              isAlwaysShown: true,
                                              child: ListView(
                                                controller:
                                                    searchScrollController,
                                                children: snapshot.data!.docs
                                                    .map((DocumentSnapshot
                                                        document) {
                                                  return ListTile(
                                                    title: Text(
                                                      document['foodName'],
                                                    ),
                                                    onTap: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        protein += document[
                                                                'protein'] *
                                                            int.parse(
                                                                amountController
                                                                    .text) *
                                                            0.01;
                                                        carbs += document[
                                                                'carbs'] *
                                                            int.parse(
                                                                amountController
                                                                    .text) *
                                                            0.01;
                                                        fat += document['fat'] *
                                                            int.parse(
                                                                amountController
                                                                    .text) *
                                                            0.01;
                                                        proteinController.text =
                                                            protein
                                                                .toStringAsFixed(
                                                                    2);
                                                        carbsController.text =
                                                            carbs
                                                                .toStringAsFixed(
                                                                    2);
                                                        fatController.text = fat
                                                            .toStringAsFixed(2);
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'search'.tr()),
                  ),
                ),
                DropdownButton(
                    value: mealType,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                          child: Text('Breakfast'.tr()), value: 'Breakfast'),
                      DropdownMenuItem(
                          child: Text('Lunch'.tr()), value: 'Lunch'),
                      DropdownMenuItem(
                          child: Text('Dinner'.tr()), value: 'Dinner'),
                      DropdownMenuItem(
                          child: Text('Snack'.tr()), value: 'Snack')
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        mealType = newValue!;
                      });
                    }),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'protein'.tr() + ' (g)'),
                  controller: proteinController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'carbs'.tr() + ' (g)'),
                  controller: carbsController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'fat'.tr() + ' (g)'),
                  controller: fatController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'foodName'.tr()),
                  controller: foodNameController,
                ),
                Container(
                  padding: EdgeInsets.only(top: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      addMeal(
                          double.parse(proteinController.text),
                          double.parse(carbsController.text),
                          double.parse(fatController.text),
                          foodNameController.text);
                      Navigator.popAndPushNamed(context, '/main_controller');
                    },
                    child: Text('add'.tr()),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addMeal(
      double protein, double carbs, double fat, String foodName) async {
    String docId = DateTime.now().year.toString() +
        DateTime.now().month.toString() +
        DateTime.now().day.toString();
    try {
      var coll = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('meals');
      var doc = await coll.doc(docId).get();

      if (doc.exists == false) {
        await coll.doc(docId).set({});
      } else {
        await coll.doc(docId).update({
          Uuid().v1(): <String, dynamic>{
            'mealType': mealType,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'foodName': foodName,
          }
        });
      }
    } catch (e) {
      print('ERROR: ' + e.toString());
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
  }

  Future<void> getRecipes() async {
    _isLoading = true;
    recipes = [];
    List<Ingredient> ings = [];
    int numOfRecipes;

    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('recipes')
        .get()
        .then((value) {
      numOfRecipes = value.docs.length;

      for (int i = 0; i < numOfRecipes; i++) {
        int ingredientCount = value.docs.elementAt(i).data().length;

        for (int j = 0; j < ingredientCount; j++) {
          String key = value.docs.elementAt(i).data().entries.elementAt(j).key;
          if (key != 'carbs' &&
              key != 'protein' &&
              key != 'fat' &&
              key != 'calories') {
            ings.add(Ingredient(
                value.docs.elementAt(i).data().entries.elementAt(j).key,
                value.docs
                    .elementAt(i)
                    .data()
                    .entries
                    .elementAt(j)
                    .value['amount'],
                value.docs
                    .elementAt(i)
                    .data()
                    .entries
                    .elementAt(j)
                    .value['protein'],
                value.docs
                    .elementAt(i)
                    .data()
                    .entries
                    .elementAt(j)
                    .value['carbs'],
                value.docs
                    .elementAt(i)
                    .data()
                    .entries
                    .elementAt(j)
                    .value['fat']));
          }
        }
        recipes.add(Recipe(
            value.docs.elementAt(i).id,
            value.docs.elementAt(i).data()['protein'],
            value.docs.elementAt(i).data()['carbs'],
            value.docs.elementAt(i).data()['fat'],
            value.docs.elementAt(i).data()['calories'],
            ings));
        ings = [];
      }
    });

    setState(() {
      _isLoading = false;
    });
  }
}
