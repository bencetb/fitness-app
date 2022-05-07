class Ingredient {
  late String name;
  late dynamic amount;
  late dynamic protein;
  late dynamic carbs;
  late dynamic fat;
  late dynamic calories;

  Ingredient(this.name, this.amount, this.protein, this.carbs, this.fat) {
    calories = protein * 4 + carbs * 4 + fat * 9;
  }
}
