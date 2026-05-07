import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rewards_service.dart';

class PowerItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int price;
  const PowerItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.price,
  });
}

const allPowers = [
  PowerItem(
    id: 'hint',
    name: 'Indiciu',
    description: 'Arată o mutare validă',
    icon: Icons.lightbulb,
    color: Color(0xFFFFB300),
    price: 30,
  ),
  PowerItem(
    id: 'undo_all',
    name: 'Reset complet',
    description: 'Anulează toate mutările',
    icon: Icons.history,
    color: Color(0xFF8E24AA),
    price: 80,
  ),
  PowerItem(
    id: 'shuffle',
    name: 'Amestecă cărți',
    description: 'Reamestecă teancul nedistribuit',
    icon: Icons.shuffle,
    color: Color(0xFF1E88E5),
    price: 50,
  ),
  PowerItem(
    id: 'peek',
    name: 'Privește următoarele 3',
    description: 'Vezi următoarele 3 cărți din stack',
    icon: Icons.visibility,
    color: Color(0xFF00ACC1),
    price: 20,
  ),
];

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _rewards = RewardsService();
  int _diamonds = 0;
  Map<String, int> _owned = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _rewards.getDiamonds();
    final p = await _getOwnedPowers();
    if (!mounted) return;
    setState(() {
      _diamonds = d;
      _owned = p;
    });
  }

  Future<Map<String, int>> _getOwnedPowers() async {
    // Stored as power_count_<id>
    final m = <String, int>{};
    for (final pw in allPowers) {
      m[pw.id] = await _getPowerCount(pw.id);
    }
    return m;
  }

  Future<int> _getPowerCount(String id) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('power_$id') ?? 0;
  }

  Future<void> _buy(PowerItem pw) async {
    if (_diamonds < pw.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diamante insuficiente')),
      );
      return;
    }
    final ok = await _rewards.spendDiamonds(pw.price);
    if (!ok) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt('power_${pw.id}', (await _getPowerCount(pw.id)) + 1);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazin'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.diamond, color: Color(0xFF80DEEA)),
                  const SizedBox(width: 4),
                  Text('$_diamonds',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2A4A), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: allPowers.length,
          itemBuilder: (ctx, i) {
            final pw = allPowers[i];
            final owned = _owned[pw.id] ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: pw.color),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: pw.color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(pw.icon, color: pw.color, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pw.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        Text(pw.description,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        if (owned > 0)
                          Text('Deținute: $owned',
                              style: TextStyle(
                                  color: pw.color, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pw.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => _buy(pw),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text('${pw.price}',
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

