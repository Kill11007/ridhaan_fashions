class Purchase {
  int? id;
  int purchase;
  String? createdDateTime;
  String? updatedDateTime;

  Purchase({this.id, required this.purchase, this.createdDateTime}) {
    createdDateTime ??= DateTime.now().toIso8601String();
    updatedDateTime = DateTime.now().toIso8601String();
  }

  void update(Purchase purchase) {
    id = purchase.id;
    this.purchase = purchase.purchase;
    createdDateTime = purchase.createdDateTime;
    updatedDateTime = DateTime.now().toIso8601String();
  }

  @override
  String toString() {
    return 'Purchase{id: $id, purchase: $purchase, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime}';
  }

  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['totalPurchase'] = purchase;
    map['createdDateTime'] = createdDateTime;
    map['updatedDateTime'] = DateTime.now().toIso8601String();
    return map;
  }

  Purchase.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        purchase = map['totalPurchase'],
        createdDateTime = map['createdDateTime'],
        updatedDateTime = map['updatedDateTime'];
}
