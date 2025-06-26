import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../coin_service.dart';
import '../utils/zodiac_utils.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  late String _userZodiac;
  late DateTime _birthDate;
  String? _selectedSign;
  int _coins = 0;

  final Map<String, String> _dailyHoroscopes = {
    'Koç': 'Enerjik bir gün seni bekliyor!',
    'Boğa': 'Sabırlı olman gereken bir gün.',
    'İkizler': 'Yeni fikirlere açık ol.',
    'Yengeç': 'Duygusal dengen önemli olacak.',
    'Aslan': 'Liderlik yeteneklerini gösterme zamanı.',
    'Başak': 'İşlerinde titiz davranmalısın.',
    'Terazi': 'Dengeyi bulmak için iyi bir gün.',
    'Akrep': 'Tutkuların seni yönlendirebilir.',
    'Yay': 'Yeni maceralara hazır ol.',
    'Oğlak': 'Çalışkanlığın meyvesini alabilirsin.',
    'Kova': 'Farklı düşünceler seni öne çıkaracak.',
    'Balık': 'Hayal gücün zirvede olacak.'
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateStr = prefs.getString('birth_date');
    final coins = await CoinService().getCoins();

    if (birthDateStr != null) {
      final birthDate = DateTime.parse(birthDateStr);
      final zodiac = getZodiacSign(birthDate);
      setState(() {
        _birthDate = birthDate;
        _userZodiac = zodiac;
        _coins = coins;
      });
    }
  }

  Future<void> _showHoroscope(String sign) async {
    if (sign == _userZodiac) {
      _showDialog(sign, free: true);
    } else {
      final success = await CoinService().deductCoins(10);
      if (success) {
        setState(() {
          _coins -= 10;
        });
        _showDialog(sign, free: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yetersiz jeton!')),
        );
      }
    }
  }

  void _showDialog(String sign, {required bool free}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$sign Burcu Yorumu'),
        content: Text(_dailyHoroscopes[sign] ?? 'Yorum bulunamadı.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Burç Yorumları'),
          actions: [
            Row(
              children: [
                const Icon(Icons.monetization_on),
                const SizedBox(width: 4),
                Text('$_coins'),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Senin burcun: $_userZodiac',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _dailyHoroscopes.keys.map((sign) {
                  final isFree = sign == _userZodiac;
                  return GestureDetector(
                    onTap: () => _showHoroscope(sign),
                    child: Card(
                      elevation: 3,
                      color: isFree ? Colors.green[100] : null,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sign, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            if (!isFree) const Text('10 Jeton'),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
}
