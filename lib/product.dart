class Product {
  String name = '';
  int price = 0;
  String id = '';

  Product({this.name = '', this.price = 0, required this.id });

  @override
  String toString() {
    return "Product($name, $price)";
  }

  Product.fromJson(Map<String, dynamic> json){
    name = json["name"];
    price = json["price"];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
