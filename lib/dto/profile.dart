class Profile {
  String id;
  String email;
  String firstName;
  String lastName;
  String kycFirstName;
  String kycLastName;
  String title;
  String gender;
  int birthDate;
  bool signupCompleted;
  String nationality;
  String mobilePhoneNumber;
  String shadowUserId;
  bool transferWiseTermsAccepted;
  Null idNowToken;

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    kycFirstName = json['kycFirstName'];
    kycLastName = json['kycLastName'];
    title = json['title'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    signupCompleted = json['signupCompleted'];
    nationality = json['nationality'];
    mobilePhoneNumber = json['mobilePhoneNumber'];
    shadowUserId = json['shadowUserId'];
    transferWiseTermsAccepted = json['transferWiseTermsAccepted'];
    idNowToken = json['idNowToken'];
  }
}
