import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/ingredient.dart';

class Recipes extends StatefulWidget {
  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final searchScrollController = ScrollController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final nameController = TextEditingController();
  final recipeNameController = TextEditingController();
  final updateRecipeNameController = TextEditingController();
  final amountController = TextEditingController();
  final updateIngredientNameController = TextEditingController();
  final updateIngredientAmountController = TextEditingController();
  List<Ingredient> ingredients = [];
  bool _isLoading = false;
  String recipeName = '';
  List<Recipe> recipes = [];

  @override
  void initState() {
    getRecipes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 3),
              itemCount: recipes.length,
              itemBuilder: ((context, index) {
                return Card(
                  color: Color.fromARGB(255, 18, 180, 151),
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: InkWell(
                      onTap: () {
                        updateRecipeNameController.text = recipes[index].name;
                        showRecipeDialog(context, height, index);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10, top: 12),
                        child: Column(
                          children: [
                            Text(
                              recipes[index].name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 9,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      recipes[index]
                                              .calories
                                              .round()
                                              .toString() +
                                          '\n' +
                                          'kcal',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      recipes[index]
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
                                      recipes[index].carbs.round().toString() +
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
                                      recipes[index].fat.round().toString() +
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
                      )),
                );
              })),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    'newRecipe'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  content: Form(
                    key: _formKey2,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'recipeName'.tr()),
                      controller: recipeNameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'required'.tr();
                        }
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        recipeNameController.text = '';
                        recipeName = '';
                        Navigator.pop(context);
                      },
                      child: Text('cancel'.tr()),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey2.currentState!.validate()) {
                          setState(() {
                            recipeName = recipeNameController.text;
                          });
                          Navigator.pop(context, 'OK');
                          showIngredientsDialog(context);
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                )),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> showRecipeDialog(
      BuildContext context, double height, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(4, 15, 4, 8),
              title: TextFormField(
                controller: updateRecipeNameController,
                decoration: InputDecoration(labelText: 'recipeName'.tr()),
              ),
              content: Container(
                width: double.maxFinite,
                height: height - 450,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        titlePadding: EdgeInsets.only(
                                            top: 8, left: 35, right: 25),
                                        contentPadding: EdgeInsets.only(
                                            top: 0,
                                            left: 15,
                                            right: 15,
                                            bottom: 0),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ingredients'.tr(),
                                            ),
                                            SizedBox(
                                              width: 34,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                nameController.text.isEmpty
                                                    ? Fluttertoast.showToast(
                                                        msg: 'searchEmpty'.tr(),
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                95, 95, 95))
                                                    : showSearchFoodDialog(
                                                        context, height);
                                              },
                                              icon: Icon(Icons.search),
                                            ),
                                          ],
                                        ),
                                        content: Container(
                                          height: 300,
                                          width: double.maxFinite,
                                          child: Form(
                                              child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'ingredientName'
                                                              .tr()),
                                                  controller: nameController,
                                                  onFieldSubmitted: (value) {
                                                    value.isEmpty
                                                        ? Fluttertoast.showToast(
                                                            msg: 'searchEmpty'
                                                                .tr(),
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    95,
                                                                    95,
                                                                    95))
                                                        : showSearchFoodDialog(
                                                            context, height);
                                                  },
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText: 'amount'.tr()),
                                                  controller: amountController,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'protein'.tr() +
                                                              ' (g)'),
                                                  controller: proteinController,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText: 'carbs'.tr() +
                                                          ' (g)'),
                                                  controller: carbsController,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'fat'.tr() + ' (g)'),
                                                  controller: fatController,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                ),
                                              ],
                                            ),
                                          )),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              nameController.text = '';
                                              amountController.text = '';
                                              proteinController.text = '';
                                              carbsController.text = '';
                                              fatController.text = '';
                                              Navigator.pop(context);
                                            },
                                            child: Text('cancel'.tr()),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                recipes[index].ingredients.add(
                                                    Ingredient(
                                                        nameController.text,
                                                        int.parse(
                                                            amountController
                                                                .text),
                                                        double.parse(
                                                            proteinController
                                                                .text),
                                                        double.parse(
                                                            carbsController
                                                                .text),
                                                        double.parse(
                                                            fatController
                                                                .text)));
                                                nameController.text = '';
                                                amountController.text = '';
                                                proteinController.text = '';
                                                carbsController.text = '';
                                                fatController.text = '';
                                                Fluttertoast.showToast(
                                                    msg: 'ingredientAdded'.tr(),
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 95, 95, 95));
                                                updateRecipe(recipes[index]);
                                              });

                                              Navigator.pop(context, 'OK');
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Text('addIngredient'.tr())),
                          Expanded(
                            child: ListView.builder(
                                itemCount: recipes[index].ingredients.length,
                                itemBuilder: ((context, index2) {
                                  return ListTile(
                                      title: Text(recipes[index]
                                              .ingredients[index2]
                                              .name +
                                          ' - ' +
                                          recipes[index]
                                              .ingredients[index2]
                                              .amount
                                              .toString() +
                                          ' g'),
                                      trailing: Container(
                                        width: 100,
                                        child: Row(children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              updateIngredientNameController
                                                      .text =
                                                  recipes[index]
                                                      .ingredients[index2]
                                                      .name;
                                              updateIngredientAmountController
                                                      .text =
                                                  recipes[index]
                                                      .ingredients[index2]
                                                      .amount
                                                      .toString();
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                        12,
                                                                        10,
                                                                        12,
                                                                        8),
                                                            content: Container(
                                                              height: 150,
                                                              child: Column(
                                                                children: [
                                                                  TextFormField(
                                                                    controller:
                                                                        updateIngredientNameController,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            'ingredientName'.tr()),
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                        updateIngredientAmountController,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            'amount'.tr()),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .numberWithOptions(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'cancel'
                                                                          .tr())),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    recipes[index]
                                                                            .ingredients[
                                                                                index2]
                                                                            .name =
                                                                        updateIngredientNameController
                                                                            .text;
                                                                    double mult = int.parse(updateIngredientAmountController
                                                                            .text) /
                                                                        recipes[index]
                                                                            .ingredients[index2]
                                                                            .amount;
                                                                    recipes[index]
                                                                            .ingredients[
                                                                                index2]
                                                                            .amount =
                                                                        int.parse(
                                                                            updateIngredientAmountController.text);

                                                                    recipes[index]
                                                                        .ingredients[
                                                                            index2]
                                                                        .protein *= mult;
                                                                    recipes[index]
                                                                        .ingredients[
                                                                            index2]
                                                                        .carbs *= mult;
                                                                    recipes[index]
                                                                        .ingredients[
                                                                            index2]
                                                                        .fat *= mult;
                                                                    recipes[index]
                                                                        .ingredients[
                                                                            index2]
                                                                        .calories = recipes[index].ingredients[index2].protein *
                                                                            4 +
                                                                        recipes[index].ingredients[index2].carbs *
                                                                            4 +
                                                                        recipes[index].ingredients[index2].fat *
                                                                            9;
                                                                    updateRecipe(
                                                                        recipes[
                                                                            index]);
                                                                    getRecipes();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'OK')),
                                                            ],
                                                          ));
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_forever),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                        builder: ((context,
                                                            setState) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'deleteIngr'.tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                'cancel'.tr()),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                recipes[index]
                                                                    .ingredients
                                                                    .removeAt(
                                                                        index2);
                                                                updateRecipe(
                                                                    recipes[
                                                                        index]);
                                                                getRecipes();
                                                              });
                                                              Navigator.pop(
                                                                  context,
                                                                  'OK');
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    }));
                                                  });
                                            },
                                          ),
                                        ]),
                                      ));
                                })),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                  'deleteRecipe'.tr(),
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
                                      deleteRecipe(recipes[index].name);
                                      getRecipes();
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ));
                    },
                    child: Text('deleteRecipe2'.tr())),
                TextButton(
                    onPressed: () {
                      String old = recipes[index].name;
                      if (old != updateRecipeNameController.text) {
                        recipes[index].name = updateRecipeNameController.text;
                        updateRecipe(recipes[index]);
                        deleteRecipe(old);
                        getRecipes();
                        Fluttertoast.showToast(
                            msg: 'recipeDeleted'.tr(),
                            backgroundColor: Color.fromARGB(255, 95, 95, 95));
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          }));
        });
  }

  Future<dynamic> showIngredientsDialog(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: EdgeInsets.only(top: 8, left: 35, right: 25),
        contentPadding: EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ingredients'.tr(),
            ),
            SizedBox(
              width: 34,
            ),
            IconButton(
              onPressed: () {
                nameController.text.isEmpty
                    ? Fluttertoast.showToast(
                        msg: 'searchEmpty'.tr(),
                        backgroundColor: Color.fromARGB(255, 95, 95, 95))
                    : showSearchFoodDialog(context, height);
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                ingredients.add(Ingredient(
                    nameController.text,
                    int.parse(amountController.text),
                    double.parse(proteinController.text),
                    double.parse(carbsController.text),
                    double.parse(fatController.text)));
                nameController.text = '';
                amountController.text = '';
                proteinController.text = '';
                carbsController.text = '';
                fatController.text = '';
                Fluttertoast.showToast(
                    msg: 'ingredientAdded'.tr(),
                    backgroundColor: Color.fromARGB(255, 95, 95, 95));
              },
              icon: Icon(Icons.save),
            ),
          ],
        ),
        content: Container(
          height: 300,
          width: double.maxFinite,
          child: Form(
              child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'ingredientName'.tr()),
                  controller: nameController,
                  onFieldSubmitted: (value) {
                    value.isEmpty
                        ? Fluttertoast.showToast(
                            msg: 'searchEmpty'.tr(),
                            backgroundColor: Color.fromARGB(255, 95, 95, 95))
                        : showSearchFoodDialog(context, height);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'amount'.tr()),
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
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
              ],
            ),
          )),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.text = '';
              amountController.text = '';
              proteinController.text = '';
              carbsController.text = '';
              fatController.text = '';
              Navigator.pop(context);
            },
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              addRecipe(ingredients);
              Navigator.pop(context, 'OK');
            },
            child: Text('saveRecipe'.tr()),
          ),
        ],
      ),
    );
  }

  Future<dynamic> showSearchFoodDialog(BuildContext context, double height) {
    return showDialog(
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
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(),
                          controller: amountController,
                          decoration: InputDecoration(labelText: 'amount'.tr()),
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
                            .where('nameSearchField',
                                arrayContains: nameController.text)
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
                                        if (_formKey.currentState!.validate()) {
                                          double protein = document['protein'] *
                                              int.parse(amountController.text) *
                                              0.01;
                                          double carbs = document['carbs'] *
                                              int.parse(amountController.text) *
                                              0.01;
                                          double fat = document['fat'] *
                                              int.parse(amountController.text) *
                                              0.01;
                                          proteinController.text =
                                              protein.toStringAsFixed(2);
                                          carbsController.text =
                                              carbs.toStringAsFixed(2);
                                          fatController.text =
                                              fat.toStringAsFixed(2);
                                          nameController.text =
                                              document['foodName'];
                                          Navigator.of(context).pop();
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
  }

  Future<void> getRecipes() async {
    _isLoading = true;
    recipes = [];
    List<Ingredient> ings = [];
    int numOfRecipes;

    await FirebaseFirestore.instance
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

  Future<void> addRecipe(List<Ingredient> ings) async {
    _isLoading = true;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    int calories;

    for (var element in ings) {
      protein += element.protein;
      carbs += element.carbs;
      fat += element.fat;
    }

    calories = (4 * protein + 4 * carbs + 9 * fat).round();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('recipes')
          .doc(recipeName)
          .set({
        for (int i = 0; i < ings.length; i++)
          ings[i].name: <String, dynamic>{
            'protein': ings[i].protein,
            'carbs': ings[i].carbs,
            'fat': ings[i].fat,
            'amount': ings[i].amount
          },
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
    Fluttertoast.showToast(
        msg: 'recipeSaved'.tr(),
        backgroundColor: Color.fromARGB(255, 95, 95, 95));
    recipeName = '';
    recipeNameController.text = '';
    ingredients = [];
    getRecipes();
    _isLoading = false;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    _isLoading = true;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    int calories;

    for (var element in recipe.ingredients) {
      protein += element.protein;
      carbs += element.carbs;
      fat += element.fat;
    }

    calories = (4 * protein + 4 * carbs + 9 * fat).round();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('recipes')
          .doc(recipe.name)
          .set({
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        for (int i = 0; i < recipe.ingredients.length; i++)
          recipe.ingredients[i].name: <String, dynamic>{
            'protein': recipe.ingredients[i].protein,
            'carbs': recipe.ingredients[i].carbs,
            'fat': recipe.ingredients[i].fat,
            'amount': recipe.ingredients[i].amount
          },
      });
    } catch (e) {
      print('ERROR: ' + e.toString());
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
    Fluttertoast.showToast(
        msg: 'updateRecipe'.tr(),
        backgroundColor: Color.fromARGB(255, 95, 95, 95));
    _isLoading = false;
  }

  Future<void> deleteRecipe(String recipeName) async {
    _isLoading = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('recipes')
          .doc(recipeName)
          .delete();
    } catch (e) {
      print('ERROR: ' + e.toString());
      Fluttertoast.showToast(
          msg: 'error'.tr(), backgroundColor: Color.fromARGB(255, 95, 95, 95));
      return;
    }
    Fluttertoast.showToast(
        msg: 'recipeDeleted'.tr(),
        backgroundColor: Color.fromARGB(255, 95, 95, 95));
    _isLoading = false;
  }
}
