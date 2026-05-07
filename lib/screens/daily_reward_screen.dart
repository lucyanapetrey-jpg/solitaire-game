import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/rewards_service.dart';

class DailyRewardScreen extends StatefulWidget {
  final int day;
  final int reward;
  const DailyRewardScreen({super.key, required this.day, required this.reward});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818).withValues(alpha: 0.97),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 0.6, end: 1.0).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                  ),
                  child: const Text(
                    '🎁',
                    style: TextStyle(fontSize: 100),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('BONUS ZILNIC!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('Ziua ${widget.day} / 7',
                    style: const TextStyle(color: Colors.white60, fontSize: 16)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD740), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Color(0xFF80DEEA), size: 48),
                      const SizedBox(width: 12),
                      Text('+${widget.reward}',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD740))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Calendar 7 days
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final claimed = day <= widget.day;
                    final isToday = day == widget.day;
                    return Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFFFFAB00)
                            : (claimed
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.white12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isToday ? const Color(0xFFFFD740) : Colors.white24,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ziua $day',
                              style: TextStyle(
                                  color: claimed ? Colors.white : Colors.white60,
                                  fontSize: 11)),
                          const SizedBox(height: 4),
                          if (claimed)
                            const Icon(Icons.check_circle, color: Colors.white, size: 18)
                          else
                            const Icon(Icons.diamond, color: Color(0xFF80DEEA), size: 18),
                          Text('${RewardsService.dailyRewards[i]}',
                              style: TextStyle(
                                  color: claimed ? Colors.white : Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFAB00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('PRIMEȘTE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
