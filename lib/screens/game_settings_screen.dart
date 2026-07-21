import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../services/consent_service.dart';
import '../services/settings_service.dart';
import '../services/sound_effects.dart';
import 'legal_document_screen.dart';

enum SettingsOpenSource { home, game }

enum SettingsGameAction { restart, home }

class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({
    super.key,
    required this.settings,
    required this.openSource,
  });

  final SettingsService settings;
  final SettingsOpenSource openSource;

  static const Color _backgroundColor = Color(0xFFFAE3B8);
  static const Color _cardColor = Color(0xFFFFFCE5);
  static const Color _primaryColor = Color(0xFFA84B00);
  static const Color _secondaryText = Color(0xFF8B664C);
  static const Color _borderColor = Color(0xFFFFC77F);
  static const Color _lightBorder = Color(0xFFFFD69A);
  static const Color _inactiveColor = Color(0xFFD6A16C);

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {'subject': 'Fruit Merge Support'},
    );

    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                const Positioned.fill(child: _GameSettingsBackground()),

                Column(
                  children: [
                    _buildHeader(context),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.sports_esports_rounded,
                              title: 'GAME PREFERENCES',
                            ),

                            const SizedBox(height: 8),

                            _SettingsCard(
                              children: [
                                _SettingsTile(
                                  icon: Icons.vibration_rounded,
                                  iconBackground: const Color(0xFFFFE0B2),
                                  iconColor: const Color(0xFFF57C00),
                                  title: 'Vibrations',
                                  subtitle: 'Feel feedback while playing',
                                  trailing: _SettingsSwitch(
                                    value: settings.vibrationEnabled,
                                    onChanged: (_) {
                                      SoundEffects.playButtonTap(settings);
                                      settings.toggleVibration();
                                    },
                                  ),
                                ),

                                const _SettingsDivider(),

                                _SettingsTile(
                                  icon: settings.soundEnabled
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                  iconBackground: const Color(0xFFD9F1FF),
                                  iconColor: const Color(0xFF349DEB),
                                  title: 'Sounds',
                                  subtitle: 'Game effects and feedback',
                                  trailing: _SettingsSwitch(
                                    value: settings.soundEnabled,
                                    onChanged: (_) async {
                                      if (settings.soundEnabled) {
                                        await SoundEffects.playButtonTap(
                                          settings,
                                        );
                                      }
                                      await settings.toggleSound();
                                      if (settings.soundEnabled) {
                                        SoundEffects.playButtonTap(settings);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            const _SectionTitle(
                              icon: Icons.favorite_rounded,
                              title: 'SUPPORT',
                            ),

                            const SizedBox(height: 8),

                            _SettingsCard(
                              children: [
                                _SettingsTile(
                                  icon: Icons.star_rounded,
                                  iconBackground: const Color(0xFFFFF0B8),
                                  iconColor: const Color(0xFFFFB51E),
                                  title: 'Rate us',
                                  subtitle: 'Enjoying the game? Tell us',
                                  showArrow: true,
                                  onTap: () {
                                    SoundEffects.playButtonTap(settings);
                                    _openUrl(AppConfig.playStoreUrl);
                                  },
                                ),

                                const _SettingsDivider(),

                                _SettingsTile(
                                  icon: Icons.mail_rounded,
                                  iconBackground: const Color(0xFFDDF5DD),
                                  iconColor: const Color(0xFF20A83D),
                                  title: 'Write us',
                                  subtitle: 'Questions or suggestions',
                                  showArrow: true,
                                  onTap: () {
                                    SoundEffects.playButtonTap(settings);
                                    _openEmail();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            const _SectionTitle(
                              icon: Icons.info_rounded,
                              title: 'INFORMATION',
                            ),

                            const SizedBox(height: 8),

                            _SettingsCard(
                              children: [
                                _SettingsTile(
                                  icon: Icons.privacy_tip_rounded,
                                  iconBackground: const Color(0xFFFFDCE4),
                                  iconColor: const Color(0xFFE94B70),
                                  title: 'Privacy Policy',
                                  subtitle: 'How your data is handled',
                                  showArrow: true,
                                  onTap: () {
                                    SoundEffects.playButtonTap(settings);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LegalDocumentScreen(
                                              title: 'Privacy Policy',
                                              onlineUrl:
                                                  AppConfig.privacyPolicyUrl,
                                              sections: LegalDocumentScreen
                                                  .privacySections,
                                            ),
                                      ),
                                    );
                                  },
                                ),

                                const _SettingsDivider(),

                                if (ConsentService.privacyOptionsRequired) ...[
                                  _SettingsTile(
                                    icon: Icons.tune_rounded,
                                    iconBackground: const Color(0xFFDFF1FF),
                                    iconColor: const Color(0xFF368ED8),
                                    title: 'Advertising privacy choices',
                                    subtitle: 'Review your consent choices',
                                    showArrow: true,
                                    onTap: () async {
                                      await SoundEffects.playButtonTap(
                                        settings,
                                      );
                                      final error =
                                          await ConsentService.showPrivacyOptions();
                                      if (context.mounted && error != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(error)),
                                        );
                                      }
                                    },
                                  ),
                                  const _SettingsDivider(),
                                ],

                                _SettingsTile(
                                  icon: Icons.description_rounded,
                                  iconBackground: const Color(0xFFFFE5C7),
                                  iconColor: const Color(0xFFD77925),
                                  title: 'Terms of Service',
                                  subtitle: 'Rules for using the game',
                                  showArrow: true,
                                  onTap: () {
                                    SoundEffects.playButtonTap(settings);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LegalDocumentScreen(
                                              title: 'Terms of Service',
                                              onlineUrl:
                                                  AppConfig.termsOfServiceUrl,
                                              sections: LegalDocumentScreen
                                                  .termsSections,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            if (openSource == SettingsOpenSource.game) ...[
                              const SizedBox(height: 22),

                              Row(
                                children: [
                                  Expanded(
                                    child: _GameActionButton(
                                      icon: Icons.home_rounded,
                                      text: 'HOME',
                                      backgroundColor: const Color(0xFFFFC45C),
                                      borderColor: const Color(0xFFD98B20),
                                      onTap: () {
                                        SoundEffects.playButtonTap(settings);
                                        Navigator.pop(
                                          context,
                                          SettingsGameAction.home,
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: _GameActionButton(
                                      icon: Icons.restart_alt_rounded,
                                      text: 'RESTART',
                                      backgroundColor: const Color(0xFFFF8A3D),
                                      borderColor: const Color(0xFFD75D18),
                                      onTap: () {
                                        SoundEffects.playButtonTap(settings);
                                        Navigator.pop(
                                          context,
                                          SettingsGameAction.restart,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            const Center(
                              child: Text(
                                'FRUIT MERGE  •  VERSION 1.0',
                                style: TextStyle(
                                  color: Color(0xFFB78967),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 82,
      width: double.infinity,
      child: Stack(
        children: [
          // ======================================================
          // BACK BUTTON
          // ======================================================
          Positioned(
            left: 16,
            top: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SoundEffects.playButtonTap(settings);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA84B00).withValues(alpha: 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: _primaryColor,
                    size: 29,
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // NORMAL SETTINGS TITLE
          // ======================================================
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Icon(icon, color: GameSettingsScreen._primaryColor, size: 15),

          const SizedBox(width: 6),

          Text(
            title,
            style: const TextStyle(
              color: GameSettingsScreen._primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS CARD
// ============================================================

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: GameSettingsScreen._cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: GameSettingsScreen._borderColor, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA84B00).withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 7,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ============================================================
// SETTINGS TILE
// ============================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrow = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final Widget? trailingWidget = trailing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.30),
                    width: 1.3,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: GameSettingsScreen._primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GameSettingsScreen._secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              ?trailingWidget,

              if (showArrow)
                Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4BC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFB76A31),
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 50),
      color: GameSettingsScreen._lightBorder,
    );
  }
}

// ============================================================
// SETTINGS SWITCH
// ============================================================

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 47,
        height: 27,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFFB8EA48), Color(0xFF73BD20)],
                )
              : null,
          color: value ? null : GameSettingsScreen._inactiveColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: value ? const Color(0xFF5E9E1E) : const Color(0xFFB77A45),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCE5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GAME ACTION BUTTON
// ============================================================

class _GameActionButton extends StatelessWidget {
  const _GameActionButton({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 21),

            const SizedBox(width: 7),

            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class _GameSettingsBackground extends StatelessWidget {
  const _GameSettingsBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GameSettingsBackgroundPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GameSettingsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFAE3B8),
    );

    final dotPaint = Paint()
      ..color = const Color(0xFFFFC77F).withValues(alpha: 0.16);

    const spacing = 38.0;

    for (double y = 18; y < size.height; y += spacing) {
      for (double x = 18; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
