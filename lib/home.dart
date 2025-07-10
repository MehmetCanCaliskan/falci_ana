import 'dart:async';
import 'package:flutter/material.dart';
import 'coin_service.dart';
import 'screens/burclar.dart';
import 'screens/watch_ad_page.dart';
import 'screens/play_game_page.dart';
import 'screens/kahve_fali.dart';
import 'screens/fallarim.dart';
import 'screens/fan_tarot_picker.dart';
import 'screens/kursun_dokme.dart';
import 'screens/oyunlar_menusu.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _coins = 20;
  int _selectedIndex = 0;
  String _infoMessage = '';
  int _countdown = 0;
  late Timer _timer;
  bool _isFortuneStarted = false;

  final List<Map<String, dynamic>> _fortunes = [
  {'title': 'Kahve Falı', 'image': 'assets/icons/coffee.png'},
  {'title': 'Tarot Falı', 'image': 'assets/icons/tarot.png'},
  {'title': 'Kurşun Dökme', 'image': 'assets/icons/kursun.png'},
  {'title': 'Melek Kartları', 'image': 'assets/icons/melek.png'},
];

  @override
  void initState() {
    super.initState();
    _checkDailyBonus();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _infoMessage = "Kahve falınız çıkmasına 14 dakika kaldı!";
      _countdown = 30;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _infoMessage = '';
        });
        _timer.cancel();
      }
    });
  }

  String get _formattedTime {
    int minutes = _countdown ~/ 60;
    int seconds = _countdown % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _checkDailyBonus() async {
    final bonusGiven = await CoinService().addDailyLoginBonus();
    final current = await CoinService().getCoins();
    setState(() {
      _coins = current;
    });

    if (bonusGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Günlük giriş bonusu: +1 jeton 🎉')),
      );
    }
  }

  Future<void> _onFortuneSelected(String title) async {
    if (title == 'Kahve Falı') {
      final currentCoins = await CoinService().getCoins();

      if (currentCoins >= 10) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoffeeFortuneUploadScreen()),
        );
        final updatedCoins = await CoinService().getCoins();
        setState(() {
          _coins = updatedCoins;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeterli jetonunuz yok!')),
        );
      }
    } else if (title == 'Tarot Falı') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FanTarotPickerPage()),
      );
    } else if (title == 'Kurşun Dökme') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KursunDokmeScreen()),
      );
    }
  }

  Widget _buildFortuneCard(String title, String imagePath) => Card(
    elevation: 2,
    child: InkWell(
      onTap: () => _onFortuneSelected(title),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.7; // %70 boyut

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: iconSize, height: iconSize),
              const SizedBox(height: 8),
              Text(title),
            ],
          );
        },
      ),
    ),
  );


  Widget _buildBottomNavigationBar() => BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() => _selectedIndex = index);

          if (index == 4) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WatchAdPage()),
            );

            if (result == true) {
              final current = await CoinService().getCoins();
              setState(() {
                _coins = current;
              });
            }
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HoroscopeScreen()),
            );
          } else if (index == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayGamePage()),
            );

            if (result == true) {
              final current = await CoinService().getCoins();
              setState(() {
                _coins = current;
              });
            }
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FallarimPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Fallarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Çiftlik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Burçlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'Premium',
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Fal Uygulaması'),
          leading: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
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
            if (_isFortuneStarted)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orangeAccent,
                child: Text(
                  _infoMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_countdown > 0)
              Text(
                'Kahve falınıza $_formattedTime kaldı!',
                style: const TextStyle(fontSize: 20),
              ),
            Flexible(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _fortunes
                    .map((f) => _buildFortuneCard(f['title'], f['image']))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OyunlarMenusuPage()),
                  );
                },
                icon: const Icon(Icons.videogame_asset),
                label: const Text("🎮 Oyna ve Jeton Kazan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(),
      );
}
