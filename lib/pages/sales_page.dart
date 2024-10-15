import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Maskeleme için
import 'package:flutter/services.dart'; // inputFormatter için
import '../controllers/sales_controller.dart';
import '../models/sales_model.dart';

class SalesPage extends StatefulWidget {
  final int schoolId;
  final String schoolName; // Okul adı parametresi
  final Sales? sales; // Var olan veri için Sales nesnesi

  SalesPage({required this.schoolId, required this.schoolName, this.sales});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesController controller = Get.put(SalesController());
  final _formKey = GlobalKey<FormState>();

  // Masked Controllers
  late final MoneyMaskedTextController _priceController;
  late final MaskedTextController _phoneController;

  // Diğer controllerlar
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _soldBookController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _returnsController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _desiredAuthorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _eventDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Günün tarihini alıyoruz

  @override
  void initState() {
    super.initState();

    // Eğer mevcut bir sales verisi varsa formlar dolduruluyor
    if (widget.sales != null) {
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
        title: Text(widget.sales != null ? 'Veri Güncelleme' : 'Veri Girişi'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Geri butonu
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Okul adını formun üstüne ortalayarak yerleştiriyoruz
              Center(
                child: Text(
                  widget.schoolName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
              SizedBox(height: 20),

              // İletişim Kişisi
              _buildTextField(_contactPersonController, 'İletişim Kişisi', 'Lütfen bir isim giriniz'),

              // Telefon Numarası (Masked) + Placeholder
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefon',
                  hintText: '0544 444 44 44', // Placeholder
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir telefon numarası giriniz';
                  }
                  if (value.length != 14) { // Maskeleme ile 14 karakter kontrolü
                    return 'Geçerli bir telefon numarası girin';
                  }
                  return null;
                },
              ),

              // Satılan Kitap
              _buildTextField(_soldBookController, 'Satılan Kitap', 'Lütfen satılan kitabı giriniz'),

              // Miktar (Sadece Sayısal Giriş)
              _buildTextField(
                _quantityController,
                'Adet',
                'Lütfen miktar giriniz',
                isNumeric: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Sadece sayısal giriş
              ),

              // Fiyat (Masked for currency) + Placeholder
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fiyat',
                  hintText: '0.00', // Placeholder
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen fiyat giriniz';
                  }
                  return null;
                },
              ),

              // İadeler (Sadece Sayısal Giriş)
              _buildTextField(
                _returnsController,
                'İadeler',
                null,
                isNumeric: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              // İndirim (%) (Sadece Sayısal Giriş)
              _buildTextField(
                _discountController,
                'İndirim (%)',
                null,
                isNumeric: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              // İstenen Yazar
              _buildTextField(_desiredAuthorController, 'İstenen Yazar', 'Lütfen yazar ismi giriniz'),

              // Tarih
              Text('Tarih: $_eventDate', style: TextStyle(fontSize: 16)),

              // Notlar
              _buildTextField(_notesController, 'Notlar', null, maxLines: 3),

              SizedBox(height: 20),

              // Kaydet veya Güncelle Butonu
              ElevatedButton(
                onPressed: () {
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
                      // Yeni veri ekleme işlemi
                      controller.apiService.addSale(salesEntry);
                      Get.snackbar("Başarılı", "Veri başarıyla kaydedildi.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,);
                    } else {
                      // Güncelleme işlemi
                      //controller.apiService.updateSale(salesEntry); // Güncelleme için servis çağrısı
                      Get.snackbar("Başarılı", "Veri başarıyla güncellendi.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,);
                    }

                    Navigator.of(context).pop(); // İşlem bitince geri dön
                  }
                },
                child: Text(widget.sales == null ? 'Kaydet' : 'Güncelle'), // Buton yazısı duruma göre değişiyor
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Giriş alanı oluşturan yardımcı fonksiyon
  Widget _buildTextField(TextEditingController controller, String label, String? validationMessage,
      {bool isNumeric = false, List<TextInputFormatter>? inputFormatters, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: inputFormatters, // Yalnızca belirli formatları kabul etmek için
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}