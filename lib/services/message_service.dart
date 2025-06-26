import 'dart:convert';
import 'package:flutter/services.dart';

class MessageService {
  Future<Map<String, dynamic>> loadMessages() async {
    String jsonString = await rootBundle.loadString('assets/config/messages.json');
    final Map<String, dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse;
  }
}
