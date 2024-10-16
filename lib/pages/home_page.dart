import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/okul_list_item.dart';
import 'raporlar_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    RaporlarPage(),
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
        title: Text(
          'Alba Kitap Okul Listesi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.school, size: 28),
              label: 'Okullar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report, size: 28),
              label: 'Raporlar',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          backgroundColor: Colors.transparent,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İlçe Seçimi Dropdown
          Obx(() => DropdownButtonFormField<String>(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.location_city),
                  labelText: 'İlçe Seçiniz',
                ),
              )),
          SizedBox(height: 16),

          // Arama Alanı (X işareti olmadan)
          TextField(
            controller: controller.searchController,
            onChanged: (query) {
              if (query.isNotEmpty) {
                controller.searchSchools(query);
              } else {
                controller.resetSearch();
              }
            },
            decoration: InputDecoration(
              labelText: 'Okul Arayın',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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