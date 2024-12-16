import 'package:flutter/material.dart';

import 'models/business_model.dart';
import 'services/business_service.dart';


class UpdateBusinessPage extends StatefulWidget {
  final BusinessModel business;

  const UpdateBusinessPage({Key? key, required this.business}) : super(key: key);

  @override
  _UpdateBusinessPageState createState() => _UpdateBusinessPageState();
}

class _UpdateBusinessPageState extends State<UpdateBusinessPage> {
  final BusinessService _businessService = BusinessService();

  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late String _selectedCountry;
  String? _imageUrl;

  final List<Map<String, dynamic>> countries = [
    {'name': 'United States', 'iconColor': Colors.blue},
    {'name': 'Indonesia', 'iconColor': Colors.red},
    {'name': 'United Kingdom', 'iconColor': Colors.indigo},
    {'name': 'Australia', 'iconColor': Colors.green},
    {'name': 'India', 'iconColor': Colors.orange},
    {'name': 'Japan', 'iconColor': Colors.red},
    {'name': 'Germany', 'iconColor': Colors.black},
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.business.businessName);
    _addressController = TextEditingController(text: widget.business.address);
    _selectedCountry = widget.business.country;
    _imageUrl = widget.business.imageUrl;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showUpdateSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Business updated successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Kembali dengan status success
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBusiness() async {
    try {
      final updatedBusiness = BusinessModel(
        id: widget.business.id,
        businessName: _businessNameController.text,
        address: _addressController.text,
        country: _selectedCountry,
        imageUrl: _imageUrl,
      );

      await _businessService.updateBusiness(widget.business.id, updatedBusiness.toMap());
      _showUpdateSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update business: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    // Tambahkan logika untuk memilih gambar
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Business Name'),
                      TextField(
                        controller: _businessNameController,
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
            const Text('Country'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCountry,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
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
              ),
            ),
            const SizedBox(height: 16),
            const Text('Address'),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateBusiness,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
