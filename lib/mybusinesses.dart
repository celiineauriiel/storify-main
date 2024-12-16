import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockit/services/user_service.dart';
import 'package:stockit/updatebusinesspage.dart';
import 'models/business_model.dart';
import 'newbusiness.dart';
import 'services/business_service.dart';

class MyBusinessesPage extends StatefulWidget {
  const MyBusinessesPage({Key? key}) : super(key: key);

  @override
  State<MyBusinessesPage> createState() => _MyBusinessesPageState();
}

class _MyBusinessesPageState extends State<MyBusinessesPage> {
  final BusinessService _businessService = BusinessService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk menampilkan pop-up konfirmasi delete business
  void _showDeleteBusinessDialog(BuildContext context, String businessId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Business',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this business? This action cannot be undone.',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () {
                Navigator.pop(context);
                _deleteBusiness(businessId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBusiness(String businessId) async {
    try {
      await _businessService.deleteBusiness(_userService.getCurrentUserId()??"", businessId);
      setState(() {}); // Refresh data setelah berhasil dihapus
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete business: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 128, 110),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Businesses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BusinessModel>>(
        stream: _businessService.getBusinessesStreamByUserId(_userService.getCurrentUserId()??""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No businesses found.'),
            );
          }

          final businesses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: business.imageUrl != null &&
                          business.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(business.imageUrl!),
                      )
                          : const CircleAvatar(
                        child: Icon(Icons.business, color: Colors.orange),
                      ),
                      title: Text(business.businessName),
                      subtitle: Text(business.address),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteBusinessDialog(context, business.id);
                        },
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman edit (opsional)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateBusinessPage(
                                business: business,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.grey, width: 1),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Edit business',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewBusinessPage(),
            ),
          );
        },
        label: const Text('Add Business'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 9, 128, 110),
      ),
    );
  }
}
