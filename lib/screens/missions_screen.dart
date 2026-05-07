import 'package:flutter/material.dart';
import '../services/rewards_service.dart';

const allMissions = [
  Mission(id: 'first_win', title: 'Prima victorie', description: 'Câștigă primul joc', reward: 50, target: 1),
  Mission(id: 'three_wins', title: 'Hattrick', description: 'Câștigă 3 jocuri', reward: 100, target: 3),
  Mission(id: 'ten_wins', title: 'Maestru', description: 'Câștigă 10 jocuri', reward: 300, target: 10),
  Mission(id: 'fifty_moves', title: 'Eficient', description: 'Fă 50 de mutări', reward: 30, target: 50),
  Mission(id: 'foundation_50', title: 'Constructor', description: 'Plasează 50 cărți la fundație', reward: 80, target: 50),
  Mission(id: 'play_5_games', title: 'Persistent', description: 'Joacă 5 jocuri', reward: 50, target: 5),
  Mission(id: 'use_3_powers', title: 'Strateg', description: 'Folosește 3 power-ups', reward: 60, target: 3),
  Mission(id: 'no_undo_win', title: 'Pur și simplu', description: 'Câștigă fără să dai Undo', reward: 200, target: 1),
];

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final _missions = MissionsService();
  final _rewards = RewardsService();
  Map<String, int> _progress = {};
  Map<String, bool> _claimed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _missions.getProgress();
    final c = <String, bool>{};
    for (final m in allMissions) {
      c[m.id] = await _missions.isClaimed(m.id);
    }
    if (!mounted) return;
    setState(() {
      _progress = p;
      _claimed = c;
    });
  }

  Future<void> _claim(Mission m) async {
    await _missions.setClaimed(m.id);
    await _rewards.addDiamonds(m.reward);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Misiuni'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2818), Color(0xFF1B5E20)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: allMissions.length,
          itemBuilder: (ctx, i) {
            final m = allMissions[i];
            final cur = _progress[m.id] ?? 0;
            final done = cur >= m.target;
            final claimed = _claimed[m.id] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: claimed
                    ? Colors.black26
                    : (done ? const Color(0xFFFFAB00).withValues(alpha: 0.3) : Colors.black54),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: claimed
                      ? Colors.white24
                      : (done ? const Color(0xFFFFD740) : Colors.white24),
                  width: done && !claimed ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        claimed
                            ? Icons.check_circle
                            : (done ? Icons.workspace_premium : Icons.flag),
                        color: claimed
                            ? Colors.greenAccent
                            : (done ? const Color(0xFFFFD740) : Colors.white60),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(m.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                decoration:
                                    claimed ? TextDecoration.lineThrough : null)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.diamond, color: Color(0xFF80DEEA), size: 18),
                          const SizedBox(width: 4),
                          Text('+${m.reward}',
                              style: const TextStyle(
                                  color: Color(0xFFFFD740),
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(m.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (cur / m.target).clamp(0.0, 1.0),
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(
                              done ? const Color(0xFFFFD740) : const Color(0xFF66BB6A),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$cur/${m.target}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  if (done && !claimed) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFAB00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _claim(m),
                        child: const Text('PRIMEȘTE',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
