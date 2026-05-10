import 'package:flutter/material.dart';
import '../i18n/app_strings.dart';
import '../services/rewards_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/settings_dialog.dart';
import 'daily_reward_screen.dart';
import 'game_screen.dart';
import 'missions_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rewards = RewardsService();
  int _diamonds = 0;

  @override
  void initState() {
    super.initState();
    _checkDailyAndLoad();
  }

  Future<void> _checkDailyAndLoad() async {
    final r = await _rewards.claimDailyIfAvailable();
    if (r.reward > 0 && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DailyRewardScreen(day: r.day, reward: r.reward),
        ),
      ).then((_) => _refresh());
    }
    _refresh();
  }

  Future<void> _refresh() async {
    final d = await _rewards.getDiamonds();
    if (mounted) setState(() => _diamonds = d);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2818), Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar with settings + diamonds
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFFFFD740), size: 28),
                      onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
                      tooltip: 'Settings',
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ShopScreen()));
                        _refresh();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF80DEEA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Color(0xFF80DEEA), size: 20),
                            const SizedBox(width: 6),
                            Text('$_diamonds',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(width: 6),
                            const Icon(Icons.add_circle, color: Color(0xFF80DEEA), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Color(0xFFFFD740), Color(0xFFFFAB00)],
                  ).createShader(r),
                  child: Text(
                    s.solitaire.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                Center(
                  child: Text(s.klondike,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 14, letterSpacing: 8)),
                ),
                const SizedBox(height: 32),
                // Card preview
                _CardStackPreview(),
                const SizedBox(height: 32),
                _bigButton(
                  s.newGame,
                  Icons.play_arrow,
                  const Color(0xFFFFAB00),
                  () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GameScreen()));
                    _refresh();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _smallButton(
                        s.missions,
                        Icons.flag,
                        const Color(0xFF8E24AA),
                        () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MissionsScreen()));
                          _refresh();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallButton(
                        s.shop,
                        Icons.shopping_cart,
                        const Color(0xFF1976D2),
                        () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ShopScreen()));
                          _refresh();
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FutureBuilder<int>(
                  future: _rewards.getCurrentStreak(),
                  builder: (c, snap) {
                    final streakDays = snap.data ?? 0;
                    if (streakDays == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Color(0xFFFF6F00)),
                          const SizedBox(width: 8),
                          Text(s.streak.replaceAll('{n}', '$streakDays'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bigButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      icon: Icon(icon, size: 28),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _smallButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      onPressed: onTap,
    );
  }
}

class _CardStackPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-50, 0),
            child: Transform.rotate(angle: -0.2, child: _miniCard('K', '♠', false)),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: _miniCard('Q', '♥', true),
          ),
          Transform.translate(
            offset: const Offset(50, 0),
            child: Transform.rotate(angle: 0.2, child: _miniCard('J', '♣', false)),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String rank, String suit, bool red) {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rank,
              style: TextStyle(
                  color: red ? Colors.red[700] : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          Text(suit,
              style: TextStyle(
                  color: red ? Colors.red[700] : Colors.black, fontSize: 24)),
        ],
      ),
    );
  }
}
