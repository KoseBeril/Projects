import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  // Render URL
  final String _baseUrl = "https://.onrender.com";
  final Dio _dio = Dio();

  /// 1. Fonksiyon: Seçilen resmin çözünürlüğünü alır
  Future<Map<String, dynamic>?> getImageResolution(File imageFile) async {
    try {
      // Resmi API'ye gönderebilmek için FormData formatına çeviriyoruz
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      // POST isteği atıyoruz
      Response response = await _dio.post(
        "$_baseUrl/get/resolution",
        data: formData,
      );

      if (response.statusCode == 200) {
        // Gelen veri: {"width": 1080, "height": 1920} şeklinde olacak
        return response.data;
      }
    } catch (e) {
      //print("Çözünürlük alma hatası: $e");
    }
    return null;
  }

  /// 2. Fonksiyon: Seçilen resmi siyah-beyaza çevirip yeni resmi binary (bytes) olarak indirir
  Future<List<int>?> convertToGrayscale(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      // Django bize direkt resmi (image file) binary olarak döneceği için
      // responseType'ı 'bytes' olarak ayarlıyoruz
      Response<List<int>> response = await _dio.post<List<int>>(
        "$_baseUrl/convert/grayscale",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Gelen resmin byte listesini döndürüyoruz
        return response.data;
      }
    } catch (e) {
      //print("Siyah-beyaz dönüştürme hatası: $e");
    }
    return null;
  }
}