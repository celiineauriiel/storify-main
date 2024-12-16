import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stockit/models/business_model.dart';

class BusinessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> getBusinessId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .get();  // Mendapatkan snapshot dari koleksi businesses

      if (snapshot.docs.isNotEmpty) {
        // Mengembalikan ID dari dokumen pertama
        return snapshot.docs.first.id;
      } else {
        return null; // Jika tidak ada dokumen dalam koleksi
      }
    } catch (e) {
      throw Exception("Error fetching business ID: $e");
    }
  }

  Stream<int> getTotalBusinessesInUserDocStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Fungsi untuk mendapatkan daftar bisnis berdasarkan userId
  Stream<List<BusinessModel>> getBusinessesStreamByUserId(String userId) {
    print("cek userId $userId");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // return {
        //   'id': doc.id,
        //   ...doc.data() as Map<String, dynamic>,
        // };
        return BusinessModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Fungsi untuk menghapus bisnis berdasarkan ID
  Future<void> deleteBusiness(String userId, String businessId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .doc(businessId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete business: $e');
    }
  }

  // Fungsi untuk upload gambar ke Firebase Storage
  Future<String> uploadImage(String userId, File imageFile) async {
    try {
      final storageRef = _storage
          .ref()
          .child('business_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Fungsi untuk menambahkan bisnis ke Firestore
  Future<void> addBusiness({
    required String userId,
    required String businessName,
    required String country,
    required String address,
    String? imageUrl,
  }) async {
    try {
      final businessRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('businesses');

      await businessRef.add({
        'businessName': businessName,
        'country': country,
        'address': address,
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add business: $e');
    }
  }

  Future<void> updateBusiness(String businessId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('businesses')
          .doc(businessId)
          .update(updatedData);
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }
}
