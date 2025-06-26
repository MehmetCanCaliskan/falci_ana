import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_status_screen.dart';  // İş durumu ekranına yönlendirecek

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String _gender = 'Male';  // Default değer

  // Cinsiyet bilgisini kaydetme ve sonraki ekrana geçme
  Future<void> _saveGender() async {
    if (_gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen cinsiyetinizi seçin')),
      );
      return;
    }

    // Cinsiyet bilgisini kaydediyoruz
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', _gender);

    // İş durumu ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JobStatusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cinsiyet Seçin')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Ortalamayı ekliyoruz
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Ortalama
              children: [
                // Kadın butonu
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: _gender == 'Female' ? Colors.pinkAccent : Colors.grey[700], // Kadın butonu pembe
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.female, size: 50, color: Colors.white), // Kadın simgesi beyaz
                        Text('Kadın', style: TextStyle(fontSize: 16, color: Colors.white)), // Kadın metni beyaz
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Erkek butonu
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: _gender == 'Male' ? Colors.blueAccent : Colors.grey[700], // Erkek butonu mavi
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.male, size: 50, color: Colors.white), // Erkek simgesi beyaz
                        Text('Erkek', style: TextStyle(fontSize: 16, color: Colors.white)), // Erkek metni beyaz
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // LGBTQ seçeneği
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Ortalama
              children: [
                Checkbox(
                  value: _gender == 'LGBTQ',
                  onChanged: (bool? value) {
                    setState(() {
                      _gender = 'LGBTQ';
                    });
                  },
                ),
                const Text('LGBTQ', style: TextStyle(color: Colors.white)), // Metin beyaz
              ],
            ),
            const SizedBox(height: 20),
            // Devam Et butonu
            Container(
              width: MediaQuery.of(context).size.width * 0.9,  // Butonu genişlet
              height: 50,  // Butonun yüksekliği
              child: ElevatedButton(
                onPressed: _saveGender,
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
