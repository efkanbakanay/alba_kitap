import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sales_model.dart';

class ApiService {
  static const String baseUrl = 'http://albakitap.com/api';
  static const Map<String, String> headers = {
    'Authorization': 'apikey c9b52897-06c5-468c-8b29-04232e796931',
    'Content-Type': 'application/json',
  };

  // İlçeleri API'den çekme
  Future<List<dynamic>> fetchIlceler() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/districts'), headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("İlçeler yüklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bir hata oluştu: $e");
    }
  }

  // Seçilen ilçeye göre okulları API'den çekme
  Future<List<dynamic>> fetchOkullar(String ilceId) async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/schools?district=$ilceId'), headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Okullar yüklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bir hata oluştu: $e");
    }
  }

 Future<List<dynamic>?> searchSchools(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schools?name=$query'),
        headers:headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Unauthorized hatası
        throw 'Yetkilendirme Hatası.';
      } else {
        // Diğer hata durumları
        throw 'Hata : ${response.statusCode}';
      }
    } catch (e) {
      throw 'Servis Hatası : $e'; // Hata mesajı döndürülüyor
    }
  }

   Future<List<dynamic>?> salesBySchoolId(int schoolId) async {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/$schoolId'),
        headers:headers,
      );

    if (response.statusCode == 200) {
       return json.decode(response.body);
    } else {
      print('API Error: ${response.body}'); // Hata durumunu loglama
      throw Exception('Veriler alınamadı');
    }
  }

    Future<Map<String, dynamic>?> addSale(Sales entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_sale'), headers: headers,
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode == 200) {
      // Başarılı ise response'u geri döndür
      return json.decode(response.body);
    } else {
      // Hata durumunda null dön
      print('Veri gönderilemedi: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateSale(Sales entry, int saleId) async {
  final response = await http.put(
    Uri.parse('$baseUrl/update_sale/${saleId}'), // Belirli bir satış için ID kullanarak güncelleme yapılıyor
    headers: headers,
    body: json.encode(entry.toJson()),
  );

  if (response.statusCode == 200) {
    // Başarılı ise response'u geri döndür
    return json.decode(response.body);
  } else {
    // Hata durumunda null dön
    print('Veri güncellenemedi: ${response.body}');
    return null;
  }
}
}
