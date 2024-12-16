class UserAccount {
  // Atribut model UserAccount
  String? fullName;
  String? email;
  String? password;

  // Constructor
  UserAccount({
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Mengonversi data dari JSON ke objek UserAccount (untuk mengambil data dari Firestore misalnya)
  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      fullName: json['fullName'],
      email: json['email'],
      password: json['password'], // Password biasanya tidak disimpan dalam Firestore, tetapi ini contoh umum
    );
  }

  // Mengonversi objek UserAccount ke format JSON (untuk menyimpan ke Firestore atau API)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,  // Pastikan password disimpan dengan aman, misalnya dengan hashing
    };
  }
}
