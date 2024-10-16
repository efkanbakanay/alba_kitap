class Sales {
  final int? id;  // id opsiyonel hale getirildi
  final int schoolId;
  final String contactPerson;
  final String phone;
  final String soldBook;
  final int quantity;
  final double price;
  final int? returns;
  final int? discountPercentage;
  final String desiredAuthor;
  final String eventDate;
  final double? totalPrice;
  final String notes;

  Sales({
    this.id,  // id opsiyonel
    required this.schoolId,
    required this.contactPerson,
    required this.phone,
    required this.soldBook,
    required this.quantity,
    required this.price,
    this.returns,
    this.discountPercentage,
    required this.desiredAuthor,
    required this.eventDate,
    this.totalPrice,
    required this.notes,
  });

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['id'],  // Eğer json'da id yoksa null olabilir
      schoolId: json['school_id'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      soldBook: json['sold_book'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      returns: json['returns'],
      discountPercentage: json['discount_percentage'],
      desiredAuthor: json['desired_author'],
      eventDate: json['event_date'],
      totalPrice: json['total_price'] != null ? double.tryParse(json['total_price'].toString()) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'school_id': schoolId,
      'contact_person': contactPerson,
      'phone': phone,
      'sold_book': soldBook,
      'quantity': quantity,
      'price': price,
      'returns': returns,
      'discount_percentage': discountPercentage,
      'desired_author': desiredAuthor,
      'event_date': eventDate,
      'notes': notes,
    };

    // Eğer id null değilse JSON'a ekliyoruz
    if (id != null) {
      data['id'] = id;
    }

    if (totalPrice != null) {
      data['total_price'] = totalPrice;
    }

    return data;
  }

  @override
  String toString() {
    return 'Sales(id: $id, schoolId: $schoolId, contactPerson: $contactPerson, phone: $phone, soldBook: $soldBook, quantity: $quantity, price: $price, returns: $returns, discountPercentage: $discountPercentage, desiredAuthor: $desiredAuthor, eventDate: $eventDate, totalPrice: $totalPrice, notes: $notes)';
  }
}