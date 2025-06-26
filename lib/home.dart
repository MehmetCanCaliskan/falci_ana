import 'dart:async'; // Timer için
import 'package:flutter/material.dart';
import 'coin_service.dart';
import 'screens/horoscope_screen.dart';
import 'screens/watch_ad_page.dart';
import 'screens/play_game_page.dart'; // import et
import 'screens/coffee_fortune_upload_screen.dart'; // Kahve Falı ekranını import ettik

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _coins = 20;
  int _selectedIndex = 0;
  String _infoMessage = '';  // Bilgilendirme mesajı
  int _countdown = 0;  // Geri sayım
  late Timer _timer;  // Timer nesnesi
  bool _isFortuneStarted = false;  // Fala bakma işlemi başladı mı?

  final List<Map<String, dynamic>> _fortunes = [
    {'title': 'Kahve Falı', 'icon': Icons.coffee},
    {'title': 'Tarot Falı', 'icon': Icons.auto_awesome},
    {'title': 'El Falı', 'icon': Icons.pan_tool},
    {'title': 'Katina Falı', 'icon': Icons.star},
    {'title': 'Yüz Falı', 'icon': Icons.face},
    {'title': 'Melek Kartları', 'icon': Icons.card_giftcard},
  ];

  @override
  void initState() {
    super.initState();
    _checkDailyBonus();
  }

  // Bilgilendirme mesajını yüklemek
  Future<void> _loadMessages() async {
    setState(() {
      _infoMessage = "Kahve falınız çıkmasına 14 dakika kaldı!";  // Bilgilendirme mesajı
      _countdown = 14 * 60;  // 14 dakika (840 saniye)
    });
    _startCountdown();
  }

  // Geri sayımı başlatma
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _infoMessage = '';  // Mesajı sıfırlıyoruz
        });
        _timer.cancel();
      }
    });
  }

  // Geri sayımı formatlayarak gösterme
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
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WatchAdPage()),
      );

      if (result == true) {
        final updatedCoins = await CoinService().getCoins();
        setState(() {
          _coins = updatedCoins;
        });
      }
    }
  }
}



  // Fal kartları
  Widget _buildFortuneCard(String title, IconData icon) => Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _onFortuneSelected(title),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      );

  // Alt navigasyon
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
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HoroscopeScreen()),
          );
        }

        if (index == 2) {
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
            // Bilgilendirme Paneli
            if (_isFortuneStarted)  // Fala bakma başladıysa
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orangeAccent,
                child: Text(
                  _infoMessage,  // Dinamik mesaj burada gösterilecek
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Geri sayım
            if (_countdown > 0)
              Text(
                'Kahve falınıza $_formattedTime kaldı!',
                style: const TextStyle(fontSize: 20),
              ),
            // Fal kartları
            Flexible(  // Değişiklik burada
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _fortunes
                    .map((f) => _buildFortuneCard(f['title'], f['icon']))
                    .toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
}
