import 'package:get/get.dart';
import '../models/ilce_model.dart'; // İlçe modeli
import '../models/okul_model.dart'; // Okul modeli
import '../services/api_service.dart'; // API servisi
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  var ilceler = <Ilce>[].obs; // İlçeleri tutuyoruz
  var okullar = <Okul>[].obs; // Okulları tutuyoruz
  var selectedIlce = ''.obs; // Seçili ilçe
  var isLoading = false.obs; // Yükleniyor durumu
  var searchController = TextEditingController(); // Arama alanı için controller

  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchIlceler(); // İlçeleri al
  }

  // İlçeleri API'den getir
  void fetchIlceler() async {
    try {
      isLoading(true);
      var jsonData = await apiService.fetchIlceler();
      if (jsonData != null && jsonData is List) {
        ilceler.value = jsonData.map((i) => Ilce.fromJson(i)).toList();
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'İlçeler yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Okulları seçilen ilçeye göre getir
  void fetchOkullar(String ilceId) async {
    try {
      isLoading(true);
      var jsonData = await apiService.fetchOkullar(ilceId);
      if (jsonData != null && jsonData is List) {
        okullar.value = jsonData.map((o) => Okul.fromJson(o)).toList();
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Okullar yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Okul ismine göre arama yap
  void searchSchools(String query) async {
  try {
    isLoading(true);
    var jsonData = await apiService.searchSchools(query);
    if (jsonData != null && jsonData is List) {
      okullar.value = jsonData.map((o) => Okul.fromJson(o)).toList();
    } else {
      print('Arama sonucu boş döndü.');
    }
  } catch (e) {
    Get.snackbar(
      'Hata',
      'Arama yapılırken bir hata oluştu: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading(false);
  }
}

  // Aramayı sıfırla
  void resetSearch() {
    searchController.clear();
    fetchOkullar(selectedIlce.value); // Seçili ilçeye göre okulları tekrar getir
  }

  // Arama alanını temizle ve listeyi sıfırla
  void clearSearch() {
    searchController.clear();
    resetSearch();
  }
}