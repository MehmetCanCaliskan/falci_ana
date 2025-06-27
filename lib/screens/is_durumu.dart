import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'iliski_durumu.dart';  // İlişki durumu ekranına yönlendirecek

class JobStatusScreen extends StatefulWidget {
  const JobStatusScreen({super.key});

  @override
  _JobStatusScreenState createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen> {
  String _jobStatus = '';  // Varsayılan değer

  // İş durumu bilgisini kaydetme ve sonraki ekrana geçme
  Future<void> _saveJobStatus() async {
    if (_jobStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen iş durumunu seçin')),
      );
      return;
    }

    // İş durumu bilgisini kaydediyoruz
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('job_status', _jobStatus);

    // İlişki durumu ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RelationshipStatusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İş Durumunu Seç')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Ortalamayı ekliyoruz
          children: [
            ...[
              'Ev hanımı',
              'Çalışmıyor',
              'İş arıyor',
              'Öğrenci',
              'Akademisyen',
              'Kendi işini yapıyor',
              'Kamu sektörü',
              'Özel sektör',
              'Emekli'
            ].map((status) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _jobStatus = status;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,  // %80 genişlik
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _jobStatus == status ? Colors.blueAccent : Colors.grey[700], // Seçili duruma göre renk
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
                onPressed: _jobStatus.isEmpty ? null : _saveJobStatus,  // Buton sadece seçim yapılınca aktif olacak
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
