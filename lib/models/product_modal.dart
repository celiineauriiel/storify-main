class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final int quantity;
  final int reorderQuantity;
  final String unitCategory;
  final String unit;
  final String currency;
  final String category;
  final double costPrice;
  final double sellingPrice;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.reorderQuantity,
    required this.unitCategory,
    required this.unit,
    required this.currency,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
  });

  // Method to map Firestore document data to Product object
  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      barcode: data['barcode'] ?? '',
      quantity: data['quantity'] ?? 0,
      reorderQuantity: data['reorderQuantity'] ?? 0,
      unitCategory: data['unitCategory'] ?? 'Count / Quantity',
      unit: data['unit'] ?? 'Pieces (pcs)',
      currency: data['currency'] ?? 'IDR',
      category: data['category'] ?? 'Add New Category',
      costPrice: data['costPrice']?.toDouble() ?? 0.0,
      sellingPrice: data['sellingPrice']?.toDouble() ?? 0.0,
    );
  }

  // Method to convert Product object back to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'quantity': quantity,
      'reorderQuantity': reorderQuantity,
      'unitCategory': unitCategory,
      'unit': unit,
      'currency': currency,
      'category': category,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
    };
  }
}
