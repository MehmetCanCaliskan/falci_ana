import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FallarimPage extends StatefulWidget {
  const FallarimPage({super.key});

  @override
  State<FallarimPage> createState() => _FallarimPageState();
}

class _FallarimPageState extends State<FallarimPage> {
  List<Map<String, dynamic>> fallar = [];

  @override
  void initState() {
    super.initState();
    _loadFallar();
  }

  Future<void> _loadFallar() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('fallar') ?? [];

    final List<Map<String, dynamic>> parsed = saved.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    parsed.sort((a, b) => b['tarih'].compareTo(a['tarih'])); // En güncel üstte

    setState(() {
      fallar = parsed;
    });
  }

  bool _falAktifMi(String tarihStr) {
    final tarih = DateTime.parse(tarihStr);
    final fark = DateTime.now().difference(tarih).inMinutes;
    return fark >= 15;
  }

  String _formatTarih(String iso) {
    final date = DateTime.parse(iso);
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fallarım")),
      body: fallar.isEmpty
          ? const Center(child: Text("Henüz fal bakılmamış."))
          : ListView.builder(
              itemCount: fallar.length,
              itemBuilder: (context, index) {
                final fal = fallar[index];
                final aktif = _falAktifMi(fal['tarih']);
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${fal['tur']} - ${_formatTarih(fal['tarih'])}"),
                    subtitle: aktif
                        ? Text(fal['yorum'])
                        : const Text("Bu fal henüz açılmadı. Lütfen 15 dakika bekleyin."),
                    enabled: aktif,
                  ),
                );
              },
            ),
    );
  }
}
