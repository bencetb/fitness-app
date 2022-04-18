class Meal {
  late String mealType;
  late String foodName;
  late dynamic protein;
  late dynamic carbs;
  late dynamic fat;
  late dynamic calories;

  Meal(this.mealType, this.protein, this.carbs, this.fat, this.foodName) {
    calories = protein * 4 + carbs * 4 + fat * 9;
  }
}
