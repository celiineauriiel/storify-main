import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_modal.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream data produk berdasarkan userId
  Stream<List<ProductModel>> getProductsStream(String userId) {
    final prefs = SharedPreferences.getInstance();
    final businessId =
        prefs.then((prefs) => prefs.getString('selectedBusinessId'));

    return Stream.fromFuture(businessId).asyncExpand((businessId) {
      if (businessId == null) {
        throw Exception("Business belum terpilih.");
      }

      print("cek userId $userId dan BusinessId : $businessId");
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    });
  }

Future<List<ProductModel>> getProducts(String userId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return ProductModel(
        id: doc.id,
        name: doc['name'] ?? '',  // Berikan nilai default jika 'name' tidak ada
        quantity: doc['quantity'] ?? 0,  // Pastikan quantity ada atau beri nilai default
        category: doc['category'] ?? '',  // Berikan nilai default jika 'category' tidak ada
        sku: doc['sku'] ?? '',  // Berikan nilai default jika 'sku' tidak ada
        barcode: doc['barcode'] ?? '',  // Berikan nilai default jika 'barcode' tidak ada
        reorderQuantity: doc['reorderQuantity'] ?? 0,  // Berikan nilai default jika 'reorderQuantity' tidak ada
        unitCategory: doc['unitCategory'] ?? '',  // Berikan nilai default jika 'unitCategory' tidak ada
        unit: doc['unit'] ?? '',  // Berikan nilai default jika 'unit' tidak ada
        currency: doc['currency'] ?? '',  // Berikan nilai default jika 'currency' tidak ada
        costPrice: doc['costPrice'] ?? 0.0,  // Pastikan costPrice ada atau beri nilai default
        sellingPrice: doc['sellingPrice'] ?? 0.0,  // Pastikan sellingPrice ada atau beri nilai default
      );
    }).toList();
  } catch (e) {
    print('Error getting products: $e');
    return [];
  }
}

  // Menambahkan produk baru ke Firestore
  Future<void> addProductToBusiness(String userId, ProductModel product) async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString('selectedBusinessId');

    if (businessId == null) {
      throw Exception("Business ID is not set in SharedPreferences.");
    }

    // Menambahkan produk ke koleksi produk dalam bisnis yang terpilih
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .add(
              product.toMap()); // Pastikan ProductModel memiliki metode toMap()
    } catch (e) {
      throw Exception("Error adding product: $e");
    }
  }

  // Mengupdate produk yang sudah ada di Firestore
  Future<void> updateProduct(
      String userId, String productId, ProductModel product) async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString('selectedBusinessId');

    if (businessId == null) {
      throw Exception("Business ID is not set in SharedPreferences.");
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .doc(productId)
          .update(product.toMap());
    } catch (e) {
      print("Error updating product: $e");
      throw e;
    }
  }

  Stream<ProductModel> getProductDetailsStream(
      String userId, String productId) {
    final prefs = SharedPreferences.getInstance();
    final businessId =
        prefs.then((prefs) => prefs.getString('selectedBusinessId'));

    return Stream.fromFuture(businessId).asyncExpand((businessId) {
      if (businessId == null) {
        throw Exception("Business belum terpilih.");
      }

      print("cek userId $userId dan BusinessId : $businessId");
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .doc(productId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          // Mengonversi snapshot menjadi model ProductModel
          return ProductModel.fromMap(snapshot.data()!, snapshot.id);
        } else {
          throw Exception("Product not found");
        }
      });
    });
  }

  // Menghapus produk dari Firestore
  Future<void> deleteProduct(String userId, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString('selectedBusinessId');

    if (businessId == null) {
      throw Exception("Business ID is not set in SharedPreferences.");
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      print("Error deleting product: $e");
      throw e;
    }
  }

  Future<void> updateProductStock(
      String userId, String productId, int quantityChange) async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString('selectedBusinessId');

    if (businessId == null) {
      throw Exception("Business ID is not set in SharedPreferences.");
    }

    try {
      // Referensi Firestore
      final productDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .collection('products')
          .doc(productId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(productDoc);

        if (!snapshot.exists) {
          throw Exception("Product does not exist");
        }

        final currentQuantity = snapshot.data()?['quantity'] ?? 0;

        // Hitung stok baru
        final newQuantity = currentQuantity + quantityChange;

        // Pastikan stok tidak menjadi negatif
        if (newQuantity < 0) {
          throw Exception("Stock tidak memadai");
        }

        // Update stok
        transaction.update(productDoc, {'quantity': newQuantity});
      });
    } catch (e) {
      print("Error updating product stock: $e");
      throw e;
    }
  }
}
