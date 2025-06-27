import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FalService {
  static Future<String?> getFalMetni({
    required String isDurumu,
    required String iliskiDurumu,
    required String kullaniciAdi,
  }) async {
    final jsonString = await rootBundle.loadString('assets/fallar.json');
    final jsonData = json.decode(jsonString);

    final fallar = jsonData['fallar'] as List;

    // Uygun falı bul
    final uygunFallar = fallar.where((fal) =>
      fal['is_durumu'] == isDurumu && fal['iliski_durumu'] == iliskiDurumu).toList();

    if (uygunFallar.isNotEmpty) {
      final randomFal = (uygunFallar..shuffle()).first;
      String metin = randomFal['fal_metni'];
      return metin.replaceAll('[Kullanıcı Adı]', kullaniciAdi);
    } else {
      return null;
    }
  }

  static Future<void> kaydetFal({
    required String falTuru,
    required String metin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tarih = DateTime.now().toIso8601String();
    final yeniFal = {
      'fal_turu': falTuru,
      'metin': metin,
      'tarih': tarih,
    };

    final eskiFallarString = prefs.getStringList('fallar') ?? [];
    final yeniFallarString = [json.encode(yeniFal), ...eskiFallarString];

    // Maksimum 30 kayıt tut
    prefs.setStringList('fallar', yeniFallarString.take(30).toList());
  }

  static Future<List<Map<String, dynamic>>> getirFallar() async {
    final prefs = await SharedPreferences.getInstance();
    final fallarString = prefs.getStringList('fallar') ?? [];
    return fallarString.map((f) => json.decode(f) as Map<String, dynamic>).toList();
  }
}
