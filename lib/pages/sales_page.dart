import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/services.dart';
import '../controllers/sales_controller.dart';
import '../models/sales_model.dart';

class SalesPage extends StatefulWidget {
  final int schoolId;
  final String schoolName;
  final Sales? sales;

  SalesPage({required this.schoolId, required this.schoolName, this.sales});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
   int? saleId = 0;
  final SalesController controller = Get.put(SalesController());
  final _formKey = GlobalKey<FormState>();

  late final MoneyMaskedTextController _priceController;
  late final MaskedTextController _phoneController;

  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _soldBookController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _returnsController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _desiredAuthorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _eventDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (widget.sales != null) {
      saleId = widget.sales?.id;
      _contactPersonController.text = widget.sales!.contactPerson;
      _phoneController = MaskedTextController(mask: '0000 000 00 00', text: widget.sales!.phone);
      _soldBookController.text = widget.sales!.soldBook;
      _quantityController.text = widget.sales!.quantity.toString();
      _priceController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',', initialValue: widget.sales!.price);
      _returnsController.text = widget.sales!.returns.toString();
      _discountController.text = widget.sales!.discountPercentage.toString();
      _desiredAuthorController.text = widget.sales!.desiredAuthor;
      _notesController.text = widget.sales!.notes;
      _eventDate = widget.sales!.eventDate;
    } else {
      _priceController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
      _phoneController = MaskedTextController(mask: '0000 000 00 00');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sales != null ? 'Veri Güncelleme' : 'Veri Girişi',style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blueGrey[900],
         flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Okul adı
                Center(
                  child: Text(
                    widget.schoolName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),

                // İletişim Kişisi
                _buildTextField(_contactPersonController, 'İletişim Kişisi', 'Lütfen bir isim giriniz'),

                // Telefon
                _buildMaskedTextField(_phoneController, 'Telefon', '0544 444 44 44', 14),

                // Satılan Kitap
                _buildTextField(_soldBookController, 'Satılan Kitap', 'Lütfen satılan kitabı giriniz'),

                // Miktar
                _buildTextField(_quantityController, 'Adet', 'Lütfen miktar giriniz', isNumeric: true),

                // Fiyat
                _buildTextField(_priceController, 'Fiyat', 'Lütfen fiyat giriniz', isNumeric: true),

                // İadeler
                _buildTextField(_returnsController, 'İadeler', null, isNumeric: true),

                // İndirim (%)
                _buildTextField(_discountController, 'İndirim (%)', null, isNumeric: true),

                // İstenen Yazar
                _buildTextField(_desiredAuthorController, 'İstenen Yazar', 'Lütfen yazar ismi giriniz'),

                // Tarih
                Text('Tarih: $_eventDate', style: TextStyle(fontSize: 16, color: Colors.grey[600])),

                // Notlar
                _buildTextField(_notesController, 'Notlar', null, maxLines: 3),

                SizedBox(height: 20),

                // Kaydet/Güncelle butonu
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.sales == null ? 'Kaydet' : 'Güncelle',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validationMessage,
      {bool isNumeric = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: const Color.fromARGB(255, 43, 56, 38)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey.shade900),
          ),
        ),
      ),
    );
  }

  Widget _buildMaskedTextField(MaskedTextController controller, String label, String placeholder, int maxLength) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          labelStyle: TextStyle(color: Colors.blueGrey[900]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey.shade900),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      Sales salesEntry = Sales(
        schoolId: widget.schoolId,
        contactPerson: _contactPersonController.text,
        phone: _phoneController.text,
        soldBook: _soldBookController.text,
        quantity: int.parse(_quantityController.text),
        price: _priceController.numberValue,
        returns: _returnsController.text.isNotEmpty ? int.parse(_returnsController.text) : 0,
        discountPercentage: _discountController.text.isNotEmpty ? int.parse(_discountController.text) : 0,
        desiredAuthor: _desiredAuthorController.text,
        eventDate: _eventDate,
        notes: _notesController.text,
      );

      if (widget.sales == null) {
        controller.apiService.addSale(salesEntry);
        Get.snackbar("Başarılı", "Veri başarıyla kaydedildi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Güncelleme işlemi
        controller.apiService.updateSale(salesEntry,saleId ?? 0);
        Get.snackbar("Başarılı", "Veri başarıyla güncellendi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Navigator.of(context).pop();
    }
  }
}