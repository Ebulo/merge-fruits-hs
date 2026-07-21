import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.onlineUrl,
    required this.sections,
  });

  final String title;
  final String onlineUrl;
  final List<LegalSection> sections;

  static const privacySections = <LegalSection>[
    LegalSection(
      'Overview',
      'Fruit Merge is an offline puzzle game published by Ebulo. The game '
          'does not require an account and does not ask for your name, phone '
          'number, contacts, precise location, photos, or files.',
    ),
    LegalSection(
      'Information stored on your device',
      'Your best score, unlocked level, coin balance, daily reward progress, '
          'and sound and vibration preferences are stored locally on your '
          'device. This information is used only to preserve game progress '
          'and settings. You can remove it by clearing the app data or '
          'uninstalling the game.',
    ),
    LegalSection(
      'Advertising and third-party data',
      'Fruit Merge uses Google Mobile Ads to display banner and interstitial '
          'advertisements. Depending on your device, region, and privacy '
          'choices, Google may process IP-derived approximate location, app '
          'interactions, diagnostic information, advertising identifiers, '
          'and other device or account identifiers for advertising, '
          'analytics, and fraud prevention. Data is encrypted in transit.',
    ),
    LegalSection(
      'Consent and privacy choices',
      'Where required, the game asks for advertising consent before '
          'requesting ads. You can revisit available advertising privacy '
          'choices from the game Settings screen. You may also reset or '
          'delete your Android advertising ID from your device settings.',
    ),
    LegalSection(
      'Children',
      'Fruit Merge is not designed to knowingly collect personal information '
          'from children. The target audience and advertising settings '
          'declared in Google Play must accurately match the audience chosen '
          'by the publisher.',
    ),
    LegalSection(
      'Contact',
      'For privacy questions, contact ${AppConfig.supportEmail}. This policy '
          'may be updated when the game or its data practices change.',
    ),
  ];

  static const termsSections = <LegalSection>[
    LegalSection(
      'Using Fruit Merge',
      'Fruit Merge is provided for personal entertainment. You may not '
          'reverse engineer, redistribute, sell, disrupt, or misuse the game '
          'or use it in violation of applicable law.',
    ),
    LegalSection(
      'Game progress and availability',
      'Scores, levels, coins, and daily rewards are virtual game progress '
          'with no cash value. Local progress may be lost if app data is '
          'cleared, the app is uninstalled, or a device is replaced. Features '
          'and availability may change as the game is improved.',
    ),
    LegalSection(
      'Advertising',
      'The game may display advertisements supplied by third parties. Ad '
          'content and availability can vary by region and privacy choices. '
          'You are responsible for reviewing any third-party offer before '
          'interacting with it.',
    ),
    LegalSection(
      'Disclaimer',
      'The game is provided as available without guarantees that it will '
          'always be uninterrupted or error-free. Nothing in these terms '
          'limits rights that cannot be limited under applicable consumer law.',
    ),
    LegalSection(
      'Contact',
      'Questions about these terms can be sent to ${AppConfig.supportEmail}.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAE3B8),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFFFCE5),
        foregroundColor: const Color(0xFFA84B00),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Effective July 22, 2026',
            style: TextStyle(
              color: Color(0xFF8B664C),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          for (final section in sections) ...[
            Text(
              section.heading,
              style: const TextStyle(
                color: Color(0xFFA84B00),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.body,
              style: const TextStyle(
                color: Color(0xFF65452F),
                height: 1.45,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
          ],
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(onlineUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('View online'),
          ),
        ],
      ),
    );
  }
}
