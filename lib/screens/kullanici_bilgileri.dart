import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cinsiyet_secme.dart';  // Cinsiyet ekranına yönlendirecek

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;

  // Kullanıcı bilgilerini kaydetme
  Future<void> _saveInfo() async {
    if (_nameController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm bilgileri doldurun')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('birth_date', _birthDate!.toIso8601String());

    // Cinsiyet ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GenderScreen()),
    );
  }

  // Doğum tarihi seçme
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 20);
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bilgilerini Gir')), // const kaldırıldı
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration( // const kaldırıldı
                labelText: 'Adınız',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _birthDate == null
                    ? 'Doğum Tarihini Seç'
                    : 'Doğum Tarihi: ${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveInfo,
              child: const Text('Devam Et'),
            ),
          ],
        ),
      ),
    );
  }
}
