import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqData = [
    {
      'question': 'What is this app?',
      'answer': 'This app is an inventory management tool that helps you track your products effectively.'
    },
    {
      'question': 'How to add a product?',
      'answer': 'Click the "+" button on the bottom bar, then follow the steps to add a product manually.'
    },
    {
      'question': 'How to search products?',
      'answer': 'Use the search icon on the top-right corner to find products by name or category.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Tombol back putih
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006A67), Color(0xFF405D72)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // FAQ Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: faqData.length,
                itemBuilder: (context, index) {
                  final item = faqData[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF006A67),
                        child: Icon(Icons.help_outline, color: Colors.white),
                      ),
                      title: Text(
                        item['question']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF006A67),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            item['answer']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}