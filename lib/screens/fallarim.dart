import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FallarimPage extends StatefulWidget {
  const FallarimPage({Key? key}) : super(key: key);

  @override
  _FallarimPageState createState() => _FallarimPageState();
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
    final falJsonList = prefs.getStringList('fallar') ?? [];

    final loadedFallar = falJsonList
        .map((falString) => json.decode(falString) as Map<String, dynamic>)
        .toList();

    // En günceli en üste koy
    loadedFallar.sort((a, b) =>
        DateTime.parse(b['tarih']).compareTo(DateTime.parse(a['tarih'])));

    setState(() {
      fallar = loadedFallar.take(30).toList(); // son 30 fal
    });
  }

  bool _isAcikMi(DateTime tarih) {
    final now = DateTime.now();
    return now.difference(tarih).inMinutes >= 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fallarım')),
      body: ListView.builder(
        itemCount: fallar.length,
        itemBuilder: (context, index) {
          final fal = fallar[index];
          final tarih = DateTime.parse(fal['tarih']);
          final acikMi = _isAcikMi(tarih);

          return ListTile(
            title: Text("${fal['tur']} - ${_formatTarihSaat(tarih)}"),
            subtitle: Text(acikMi
                ? 'Fal hazır, dokunup açabilirsin'
                : 'Hazırlanıyor... (${15 - DateTime.now().difference(tarih).inMinutes} dk kaldı)'),
            trailing: Icon(acikMi ? Icons.visibility : Icons.lock),
            onTap: acikMi
                ? () {
                    // Fal içeriği gösterilebilir
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(fal['tur']),
                        content: Text(fal['yorum']),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Kapat"))
                        ],
                      ),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }

  String _formatTarihSaat(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
