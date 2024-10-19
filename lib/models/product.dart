class Product {
  final String id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
