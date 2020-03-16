class UserFeatures {
  int availableSpaces;
  bool canUpgrade;

  UserFeatures.fromJson(Map<String, dynamic> json) {
    availableSpaces = json['availableSpaces'];
    canUpgrade = json['canUpgrade'];
  }
}
