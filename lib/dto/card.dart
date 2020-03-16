class Card {
  String id;
  String maskedPan;
  String publicToken;
  int pinDefined;
  int cardActivated;
  String usernameOnCard;
  String status;
  String design;
  String cardProductType;
  bool applePayEligible;
  bool googlePayEligible;
  String pan;
  int expirationDate;
  String cardType;
  String cardProduct;
  String exceetExpressCardDelivery;
  String membership;
  String exceetActualDeliveryDate;
  String exceetExpressCardDeliveryEmailSent;
  String exceetCardStatus;
  String exceetExpectedDeliveryDate;
  String exceetExpressCardDeliveryTrackingId;
  String cardSettingsId;
  bool mptsCard;
  String orderId;

  Card.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    maskedPan = json['maskedPan'];
    publicToken = json['publicToken'];
    pinDefined = json['pinDefined'];
    cardActivated = json['cardActivated'];
    usernameOnCard = json['usernameOnCard'];
    status = json['status'];
    design = json['design'];
    cardProductType = json['cardProductType'];
    applePayEligible = json['applePayEligible'];
    googlePayEligible = json['googlePayEligible'];
    pan = json['pan'];
    expirationDate = json['expirationDate'];
    cardType = json['cardType'];
    cardProduct = json['cardProduct'];
    exceetExpressCardDelivery = json['exceetExpressCardDelivery'];
    membership = json['membership'];
    exceetActualDeliveryDate = json['exceetActualDeliveryDate'];
    exceetExpressCardDeliveryEmailSent =
        json['exceetExpressCardDeliveryEmailSent'];
    exceetCardStatus = json['exceetCardStatus'];
    exceetExpectedDeliveryDate = json['exceetExpectedDeliveryDate'];
    exceetExpressCardDeliveryTrackingId =
        json['exceetExpressCardDeliveryTrackingId'];
    cardSettingsId = json['cardSettingsId'];
    mptsCard = json['mptsCard'];
    orderId = json['orderId'];
  }
}
