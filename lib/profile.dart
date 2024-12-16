import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockit/services/business_service.dart';
import 'package:stockit/services/user_service.dart';
import 'mybusinesses.dart';
import 'loginpage.dart'; // Pastikan untuk mengimpor halaman login

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();
  final businessService = BusinessService();

  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout?',
          style: TextStyle(
            color: Color.fromARGB(255, 9, 128, 110),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog tanpa melakukan apa-apa
            },
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Color.fromARGB(255, 132, 22, 151), fontSize: 16)),
            onPressed: () async {
              try {
                // Lakukan logout menggunakan Firebase
                await FirebaseAuth.instance.signOut();
                
                // Menutup dialog setelah logout
                Navigator.of(context).pop();
                
                // Navigasi ke halaman login setelah logout
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Tampilkan error jika terjadi masalah
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to logout: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be removed.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () async {
                try {
                  // Panggil fungsi untuk menghapus akun
                  await userService.deleteUserAccount();
                  // Menutup dialog dan kembali ke layar login
                  Navigator.of(context).pop();
                  // Navigasi ke halaman login setelah akun dihapus
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  // Tampilkan error jika terjadi masalah
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                  Navigator.of(context).pop();  // Menutup dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfilePhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profile photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006A67),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://tse3.mm.bing.net/th?id=OIP.RyxJIDAYkvNypd4dKJXIlAHaFj&pid=Api&P=0&h=220',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: () {
                        _showProfilePhotoOptions(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.email, color: Color.fromARGB(255, 23, 103, 27)),
                title: const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: Text(userService.getCurrentUserEmail() ?? "",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<int>(
              stream: businessService.getTotalBusinessesInUserDocStream(userService.getCurrentUserId() ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text('Error fetching business count');
                }

                final totalBusinesses = snapshot.data ?? 0;
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.green),
                    title: const Text(
                      'My Businesses',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalBusinesses',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyBusinessesPage()));
                    },
                  ),
                );
              },
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 224, 38, 25),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Delete account',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  _showDeleteDialog(context);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
