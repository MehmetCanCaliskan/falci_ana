import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class KursunDokmeScreen extends StatefulWidget {
  const KursunDokmeScreen({super.key});

  @override
  State<KursunDokmeScreen> createState() => _KursunDokmeScreenState();
}

class _KursunDokmeScreenState extends State<KursunDokmeScreen> with TickerProviderStateMixin
 {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _pressed = false;
  bool _showVideo = false;
  bool _showResult = false;
  String _falYorumu = '';
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('KursunDokmeScreen initState');

    _controller = VideoPlayerController.asset('assets/videos/kursun_dokme_ani.mp4')
      ..setLooping(false);

    _controller.addListener(() async {
      if (!_controller.value.isInitialized) return;

      final isFinished = _controller.value.position >= _controller.value.duration;
      debugPrint('Video kontrol listener: position=${_controller.value.position}, duration=${_controller.value.duration}');

      if (isFinished && !_showResult) {
        debugPrint('Video tamamlandı, fal yükleniyor...');
        final yorum = await _getFalYorumu();
        setState(() {
          _falYorumu = yorum;
          _showResult = true;
        });
        debugPrint('Fal gösterildi: $_falYorumu');
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    debugPrint('dispose çalıştı');
    _controller.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    debugPrint('Start timer başladı');

    Future.delayed(const Duration(seconds: 7), () async {
      debugPrint('7 saniye sonra video initialize edilmeye çalışılıyor');

      try {
        await _controller.initialize();
        debugPrint('Video initialize tamam');
        setState(() {
          _showVideo = true;
        });
        _controller.play();
        debugPrint('Video oynatılıyor');
      } catch (e) {
        debugPrint('Video başlatılamadı: $e');
      }
    });
  }

  Future<String> _getFalYorumu() async {
    final prefs = await SharedPreferences.getInstance();
    final job = prefs.getString('job_status') ?? 'Çalışmıyor';
    final relationship = prefs.getString('relationship_status') ?? 'İlişkisi Yok';

    debugPrint('SharedPreferences -> job: $job, ilişki: $relationship');

    try {
      final jsonString =
          await rootBundle.loadString('assets/kursun/kursun_fali_yorumlari.json');
      final List<dynamic> data = json.decode(jsonString);
      debugPrint('JSON okundu, veri sayısı: ${data.length}');

      final Map<String, dynamic> matched = data.firstWhere(
        (item) =>
            item['is_durumu'] == job &&
            item['iliski_durumu'] == relationship,
        orElse: () {
          debugPrint('Eşleşme yok, varsayılan fal verildi');
          return {
            'fal_metni': 'Bugün sana özel simgelerle dolu bir kurşun dökümü gerçekleşti.'
          };
        },
      );

      return matched['fal_metni'] ?? 'Fal metni bulunamadı.';
    } catch (e) {
      debugPrint('JSON okuma hatası: $e');
      return 'Fal metni yüklenirken hata oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _showVideo
            ? Stack(
                alignment: Alignment.center,
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const CircularProgressIndicator(),
                  if (_showResult)
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      top: 40,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _falYorumu,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : GestureDetector(
                onLongPressStart: (_) {
                  debugPrint('Uzun basma başladı');
                  setState(() => _pressed = true);
                  _startTimer();
                },
                onLongPressEnd: (_) {
                  debugPrint('Uzun basma bitti');
                  setState(() => _pressed = false);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Center(
                              child: Icon(Icons.remove_red_eye,
                                  color: Colors.white, size: 50),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        '7 saniye boyunca basılı tut',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
