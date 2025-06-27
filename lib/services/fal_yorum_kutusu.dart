import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FalYorumKutusu {
  static List<Map<String, dynamic>> _fallar = [];

  static Future<void> yukle() async {
    final data = await rootBundle.loadString('assets/config/fallar.json');
    _fallar = List<Map<String, dynamic>>.from(json.decode(data));
  }

  static String falAlProfilIle(String isDurumu, String iliskiDurumu) {
    final fal = _fallar.firstWhere(
      (f) => f['is_durumu'] == isDurumu && f['iliski_durumu'] == iliskiDurumu,
      orElse: () => {
        'fal_metni': 'Fincan sessiz ama gözlerin çok şey söylüyor...'
      },
    );
    return fal['fal_metni'] ?? 'Fal bulunamadı.';
  }
}
