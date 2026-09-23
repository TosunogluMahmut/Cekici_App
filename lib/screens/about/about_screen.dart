import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.car_crash, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Çekici Çağır',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Sürüm 1.0.0',
                style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Çekici Çağır, yolda kaldığınız anlarda en yakın çekiciyi '
              'hızlı ve güvenli bir şekilde bulmanızı sağlayan bir platformdur.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary),
                    title: const Text('Gizlilik Politikası'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                    title: const Text('Kullanım Koşulları'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.policy_outlined, color: theme.colorScheme.primary),
                    title: const Text('Lisanslar'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Çekici Çağır',
                        applicationVersion: '1.0.0',
                        applicationIcon: Icon(Icons.car_crash, size: 48, color: theme.colorScheme.primary),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.mail_outline, color: theme.colorScheme.primary),
                    title: const Text('Bize Ulaşın'),
                    subtitle: const Text('destek@cekiciapp.com'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '© 2026 Çekici Çağır Tüm Hakları Saklıdır',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
