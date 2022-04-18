import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Recipes extends StatefulWidget {
  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final nameController = TextEditingController();
  bool _isLoading = false;

  List<Recipe> recipes = [];

  @override
  void initState() {
    getRecipes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(recipes[index].name.toString()),
                );
              })),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Új recept',
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.add))
              ],
            ),
            content: Container(
              height: 300,
              width: double.maxFinite,
              child: Form(
                  child: ListView(children: [
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Név'),
                      controller: nameController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'protein'.tr()),
                      controller: proteinController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'carbs'.tr()),
                      controller: carbsController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'fat'.tr()),
                      controller: fatController,
                    ),
                  ],
                ),
              ])),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    addRecipe(
                        nameController.text,
                        int.parse(proteinController.text),
                        int.parse(carbsController.text),
                        int.parse(fatController.text));
                  });
                  Navigator.pop(context, 'OK');
                  getRecipes();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addRecipe(String name, int protein, int carbs, int fat) async {
    _isLoading = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('recipes')
          .doc('recipes')
          .update({
        Uuid().v1(): <String, dynamic>{
          'name': name,
          'protein': protein,
          'carbs': carbs,
          'fat': fat
        }
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      return;
    }
  }

  Future<void> getRecipes() async {
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
