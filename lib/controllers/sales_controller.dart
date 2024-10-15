import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sales_model.dart';
import '../services/api_service.dart';

class SalesController extends GetxController {
  final isLoading = false.obs;
   var salesList = <Sales>[].obs;

  // Servis çağrısı için SalesService
  final ApiService apiService = ApiService();

  // Formu kaydetme fonksiyonu
  Future<bool> saveSales(Sales salesEntry) async {
    try {
      isLoading(true); // Kaydetme işlemi başlıyor
       var response = await apiService.addSale(salesEntry);
      if (response != null) {
        Get.snackbar("Başarılı", "Veri başarıyla kaydedildi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar("Hata", "Veri kaydedilemedi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Hata", "Bir hata oluştu: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false); // Kaydetme işlemi sona erdi
    }
    return false;
  }

   Future<void> salesBySchoolId(int schoolId) async {
    try {
      isLoading(true);
      var jsonData = await apiService.salesBySchoolId(schoolId);
      if (jsonData != null && jsonData is List) {
      var data = jsonData.map((o) => Sales.fromJson(o)).toList();
      salesList.value = data;
    } else {
      print('Arama sonucu boş döndü.');
    }
    } catch (e) {
      print(e);
      Get.snackbar("Hata", "Veriler alınamadı");
    } finally {
      isLoading(false);
    }
  }
}