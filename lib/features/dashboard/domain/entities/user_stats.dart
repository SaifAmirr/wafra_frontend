class UserStats {
  // Restaurant
  final int listingsPosted;
  final int mealsDonated;
  final int partnersServed;

  // Individual & Food Bank
  final int mealsReceived;
  final int pickupsCompleted;
  final int restaurantsVisited;

  const UserStats({
    this.listingsPosted = 0,
    this.mealsDonated = 0,
    this.partnersServed = 0,
    this.mealsReceived = 0,
    this.pickupsCompleted = 0,
    this.restaurantsVisited = 0,
  });
}
