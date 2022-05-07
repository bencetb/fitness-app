import 'ingredient.dart';

class Recipe {
  late String name;
  late dynamic protein;
  late dynamic carbs;
  late dynamic fat;
  late int calories;
  late List<Ingredient> ingredients;

  Recipe(this.name, this.protein, this.carbs, this.fat, this.calories,
      this.ingredients);
}
