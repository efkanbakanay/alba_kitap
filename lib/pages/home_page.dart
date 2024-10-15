import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/okul_list_item.dart'; // Controller sınıfı
import 'raporlar_page.dart'; // Raporlar sayfası

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  int _selectedIndex = 0; // Hangi menünün seçili olduğunu tutan index
  final List<Widget> _pages = [
    HomeContent(), // Ana sayfa içeriği
    RaporlarPage(), // Raporlar sayfası
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alba Kitap Okul Listesi'),
      ),
      body: _pages[_selectedIndex], // Seçilen sayfa
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Okullar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Raporlar',
          ),
        ],
        currentIndex: _selectedIndex, // Seçilen menü
        selectedItemColor: Colors.blueAccent, // Seçili öğe rengi
        unselectedItemColor: Colors.grey, // Seçilmeyen öğe rengi
        backgroundColor: Colors.white, // Arka plan rengi
        onTap: _onItemTapped, // Menüye tıklandığında ne olacağı
        type: BottomNavigationBarType.fixed, // Sabit menü tipi
      ),
    );
  }
}

// Ana içerik kısmını ayrı bir widget olarak ayırdım
class HomeContent extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // İlçe Seçimi Dropdown
          Obx(() => DropdownButton<String>(
                value: controller.selectedIlce.value.isEmpty
                    ? null
                    : controller.selectedIlce.value,
                hint: Text('İlçe Seçiniz'),
                items: controller.ilceler.map((ilce) {
                  return DropdownMenuItem<String>(
                    value: ilce.district,
                    child: Text(ilce.district),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedIlce.value = value!;
                  controller.fetchOkullar(value);
                },
              )),
          SizedBox(height: 16),

          // Arama Alanı (X işareti olmadan)
          TextField(
            controller: controller.searchController,
            onChanged: (query) {
              if (query.isNotEmpty) {
                controller.searchSchools(query); // API'den arama yap
              } else {
                controller.resetSearch(); // Arama kutusu boşsa listeyi sıfırla
              }
            },
            decoration: InputDecoration(
              labelText: 'Okul Arayın',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Listeyi Gösterme
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.okullar.isEmpty) {
                return Center(child: Text('Okul Bulunamadı'));
              } else {
                return ListView.builder(
                  itemCount: controller.okullar.length,
                  itemBuilder: (context, index) {
                    return OkulListItem(okul: controller.okullar[index]);
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}