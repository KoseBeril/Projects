import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart'; // URL'in burada tanımlı olsun
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> _performPlantIdentification(String filePath) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/upload');
  var request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('file', filePath));
  
  var response = await request.send().timeout(const Duration(seconds: 120));
  
  if (response.statusCode == 200) {
    String data = await response.stream.bytesToString();
    return json.decode(data);
  } else {
    throw Exception('Server recognition error: ${response.statusCode}');
  }
}

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;

  // Görevleri Çek (GET) --- günlük - haftalık görev oluşturma 
  Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // Chatbot (POST)
  Future<String> getChatReply(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"message": message}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['reply'];
    }
    return "Connection error.";
  }

  // Bitki Tanıma (POST - Multipart)
  Future<Map<String, dynamic>> identifyPlant(File imageFile) async {
    try {
      // compute kullanarak işi arka plana atıyoruz
      print("Request is being sent to: ${Uri.parse('$baseUrl/upload')}");
      return await compute(_performPlantIdentification, imageFile.path);
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception('Recognition failed.');
    }
  }

  //1. Çoklu görev ekleme (Weekly/Daily fark etmeksizin)
  Future<bool> addTasks(String name, List<String> dates) async {
  final response = await http.post(
    Uri.parse('$baseUrl/tasks'),
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      "name": name,
      "dates": dates, // Backend'de 'dates' anahtarını bekliyoruz
    }),
  );
  return response.statusCode == 201;
  }

  // 2. Belirli bir güne göre görevleri çekme (Filtreleme)
  Future<List<dynamic>> getTasksByDate(String date) async {
  // Backend'e URL üzerinden tarih gönderme (?date=YYYY-MM-DD)
  final response = await http.get(Uri.parse('$baseUrl/tasks?date=$date'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return [];
  }

  // Görev Sil (DELETE)
  // Backend tarafında @app.route('/tasks/<int:id>', methods=['DELETE']) olması gerekir
  Future<bool> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
    );
    return response.statusCode == 200;
  }
}