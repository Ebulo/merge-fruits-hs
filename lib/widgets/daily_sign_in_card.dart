import 'package:flutter/material.dart';

import '../services/daily_reward_service.dart';
import '../services/settings_service.dart';
import '../services/sound_effects.dart';

class DailySignInCard extends StatelessWidget {
  const DailySignInCard({
    super.key,
    required this.dailyReward,
    required this.settings,
  });

  final DailyRewardService dailyReward;
  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dailyReward,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF79C8ED),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF4DA6D2,
                ).withValues(alpha: 0.25),
                offset: const Offset(0, 4),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =======================================================
              // HEADER
              // =======================================================

              Row(
                children: [
                  // FIRE ICON

                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECA8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFC75A),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      '🔥',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  // TITLE

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY STREAK',
                          style: TextStyle(
                            color: Color(0xFF2478A5),
                            fontSize: 17,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Play every day and collect rewards!',
                          style: TextStyle(
                            color: Color(0xFF6B9DB7),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CURRENT DAY

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF5C9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF91D35A),
                        width: 1.8,
                      ),
                    ),
                    child: Text(
                      'DAY ${dailyReward.currentDay}',
                      style: const TextStyle(
                        color: Color(0xFF589A2A),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =======================================================
              // 7 DAY REWARD CARDS
              // =======================================================

              Row(
                children: List.generate(
                  7,
                  (index) {
                    final day = index + 1;

                    final completed =
                        dailyReward.isDayCompleted(day);

                    final current =
                        dailyReward.isCurrentDay(day);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                        ),
                        child: _RewardDayCard(
                          day: day,
                          reward:
                              dailyReward.rewardForDay(day),
                          completed: completed,
                          current: current,
                          claimedToday:
                              dailyReward.claimedToday,
                          onTap: () {
                            if (current &&
                                dailyReward.canClaim) {
                              SoundEffects.playButtonTap(settings);
                              _claimReward(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================================================================
  // CLAIM REWARD
  // ===================================================================

  Future<void> _claimReward(
    BuildContext context,
  ) async {
    final reward = dailyReward.currentReward;

    final claimed = await dailyReward.claimReward();

    if (!context.mounted || !claimed) {
      return;
    }

    // Reward claim hone ke baad sirf SnackBar show hoga.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF74C943),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Text(
              '🎁',
              style: TextStyle(
                fontSize: 21,
              ),
            ),

            const SizedBox(width: 9),

            Text(
              '+$reward Reward Collected!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// DAY REWARD CARD
// =====================================================================

class _RewardDayCard extends StatelessWidget {
  const _RewardDayCard({
    required this.day,
    required this.reward,
    required this.completed,
    required this.current,
    required this.claimedToday,
    required this.onTap,
  });

  final int day;
  final int reward;

  final bool completed;
  final bool current;
  final bool claimedToday;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        height: 80,
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _borderColor(),
            width: current ? 2.5 : 1.5,
          ),
          boxShadow: current && !claimedToday
              ? [
                  BoxShadow(
                    color: const Color(
                      0xFFFFB84D,
                    ).withValues(alpha: 0.30),
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // =========================================================
            // DAY NUMBER
            // =========================================================

            Container(
              height: 20,
              alignment: Alignment.center,
              child: Text(
                'DAY $day',
                style: TextStyle(
                  color: _textColor(),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // =========================================================
            // REWARD ICON
            // =========================================================

            Expanded(
              child: Center(
                child: completed
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF70BE42),
                        size: 26,
                      )
                    : Text(
                        day == 7 ? '🎁' : '🍒',
                        style: const TextStyle(
                          fontSize: 23,
                        ),
                      ),
              ),
            ),

            // =========================================================
            // REWARD AMOUNT
            // =========================================================

            Container(
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _bottomColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+$reward',
                  style: TextStyle(
                    color: _textColor(),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // BACKGROUND COLOR
  // ===================================================================

  Color _backgroundColor() {
    // COMPLETED DAY

    if (completed) {
      return const Color(0xFFE5F8D7);
    }

    // CURRENT DAY

    if (current && !claimedToday) {
      return const Color(0xFFFFF1C7);
    }

    // UPCOMING DAY

    return const Color(0xFFDDF3FC);
  }

  // ===================================================================
  // BOTTOM COLOR
  // ===================================================================

  Color _bottomColor() {
    // COMPLETED DAY

    if (completed) {
      return const Color(0xFFCFF0B9);
    }

    // CURRENT DAY

    if (current && !claimedToday) {
      return const Color(0xFFFFDFA0);
    }

    // UPCOMING DAY

    return const Color(0xFFC8EAF8);
  }

  // ===================================================================
  // BORDER COLOR
  // ===================================================================

  Color _borderColor() {
    // COMPLETED DAY

    if (completed) {
      return const Color(0xFF9AD66D);
    }

    // CURRENT DAY

    if (current && !claimedToday) {
      return const Color(0xFFFFBD58);
    }

    // UPCOMING DAY

    return const Color(0xFF8DD0ED);
  }

  // ===================================================================
  // TEXT COLOR
  // ===================================================================

  Color _textColor() {
    // COMPLETED DAY

    if (completed) {
      return const Color(0xFF559C30);
    }

    // CURRENT DAY

    if (current && !claimedToday) {
      return const Color(0xFFC77A16);
    }

    // UPCOMING DAY

    return const Color(0xFF4C91B5);
  }
}
