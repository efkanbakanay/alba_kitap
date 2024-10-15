import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/sales_controller.dart';
import '../models/okul_model.dart';
import '../models/sales_model.dart'; // Eklenen veriler için model
import '../pages/sales_page.dart';

class OkulListItem extends StatefulWidget {
  final Okul okul;
  final int? selectedSchoolId; // Seçili okul ID'si

  OkulListItem({required this.okul, this.selectedSchoolId});

  @override
  _OkulListItemState createState() => _OkulListItemState();
}

class _OkulListItemState extends State<OkulListItem> {
  
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedSchoolId == widget.okul.id;

    return Container(
      color: isSelected ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white,
      child: ListTile(
        title: Text(widget.okul.name),
        subtitle: Text(widget.okul.district),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return BottomSheetContent(
                okul: widget.okul,
                onSelected: () {
                  Navigator.of(context).pop(widget.okul.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  final Okul okul;
  final VoidCallback? onSelected;

  // SalesController'ı buraya inject ediyoruz
  final SalesController salesController = Get.put(SalesController());

  BottomSheetContent({required this.okul, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'Seçili Okul: ${okul.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // BottomSheet kapatılıyor
                  // Veri giriş sayfasına yönlendirme, okul adını da gönderiyoruz
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SalesPage(
                        schoolId: int.parse(okul.id), // ID'yi int'e çeviriyoruz
                        schoolName: okul.name, // Okul adını gönderiyoruz
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit),
                label: Text('Veri Girişi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Verileri gör modalını aç
                  showVerileriGorModal(context, int.parse(okul.id), okul.name); // ID'yi int'e çeviriyoruz
                },
                icon: Icon(Icons.visibility),
                label: Text('Verileri Gör'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (okul.location.isNotEmpty) {
                    launchUrl(Uri.parse(okul.location));
                  } else {
                    Get.snackbar(
                      "Hata",
                      "Yol tarifi için geçerli bir konum bulunamadı.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.directions),
                label: Text('Git'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

void showVerileriGorModal(BuildContext context, int schoolId, String schoolName) {
  // Verileri servisten çekiyoruz
  salesController.salesBySchoolId(schoolId).then((_) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Obx(() {
          if (salesController.isLoading.value) {
            // Yükleniyor animasyonu
            return Center(child: CircularProgressIndicator());
          } else if (salesController.salesList.isEmpty) {
            // Eğer salesList boşsa "Veri bulunamadı" mesajı göster
            return Center(child: Text('Veri bulunamadı'));
          } else {
            // Veriler geldiyse listeyi göster
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop(); // Modalı kapat
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            schoolName, // Okul adı başlık olarak yazdırılıyor
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Expanded ile ListView builder'ı sararak taşmayı önlüyoruz
                  Expanded(
                    child: ListView.builder(
                      itemCount: salesController.salesList.length, // Listede kaç eleman varsa
                      itemBuilder: (context, index) {
                        final sale = salesController.salesList[index]; // Her bir satış verisi
                        return ListTile(
                          title: Text("${sale.soldBook} - ${sale.contactPerson}"),
                          subtitle: Text("${sale.eventDate} - ${sale.notes}"),
                          onTap: () {
                            // Satış verisini SalesPage'e gönder
                            Navigator.of(context).pop(); // Modal'ı kapat
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SalesPage(
                                  schoolId: sale.schoolId,
                                  schoolName: schoolName,
                                  sales: sale, // Seçili veriyi SalesPage'e gönder
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  });
}
}