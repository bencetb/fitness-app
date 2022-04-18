import 'package:fitness_app/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AddMeal extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddMeal> {
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final searchController = TextEditingController();
  final foodNameController = TextEditingController();
  final recipeScrollController = ScrollController();
  final searchScrollController = ScrollController();
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
                                  height: height - 500,
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
              onPressed: () {
                setState(() {
                  foodName = searchController.text.toLowerCase().trim();
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: Text('chooseFood'.tr())),
                        contentPadding: EdgeInsets.only(top: 10),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: height - 430,
                              width: double.maxFinite,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('foods')
                                    .where("nameSearchField",
                                        arrayContains: foodName)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    default:
                                      return Scrollbar(
                                        controller: searchScrollController,
                                        isAlwaysShown: true,
                                        child: ListView(
                                          controller: searchScrollController,
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            return ListTile(
                                              title: Text(
                                                document['foodName'],
                                              ),
                                              onTap: () {
                                                protein += document['protein'];
                                                carbs += document['carbs'];
                                                fat += document['fat'];
                                                proteinController.text =
                                                    protein.toString();
                                                carbsController.text =
                                                    carbs.toString();
                                                fatController.text =
                                                    fat.toString();
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
                      );
                    });
              },
              icon: Icon(Icons.search))
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
      return;
    }
  }

  Future<void> getRecipes() async {
    //_isLoading = true;
    recipes = [];
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('recipes')
          .doc('recipes')
          .get();

      var data = result.data();
      int recipeCount = data?.length as int;
      setState(() {
        for (int i = 0; i < recipeCount; i++) {
          recipes.add(Recipe(
            data?.values.elementAt(i)['name'] as String,
            data?.values.elementAt(i)['protein'],
            data?.values.elementAt(i)['carbs'],
            data?.values.elementAt(i)['fat'],
          ));
        }
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
    _isLoading = false;
  }
}
