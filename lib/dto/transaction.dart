class Transaction {
  String id;
  String userId;
  String type;
  double amount;
  String currencyCode;
  double originalAmount;
  String originalCurrency;
  double exchangeRate;
  String merchantCity;
  int visibleTS;
  int mcc;
  int mccGroup;
  String merchantName;
  bool recurring;
  bool partnerAccountIsSepa;
  String accountId;
  String category;
  String cardId;
  int userCertified;
  bool pending;
  String transactionNature;
  int createdTS;
  int merchantCountry;
  int merchantCountryCode;
  String txnCondition;
  String smartLinkId;
  String linkId;
  int confirmed;
  String partnerBic;
  String partnerName;
  String partnerIban;
  String referenceText;
  String mandateId;
  String creditorIdentifier;
  String creditorName;
  String smartContactId;
  String partnerBcn;
  String partnerAccountBan;
  int userAccepted;
  String partnerBankName;
  String paymentScheme;
  String purposeCode;
  String referenceToOriginalOperation;

  Transaction({
    this.id,
    this.userId,
    this.type,
    this.amount,
    this.currencyCode,
    this.originalAmount,
    this.originalCurrency,
    this.exchangeRate,
    this.merchantCity,
    this.visibleTS,
    this.mcc,
    this.mccGroup,
    this.merchantName,
    this.recurring,
    this.partnerAccountIsSepa,
    this.accountId,
    this.category,
    this.cardId,
    this.userCertified,
    this.pending,
    this.transactionNature,
    this.createdTS,
    this.merchantCountry,
    this.merchantCountryCode,
    this.txnCondition,
    this.smartLinkId,
    this.linkId,
    this.confirmed,
    this.partnerBic,
    this.partnerName,
    this.partnerIban,
    this.referenceText,
    this.mandateId,
    this.creditorIdentifier,
    this.creditorName,
    this.smartContactId,
    this.partnerBcn,
    this.partnerAccountBan,
    this.userAccepted,
    this.partnerBankName,
    this.paymentScheme,
    this.purposeCode,
    this.referenceToOriginalOperation,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    type = json['type'];
    amount = json['amount'];
    currencyCode = json['currencyCode'];
    originalAmount = json['originalAmount'];
    originalCurrency = json['originalCurrency'];
    exchangeRate = json['exchangeRate'];
    merchantCity = json['merchantCity'];
    visibleTS = json['visibleTS'];
    mcc = json['mcc'];
    mccGroup = json['mccGroup'];
    merchantName = json['merchantName'];
    recurring = json['recurring'];
    partnerAccountIsSepa = json['partnerAccountIsSepa'];
    accountId = json['accountId'];
    category = json['category'];
    cardId = json['cardId'];
    userCertified = json['userCertified'];
    pending = json['pending'];
    transactionNature = json['transactionNature'];
    createdTS = json['createdTS'];
    merchantCountry = json['merchantCountry'];
    merchantCountryCode = json['merchantCountryCode'];
    txnCondition = json['txnCondition'];
    smartLinkId = json['smartLinkId'];
    linkId = json['linkId'];
    confirmed = json['confirmed'];
    partnerBic = json['partnerBic'];
    partnerName = json['partnerName'];
    partnerIban = json['partnerIban'];
    referenceText = json['referenceText'];
    mandateId = json['mandateId'];
    creditorIdentifier = json['creditorIdentifier'];
    creditorName = json['creditorName'];
    smartContactId = json['smartContactId'];
    partnerBcn = json['partnerBcn'];
    partnerAccountBan = json['partnerAccountBan'];
    userAccepted = json['userAccepted'];
    partnerBankName = json['partnerBankName'];
    paymentScheme = json['paymentScheme'];
    purposeCode = json['purposeCode'];
    referenceToOriginalOperation = json['referenceToOriginalOperation'];
  }
}
