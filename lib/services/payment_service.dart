import '../models/payment_method.dart';

class PaymentService {
  Future<List<PaymentMethod>> getPaymentMethods() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      PaymentMethod(
        id: 'pm_1',
        cardHolderName: 'MAHMUT EREN YILMAZ',
        lastFourDigits: '4242',
        expiryDate: '12/25',
        cardType: CardType.visa,
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm_2',
        cardHolderName: 'MAHMUT EREN YILMAZ',
        lastFourDigits: '1234',
        expiryDate: '08/26',
        cardType: CardType.mastercard,
      ),
    ];
  }
}

