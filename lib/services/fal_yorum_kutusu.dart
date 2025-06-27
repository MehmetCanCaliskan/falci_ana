import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FalYorumKutusu {
  static Map<String, List<String>> yorumlar = {};

  static Future<void> yukle() async {
    final data = await rootBundle.loadString('assets/config/fal_yorumlari_72.json');
    yorumlar = Map<String, List<String>>.from(
      json.decode(data).map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  static String falAlProfilIle(String isDurumu, String iliskiDurumu) {
    final key = "${isDurumu.toLowerCase()}_${iliskiDurumu.toLowerCase()}";
    final list = yorumlar[key] ?? ["Fincan sessiz ama gözlerin çok şey söylüyor..."];
    list.shuffle();
    return list.first;
  }
}
