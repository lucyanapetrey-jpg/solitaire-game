import 'package:shared_preferences/shared_preferences.dart';

class RewardsService {
  static const _kDiamondsKey = 'diamonds';
  static const _kLastLoginKey = 'lastLoginEpoch';
  static const _kStreakKey = 'loginStreak';
  static const _kMissionsKey = 'missionsState';

  // Daily reward in diamonds for streak day 1..7
  static const dailyRewards = [10, 15, 25, 40, 60, 90, 150];

  Future<int> getDiamonds() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kDiamondsKey) ?? 50; // start with 50
  }

  Future<void> addDiamonds(int n) async {
    final p = await SharedPreferences.getInstance();
    final cur = await getDiamonds();
    await p.setInt(_kDiamondsKey, cur + n);
  }

  Future<bool> spendDiamonds(int n) async {
    final cur = await getDiamonds();
    if (cur < n) return false;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kDiamondsKey, cur - n);
    return true;
  }

  /// Returns reward (in diamonds) if user qualifies for daily bonus, 0 otherwise
  Future<({int day, int reward})> claimDailyIfAvailable() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastEpoch = p.getInt(_kLastLoginKey);
    final streak = p.getInt(_kStreakKey) ?? 0;

    if (lastEpoch != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastEpoch);
      final lastDay = DateTime(last.year, last.month, last.day);
      if (lastDay.isAtSameMomentAs(today)) {
        // already claimed
        return (day: streak, reward: 0);
      }
      final diff = today.difference(lastDay).inDays;
      final newStreak = (diff == 1 ? streak + 1 : 1).clamp(1, 7);
      final reward = dailyRewards[newStreak - 1];
      await addDiamonds(reward);
      await p.setInt(_kLastLoginKey, today.millisecondsSinceEpoch);
      await p.setInt(_kStreakKey, newStreak);
      return (day: newStreak, reward: reward);
    } else {
      final reward = dailyRewards[0];
      await addDiamonds(reward);
      await p.setInt(_kLastLoginKey, today.millisecondsSinceEpoch);
      await p.setInt(_kStreakKey, 1);
      return (day: 1, reward: reward);
    }
  }

  Future<int> getCurrentStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kStreakKey) ?? 0;
  }
}

class Mission {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int target;
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.target,
  });
}

class MissionsService {
  // Persistent: progress[id] = current count, claimed[id] = bool
  Future<Map<String, int>> getProgress() async {
    final p = await SharedPreferences.getInstance();
    final out = <String, int>{};
    for (final k in p.getKeys()) {
      if (k.startsWith('mission_p_')) {
        out[k.substring('mission_p_'.length)] = p.getInt(k) ?? 0;
      }
    }
    return out;
  }

  Future<bool> isClaimed(String id) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('mission_c_$id') ?? false;
  }

  Future<void> setClaimed(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('mission_c_$id', true);
  }

  Future<int> increment(String id, [int amount = 1]) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt('mission_p_$id') ?? 0;
    final newVal = cur + amount;
    await p.setInt('mission_p_$id', newVal);
    return newVal;
  }
}
