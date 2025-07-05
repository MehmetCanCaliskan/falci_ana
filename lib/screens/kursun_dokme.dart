import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class KursunDokmeScreen extends StatefulWidget {
  const KursunDokmeScreen({super.key});

  @override
  State<KursunDokmeScreen> createState() => _KursunDokmeScreenState();
}

class _KursunDokmeScreenState extends State<KursunDokmeScreen> {
  bool _pressed = false;
  bool _showVideo = false;
  bool _showResult = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/kursun_dokme_ani.mp4')
      ..initialize().then((_) => setState(() {}))
      ..setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        _showVideo = true;
      });
      _controller.play();

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          setState(() {
            _showResult = true;
          });
        }
      });
    });
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
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  if (_showResult)
                    Positioned(
                      bottom: 40,
                      child: Text(
                        'Kurşun dökümü tamamlandı.\nNegatif enerji uzaklaştı.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : GestureDetector(
                onLongPressStart: (_) {
                  setState(() => _pressed = true);
                  _startTimer();
                },
                onLongPressEnd: (_) {
                  setState(() => _pressed = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _pressed ? 160 : 120,
                  height: _pressed ? 160 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.remove_red_eye, color: Colors.white, size: 50),
                  ),
                ),
              ),
      ),
    );
  }
}
