import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FalService {
  static Future<String?> getFalMetni({
    required String isDurumu,
    required String iliskiDurumu,
    required String kullaniciAdi,
  }) async {
    final jsonString = await rootBundle.loadString('assets/config/fallar.json');
    final List<dynamic> fallar = json.decode(jsonString);

    // Uygun falı bul
    final uygunFallar = fallar.where((fal) =>
      fal['is_durumu'] == isDurumu && fal['iliski_durumu'] == iliskiDurumu).toList();
    
    
    // 🐞 Debug için buraya ekle:
    print('🧪 is_durumu: $isDurumu');
    print('🧪 iliski_durumu: $iliskiDurumu');
    print('🧪 Eşleşen fal sayısı: ${uygunFallar.length}');

    
    if (uygunFallar.isNotEmpty) {
      uygunFallar.shuffle(); // Rastgele seçmek için
      final metin = uygunFallar.first['fal_metni'];
      return metin.replaceAll('[Kullanıcı Adı]', kullaniciAdi);
    } else {
      return 'Fincan sessiz ama gözlerin çok şey söylüyor...';
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

    prefs.setStringList('fallar', yeniFallarString.take(30).toList());
  }

  static Future<List<Map<String, dynamic>>> getirFallar() async {
    final prefs = await SharedPreferences.getInstance();
    final fallarString = prefs.getStringList('fallar') ?? [];
    return fallarString.map((f) => json.decode(f) as Map<String, dynamic>).toList();
  }
}
