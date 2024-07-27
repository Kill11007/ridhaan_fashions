class Customer{
  int? id;
  final String phoneNumber;
  final String name;
  final int totalPurchase;

  Customer({this.id, required this.phoneNumber, required this.name, required this.totalPurchase});

  @override
  String toString() {
    return "Customer($id, $name, $phoneNumber, total_purchase: $totalPurchase)";
  }

  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['phoneNumber'] = phoneNumber;
    map['name'] = name;
    map['totalPurchase'] = totalPurchase;
    return map;
  }

  Customer.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        phoneNumber = map['phoneNumber'],
        name = map['name'],
        totalPurchase = map['totalPurchase'];
}