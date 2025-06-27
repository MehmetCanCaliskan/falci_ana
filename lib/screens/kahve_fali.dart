import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../coin_service.dart'; // CoinService'yi import ettik

class CoffeeFortuneUploadScreen extends StatefulWidget {
  const CoffeeFortuneUploadScreen({super.key});

  @override
  _CoffeeFortuneUploadScreenState createState() =>
      _CoffeeFortuneUploadScreenState();
}

class _CoffeeFortuneUploadScreenState extends State<CoffeeFortuneUploadScreen> {
  List<File> _images = [];  // Yüklenen fotoğrafların listesi
  final ImagePicker _picker = ImagePicker();

  // Fotoğraf seçmek için kamera veya galeriden seçme
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
                final XFile? file = await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, file);  // Kameradan fotoğrafı alıyoruz ve ekrana geri dönüyoruz
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, file);  // Galeriden fotoğrafı alıyoruz ve ekrana geri dönüyoruz
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        if (_images.length < 3) {
          _images.add(File(pickedFile.path));  // Fotoğrafı listeye ekliyoruz
        }
      });
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
            // Fotoğraf kutuları (3 kare şeklinde köşeleri yuvarlatılmış)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: _pickImage,  // Fotoğraf kutusuna tıklayınca fotoğraf yüklenir
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),  // Yuvarlatılmış köşeler
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
            // "Fala Bak" butonunu alt kısma yerleştirme
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // %90 genişlik
                child: ElevatedButton(
                  onPressed: () async {
                    if (_images.isNotEmpty) {
                      // Fotoğraf yüklendikten sonra jeton düşürme
                      bool success = await CoinService().deductCoins(10); // 10 jeton düşürme
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Falınız hazırlanıyor...')),
                        );

                        Navigator.pop(context);  // Ana ekrana geri dön
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Yeterli jetonunuz yok!')),
                        );
                      }
                    } else {
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
