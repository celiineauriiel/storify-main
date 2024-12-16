import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockit/InventoryDetailScreen.dart';
import 'package:stockit/addinventory.dart';
import 'package:stockit/models/product_modal.dart';
import 'package:stockit/newbusiness.dart';
import 'package:stockit/profile.dart';
import 'package:stockit/services/business_service.dart';
import 'package:stockit/services/product_service.dart';
import 'package:stockit/services/user_service.dart';
import 'faqpage.dart';
import 'models/business_model.dart';  // Mengimpor FAQPage

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> inventoryItems = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
  final currentUserId = _userService.getCurrentUserId();
  final products = await _productService.getProducts(currentUserId ?? "");
  setState(() {
    inventoryItems = products.map((product) {
      return {
        'name': product.name,
        'id': product.id,
        'quantity': product.quantity,
        'category': product.category,
      };
    }).toList();
  });
}

  int get totalItems {
    // Menghitung total produk dengan quantity > 0
    return inventoryItems.where((item) => item['quantity'] > 0).length;
  }

  int get outOfStock {
    // Menghitung produk yang stoknya 0
    return inventoryItems.where((item) => item['quantity'] == 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF006A67),
        title: InkWell(
          onTap: () async {
            var showModal = await showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => BusinessSelector(),
);

if (showModal == true) {
  setState(() {});
}

          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Business', style: TextStyle(color: Colors.white)),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0) + EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.getProductsStream(_userService.getCurrentUserId() ?? ""),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (productSnapshot.hasError) {
                  return Center(child: Text('Error: ${productSnapshot.error}'));
                }

                if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                  return Center(child: Text('No products found.'));
                }

                final filteredProducts = productSnapshot.data!.where((product) {
  final matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
  final matchesSearchQuery = searchQuery.isEmpty || 
      product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      product.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||  // Pencarian berdasarkan SKU
      product.quantity.toString().contains(searchQuery);  // Pencarian berdasarkan Quantity

  return matchesCategory && matchesSearchQuery;
}).toList();


                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return InventoryItem(productModel: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Color(0xFF006A67)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQPage()),
                );
              },
            ),
            SizedBox(width: 32),
            FloatingActionButton(
              backgroundColor: Color(0xFF006A67),
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit, color: Colors.teal),
                          title: Text('Add Product Manually'),
                          onTap: () {
                            Navigator.pop(context); // Close the bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddInventoryScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 32),
            IconButton(
              icon: Icon(Icons.person, color: Color(0xFF006A67)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryButton(String category, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == category
            ? const Color(0xFF006A67)
            : const Color.fromARGB(255, 255, 255, 255),
        shape: StadiumBorder(),
      ),
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: selectedCategory == category ? Colors.white : Color(0xFF006A67),
        ),
      ),
    );
  }
}

class BusinessSelector extends StatefulWidget {
  @override
  State<BusinessSelector> createState() => _BusinessSelectorState();
}

class _BusinessSelectorState extends State<BusinessSelector> {
  final BusinessService _businessService = BusinessService();
  final UserService _userService = UserService();
  String? selectedBusinessId;

  @override
  void initState() {
    super.initState();
    _loadSelectedBusinessId();
  }

  Future<void> _loadSelectedBusinessId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBusinessId = prefs.getString('selectedBusinessId');
    });
  }

  Future<void> _saveSelectedBusinessId(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedBusinessId', businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a business',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            StreamBuilder<List<BusinessModel>>(
              stream: _businessService.getBusinessesStreamByUserId(_userService.getCurrentUserId() ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No businesses found.'));
                }

                final businesses = snapshot.data!;

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];

                    return ListTile(
                      leading: const Icon(Icons.store, color: Colors.orange),
                      title: Text(business.businessName),
                      subtitle: Text(business.address),
                      trailing: Radio<String>(
                        value: business.id,
                        groupValue: selectedBusinessId,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedBusinessId = value;
                            });
                            _saveSelectedBusinessId(value);
                            Navigator.pop(context, true); // Return true when selected
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewBusinessPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                backgroundColor: Color(0xFF006A67),
                textStyle: TextStyle(color: Colors.white),
              ),
              child: Text('Add a new business', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}



class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const SummaryCard({required this.title, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(count.toString(), style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class InventoryItem extends StatelessWidget {
  final ProductModel productModel;

  const InventoryItem({required this.productModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryDetailScreen(productModel: productModel,)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productModel.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('ID: ${productModel.sku}  |  '),
                            Text('Quantity: ${productModel.quantity} pcs'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                child: Text(productModel.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

