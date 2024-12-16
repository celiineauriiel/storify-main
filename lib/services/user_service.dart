import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserEmail() {
    final user = _auth.currentUser;
    return user?.email;
  }

  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Stream<String?> getUserEmailStream() {
    return _auth.authStateChanges().map((user) => user?.email);
  }

  Stream<String?> getUserIdStream() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  // Fungsi untuk menghapus akun pengguna
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();  // Menghapus akun pengguna
      }
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }
}
