import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';  // Ana ekrana yönlendirecek

class RelationshipStatusScreen extends StatefulWidget {
  const RelationshipStatusScreen({super.key});

  @override
  _RelationshipStatusScreenState createState() =>
      _RelationshipStatusScreenState();
}

class _RelationshipStatusScreenState extends State<RelationshipStatusScreen> {
  String _relationshipStatus = '';  // Varsayılan değer

  // İlişki durumu bilgisini kaydetme ve sonraki ekrana geçme
  Future<void> _saveRelationshipStatus() async {
    if (_relationshipStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ilişki durumunuzu seçin')),
      );
      return;
    }

    // İlişki durumu bilgisini kaydediyoruz
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('relationship_status', _relationshipStatus);

    // Ana ekrana yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İlişki Durumunu Seç')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Ortalamayı ekliyoruz
          children: [
            ...[
              'İlişkisi Var',
              'Nişanlı',
              'Evli',
              'İlişkisi Yok',
              'Boşanmış',
              'Dul',
              'Platonik',
              'Ayrılmış'
            ].map((status) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _relationshipStatus = status;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,  // %80 genişlik
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _relationshipStatus == status
                        ? Colors.blueAccent
                        : Colors.grey[700], // Seçili duruma göre renk
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,  // Metin rengi beyaz
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            // Devam Et butonu
            Container(
              width: MediaQuery.of(context).size.width * 0.9,  // Butonu genişlet
              height: 50,  // Butonun yüksekliği
              child: ElevatedButton(
                onPressed: _relationshipStatus.isEmpty
                    ? null
                    : _saveRelationshipStatus,  // Buton sadece seçim yapılınca aktif olacak
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,  // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Köşeleri yuvarlat
                  ),
                ),
                child: const Text('Devam Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
