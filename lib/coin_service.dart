import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinKey = 'user_coins';
  static const String _lastLoginKey = 'last_login_date';

  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 20; // ilk girişte 20 coin
  }

  Future<void> setCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinKey, coins);
  }

  Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await setCoins(current + amount);
  }

  Future<bool> deductCoins(int amount) async {
    final current = await getCoins();
    if (current >= amount) {
      await setCoins(current - amount);
      return true;
    }
    return false;
  }

  Future<bool> addDailyLoginBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastLogin = prefs.getString(_lastLoginKey);

    if (lastLogin != null) {
      final lastLoginDate = DateTime.tryParse(lastLogin);
      if (lastLoginDate != null &&
          lastLoginDate.year == today.year &&
          lastLoginDate.month == today.month &&
          lastLoginDate.day == today.day) {
        return false; // aynı gün tekrar giriş yapmış, bonus verme
      }
    }

    // yeni gün: bonus ver
    await addCoins(1);
    await prefs.setString(_lastLoginKey, today.toIso8601String());
    return true;
  }
  

}
