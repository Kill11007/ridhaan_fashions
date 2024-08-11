import 'package:ridhaan_fashions/customer.dart';
import 'package:ridhaan_fashions/supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  final int discount;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    required this.discount
  });
}

class InvoiceInfo {
  final String number;
  final DateTime date;

  const InvoiceInfo({
    required this.number,
    required this.date,
  });
}

class InvoiceItem {
  final String description;
  final int price;

  const InvoiceItem({
    required this.description,
    required this.price,
  });
}