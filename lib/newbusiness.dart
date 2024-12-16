import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'services/business_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add a New Business',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 17, 165, 143)),
        useMaterial3: true,
      ),
      home: const AddNewBusinessPage(),
    );
  }
}

class AddNewBusinessPage extends StatefulWidget {
  const AddNewBusinessPage({super.key});

  @override
  State<AddNewBusinessPage> createState() => _AddNewBusinessPageState();
}

class _AddNewBusinessPageState extends State<AddNewBusinessPage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedCountry = 'United States';
  File? selectedImage;

  final List<Map<String, dynamic>> countries = [
    {'name': 'United States', 'iconColor': Colors.blue},
    {'name': 'Indonesia', 'iconColor': Colors.red},
    {'name': 'United Kingdom', 'iconColor': Colors.indigo},
    {'name': 'Australia', 'iconColor': Colors.green},
    {'name': 'India', 'iconColor': Colors.orange},
    {'name': 'Japan', 'iconColor': Colors.red},
    {'name': 'Germany', 'iconColor': Colors.black},
  ];

  final BusinessService _businessService = BusinessService();

  Future<void> showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await pickImage(ImageSource.camera);
                  showNotification("Photo taken from camera!");
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await pickImage(ImageSource.gallery);
                  showNotification("Photo selected from gallery!");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> addNewBusiness() async {
    if (businessNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedCountry.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill in all fields to proceed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Dapatkan user ID dari Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in.');

      // URL gambar (jika ada gambar yang dipilih)
      String? imageUrl;
      if (selectedImage != null) {
        // TODO : Untuk gambar tidak bisa karena bayar
        // imageUrl = await _businessService.uploadImage(user.uid, selectedImage!);
      }

      // Tambahkan bisnis menggunakan service
      await _businessService.addBusiness(
        userId: user.uid,
        businessName: businessNameController.text,
        country: selectedCountry,
        address: addressController.text,
        imageUrl: imageUrl,
      );

      // Tampilkan notifikasi sukses
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Business has been successfully added!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  businessNameController.clear();
                  addressController.clear();
                  setState(() {
                    selectedImage = null;
                    selectedCountry = 'United States';
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Tampilkan pesan error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add business: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Business'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: showImagePickerOptions,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      image: selectedImage != null
                          ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: selectedImage == null
                        ? const Icon(Icons.camera_alt, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: businessNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter business name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Country',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['name'] as String,
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: country['iconColor'] as Color),
                      const SizedBox(width: 8),
                      Text(country['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountry = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Enter address',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addNewBusiness,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 4, 137, 131),
                ),
                child: const Text(
                  'Add a new business',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}