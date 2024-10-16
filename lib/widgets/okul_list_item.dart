import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/sales_controller.dart';
import '../models/okul_model.dart';
import '../models/sales_model.dart';
import '../pages/sales_page.dart';

class OkulListItem extends StatefulWidget {
  final Okul okul;
  final int? selectedSchoolId;

  OkulListItem({required this.okul, this.selectedSchoolId});

  @override
  _OkulListItemState createState() => _OkulListItemState();
}

class _OkulListItemState extends State<OkulListItem> {
  
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedSchoolId == widget.okul.id;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListTile(
        title: Text(widget.okul.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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

  final SalesController salesController = Get.put(SalesController());

  BottomSheetContent({required this.okul, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Okul adı
      Text(
        '${okul.name}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20, // Daha büyük ve şık font
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 16),

      // Tatlı bir çizgi
      Divider(
        color: Colors.grey.shade300,
        thickness: 2,
        indent: 30,
        endIndent: 30,
      ),
      SizedBox(height: 16),

      // Butonlar
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCustomActionButton(
            context,
            'Veri Girişi',
            Icons.edit,
            Color(0xFF4CAF50), // Uyumlu yeşil renk
            () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SalesPage(
                    schoolId: int.parse(okul.id),
                    schoolName: okul.name,
                  ),
                ),
              );
            },
          ),
          _buildCustomActionButton(
            context,
            'Verileri Gör',
            Icons.visibility,
            Color(0xFF2196F3), // Uyumlu mavi renk
            () {
              showVerileriGorModal(context, int.parse(okul.id), okul.name);
            },
          ),
          _buildCustomActionButton(
            context,
            'Git',
            Icons.directions,
            Color(0xFFF57C00), // Uyumlu turuncu renk
            () {
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
          ),
        ],
      ),
    ],
  ),
);
  }

// Custom Buton Oluşturucu
Widget _buildCustomActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 24),
    label: Text(
      label,
      style: TextStyle(fontSize: 14),
    ),
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), backgroundColor: color, // İkon ve yazı rengi beyaz
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Buton köşeleri yuvarlatıldı
      ),
      elevation: 5, // Hafif gölge
    ),
  );
}

  void showVerileriGorModal(BuildContext context, int schoolId, String schoolName) {
    salesController.salesBySchoolId(schoolId).then((_) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Obx(() {
            if (salesController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if (salesController.salesList.isEmpty) {
              return Center(child: Text('Veri bulunamadı'));
            } else {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              schoolName,
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: salesController.salesList.length,
                        itemBuilder: (context, index) {
                          final sale = salesController.salesList[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                "${sale.soldBook} - ${sale.contactPerson}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("${sale.eventDate} - ${sale.notes}"),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SalesPage(
                                      schoolId: sale.schoolId,
                                      schoolName: schoolName,
                                      sales: sale,
                                    ),
                                  ),
                                );
                              },
                            ),
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