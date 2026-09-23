import 'package:flutter/material.dart';
import '../../models/payment_method.dart';
import '../../services/payment_service.dart';
import '../../widgets/empty_state_widget.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentMethod>? _methods;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final methods = await _paymentService.getPaymentMethods();
    if (mounted) {
      setState(() {
        _methods = methods;
        _loading = false;
      });
    }
  }

  void _removePaymentMethod(int index) {
    setState(() {
      _methods!.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ödeme yöntemi silindi.')),
    );
  }

  LinearGradient _getCardGradient(CardType type) {
    switch (type) {
      case CardType.visa:
        return const LinearGradient(
          colors: [Color(0xFF1A1F71), Color(0xFF00539B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardType.mastercard:
        return const LinearGradient(
          colors: [Color(0xFF8B0000), Color(0xFFDC143C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF424242), Color(0xFF212121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Yöntemlerim', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _methods == null || _methods!.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.credit_card_off,
                  title: 'Kart Bulunamadı',
                  subtitle: 'Kayıtlı ödeme yöntemi bulunmuyor. Yeni bir kart ekleyebilirsiniz.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _methods!.length,
                  itemBuilder: (context, index) {
                    final method = _methods![index];
                    return Dismissible(
                      key: Key(method.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) {
                        _removePaymentMethod(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: _getCardGradient(method.cardType),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.memory, color: Colors.white70, size: 32),
                                  if (method.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                      ),
                                      child: const Text('Varsayılan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '****  ****  ****  ${method.lastFourDigits}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 2,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'KART SAHİBİ',
                                        style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        method.cardHolderName.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'SKT',
                                        style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        method.expiryDate,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    method.cardType.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kart ekleme ekranı yakında eklenecek.')));
        },
        icon: const Icon(Icons.add_card),
        label: const Text('Yeni Kart Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
