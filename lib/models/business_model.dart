class BusinessModel {
  String id;
  String businessName;
  String address;
  String country;
  String? imageUrl;

  BusinessModel({
    required this.id,
    required this.businessName,
    required this.address,
    required this.country,
    this.imageUrl,
  });

  // Fungsi untuk mengonversi Firestore document ke objek Business
  factory BusinessModel.fromMap(String id, Map<String, dynamic> data) {
    return BusinessModel(
      id: id,
      businessName: data['businessName'] ?? '',
      address: data['address'] ?? '',
      country: data['country'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  // Fungsi untuk mengonversi objek Business ke map (untuk update Firestore)
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'address': address,
      'country': country,
      'imageUrl': imageUrl,
    };
  }
}
