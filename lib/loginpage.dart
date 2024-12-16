import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockit/homepage.dart';
import 'package:stockit/registerpage.dart';
import 'package:stockit/services/business_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = '';

  // Fungsi untuk login
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in both email and password';
      });
      return;
    }

    try {
      // Menjalankan login dengan email dan password menggunakan Firebase
      var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final businessS = BusinessService();
      if(user.user != null) {
        var businessId = await businessS.getBusinessId(user.user!.uid);
        if(businessId != null)
        {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('selectedBusinessId', businessId);
        }
      }


      // Navigasi ke halaman Homepage jika login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } on FirebaseAuthException catch (e) {
      print("cek error " + e.code);
      print("cek error " + e.message.toString());
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'Email tidak terdaftar';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Password Salah';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Format email salah';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'Email salah atau password salah';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      // Menangani error lainnya
      setState(() {
        errorMessage = 'An unknown error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://cdn.dribbble.com/users/458522/screenshots/16171869/media/0c5b235e80c42db71c2567d8a04625ac.png'),
                radius: 60.0,
              ),

              const SizedBox(height: 5.0),

              // Greeting Text
              Text(
                "Storify",
                style: GoogleFonts.secularOne(
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F1500),
                ),
              ),

              const SizedBox(height: 5.0),

              const Text(
                'Sign in to use our services',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40.0),

              // Email TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Password TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),

              // Error message
              const SizedBox(height: 10.0),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14.0,
                    ),
                  ),
                ),

              // Login Button
              const SizedBox(height: 20.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: _loginUser, // Panggil fungsi login saat tombol ditekan
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 0, 106, 103),
                    ),
                    child: const Center(
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Navigasi ke RegisterPage jika pengguna belum memiliki akun
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t Have an Account?',
                    style: TextStyle(
                        color: Colors.black87, fontStyle: FontStyle.italic),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Registerpage()),
                      );
                    },
                    child: const Text(
                      ' Register now',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 106, 103),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
