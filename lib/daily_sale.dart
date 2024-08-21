class Sale {
  int? id;
  int sale;
  String? createdDateTime;
  String? updatedDateTime;

  Sale({this.id, required this.sale}) {
    createdDateTime = DateTime.now().toIso8601String();
    updatedDateTime = DateTime.now().toIso8601String();
  }

  @override
  String toString() {
    return 'Sale{id: $id, sale: $sale, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime}';
  }

  void update(Sale sale) {
    id = sale.id;
    this.sale = sale.sale;
    createdDateTime = sale.createdDateTime;
    updatedDateTime = DateTime.now().toIso8601String();
  }

  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['totalSale'] = sale;
    map['createdDateTime'] = createdDateTime;
    map['updatedDateTime'] = updatedDateTime;
    return map;
  }

  Sale.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        sale = map['totalSale'],
        createdDateTime = map['createdDateTime'],
        updatedDateTime = map['updatedDateTime'];
}
