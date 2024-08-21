import 'dart:convert';

import 'package:ridhaan_fashions/product.dart';

class Bill {
  final int? id;
  final String phoneNumber;
  String customerName;
  final List<Product> products;
  final int discount;
  int total = 0;
  String? createdDateTime;
  String? updatedDateTime;

  Bill(
      {this.id,
      required this.phoneNumber,
      this.customerName = '',
      required this.products,
      required this.discount}) {
    for (Product p in products) {
      total += p.price;
    }
    total -= discount;
    createdDateTime = DateTime.now().toIso8601String();
    updatedDateTime = DateTime.now().toIso8601String();
  }

  @override
  String toString() {
    return "Bill(id: $id, customer: $phoneNumber, $customerName, discount: $discount, total: $total, products: $products)";
  }

  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['phoneNumber'] = phoneNumber;
    map['customerName'] = customerName;
    map['products'] = jsonEncode(products);
    map['discount'] = discount;
    map['total'] = total;
    map['createdDateTime'] = createdDateTime;
    map['updatedDateTime'] = DateTime.now().toIso8601String();
    return map;
  }

  Bill.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        phoneNumber = map['phoneNumber'],
        customerName = map['customerName'],
        discount = map['discount'],
        total = map['total'],
        createdDateTime = map['createdDateTime'],
        updatedDateTime = map['updatedDateTime'],
        products = List<Product>.from(jsonDecode(map['products'])
            .map((model) => Product.fromJson(model)));
}
