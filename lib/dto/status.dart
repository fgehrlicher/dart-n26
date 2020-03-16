import 'package:dart_n26/dto/kyc_detail.dart';

class Status {
  String id;
  int created;
  int updated;
  int singleStepSignup;
  int emailValidationInitiated;
  int emailValidationCompleted;
  int productSelectionCompleted;
  int phonePairingInitiated;
  int phonePairingCompleted;
  String userStatusCol;
  int kycInitiated;
  int kycCompleted;
  String kycPersonalCompleted;
  String kycPostIdentInitiated;
  String kycPostIdentCompleted;
  String kycWebIDInitiated;
  String kycWebIDCompleted;
  KycDetail kycDetails;
  int cardActivationCompleted;
  String cardIssued;
  int pinDefinitionCompleted;
  String accountClosed;
  String coreDataUpdated;
  String unpairingProcessStatus;
  String isDeceased;
  String firstIncomingTransaction;
  bool flexAccount;
  int flexAccountConfirmed;
  String signupStep;
  String unpairTokenCreation;
  String pairingState;
  String showScreen;

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    updated = json['updated'];
    singleStepSignup = json['singleStepSignup'];
    emailValidationInitiated = json['emailValidationInitiated'];
    emailValidationCompleted = json['emailValidationCompleted'];
    productSelectionCompleted = json['productSelectionCompleted'];
    phonePairingInitiated = json['phonePairingInitiated'];
    phonePairingCompleted = json['phonePairingCompleted'];
    userStatusCol = json['userStatusCol'];
    kycInitiated = json['kycInitiated'];
    kycCompleted = json['kycCompleted'];
    kycPersonalCompleted = json['kycPersonalCompleted'];
    kycPostIdentInitiated = json['kycPostIdentInitiated'];
    kycPostIdentCompleted = json['kycPostIdentCompleted'];
    kycWebIDInitiated = json['kycWebIDInitiated'];
    kycWebIDCompleted = json['kycWebIDCompleted'];
    kycDetails = json['kycDetails'] != String
        ? KycDetail.fromJson(json['kycDetails'])
        : String;
    cardActivationCompleted = json['cardActivationCompleted'];
    cardIssued = json['cardIssued'];
    pinDefinitionCompleted = json['pinDefinitionCompleted'];
    accountClosed = json['accountClosed'];
    coreDataUpdated = json['coreDataUpdated'];
    unpairingProcessStatus = json['unpairingProcessStatus'];
    isDeceased = json['isDeceased'];
    firstIncomingTransaction = json['firstIncomingTransaction'];
    flexAccount = json['flexAccount'];
    flexAccountConfirmed = json['flexAccountConfirmed'];
    signupStep = json['signupStep'];
    unpairTokenCreation = json['unpairTokenCreation'];
    pairingState = json['pairingState'];
    showScreen = json['showScreen'];
  }
}
