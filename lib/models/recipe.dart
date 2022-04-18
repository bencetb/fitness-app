class Recipe {
  late String name;
  late int protein;
  late int carbs;
  late int fat;
  late int calories;

  Recipe(this.name, this.protein, this.carbs, this.fat) {
    calories = protein * 4 + carbs * 4 + fat * 9;
  }
}
