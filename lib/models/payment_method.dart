enum CardType {
  visa,
  mastercard,
  other,
}

class PaymentMethod {
  final String id;
  final String cardHolderName;
  final String lastFourDigits;
  final String expiryDate;
  final CardType cardType;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardHolderName,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });
}

