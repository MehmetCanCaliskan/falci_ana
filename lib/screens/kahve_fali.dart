import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../coin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fal_yorum_kutusu.dart';
import 'dart:convert';
import '../services/fal_servisi.dart';
import '../home.dart'; // <- EKLENDİ: HomePage yönlendirmesi için

class CoffeeFortuneUploadScreen extends StatefulWidget {
  const CoffeeFortuneUploadScreen({super.key});

  @override
  _CoffeeFortuneUploadScreenState createState() =>
      _CoffeeFortuneUploadScreenState();
}

class _CoffeeFortuneUploadScreenState extends State<CoffeeFortuneUploadScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile>(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () async {
                final XFile? file =
                    await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                final XFile? file =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        if (_images.length < 3) {
          _images.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _falaBakVeKaydet() async {
    final prefs = await SharedPreferences.getInstance();

    final isDurumu = prefs.getString('is_durumu') ?? 'İş arıyor';
    final iliskiDurumu = prefs.getString('iliski_durumu') ?? 'İlişkisi Yok';
    final kullaniciAdi = prefs.getString('user_name') ?? 'Sevgili Kullanıcı';

    final yorum = await FalService.getFalMetni(
      isDurumu: isDurumu,
      iliskiDurumu: iliskiDurumu,
      kullaniciAdi: kullaniciAdi,
    );

    if (yorum != null) {
      await FalService.kaydetFal(
        falTuru: 'Kahve Falı',
        metin: yorum,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kahve Falı Fotoğrafları')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _images.length > index
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _images[index],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.black,
                          ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_images.isNotEmpty) {
                      bool success = await CoinService().deductCoins(10);
                      if (success) {
                        await _falaBakVeKaydet();

                        if (!mounted) return; // Widget hâlâ hayattaysa

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Yeterli jetonunuz yok!')),
                        );
                      }
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen en az bir fotoğraf yükleyin')),
                      );
                    }
                  },

                  child: const Text('Fala Bak'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
