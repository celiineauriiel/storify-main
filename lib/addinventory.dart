import 'package:flutter/material.dart';
import 'package:stockit/models/product_modal.dart';
import 'package:stockit/services/product_service.dart';
import 'package:stockit/services/user_service.dart';

class AddInventoryScreen extends StatefulWidget {
  @override
  _AddInventoryScreenState createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();

  int initialQuantity = 0;
  int reorderQuantity = 0;
  String selectedUnitCategory = "Count / Quantity";
  String selectedUnit = "Pieces (pcs)";
  String selectedCurrency = "IDR";
  String selectedCategory = "Add New Category";

  // Dropdown options
  final Map<String, List<String>> unitOptions = {
    "Count / Quantity": ["Units (units)", "Pieces (pcs)", "Items (items)", "Packs (packs)", "Boxes (boxes)", "Other"],
    "Volume": ["Liters (l)", "Milliliters (ml)", "Fluid Ounces (fl oz)", "Cups (cup)", "Other"],
    "Weight": ["Kilograms (kg)", "Grams (g)", "Ounces (oz)", "Other"],
    "Length": ["Kilometers (km)", "Meters (m)", "Centimeters (cm)", "Inches (in)", "Feet (ft)", "Other"],
  };

  final List<String> categories = ["Add New Category", "Electronics", "Groceries", "Fashion"];
  final List<String> currencies = ["EUR", "USD", "IDR", "JPY", "KRW", "AUD", "None"];

  Future<void> _saveInventory() async {
    // Validate user input
    if (_nameController.text.isEmpty || _costPriceController.text.isEmpty || _sellingPriceController.text.isEmpty) {
      _showErrorDialog("Please fill all required fields.");
      return;
    }

    try {
      final product = ProductModel(
        id: '', // Firestore will auto-generate the ID
        name: _nameController.text,
        sku: _skuController.text,
        barcode: _barcodeController.text,
        quantity: initialQuantity,
        reorderQuantity: reorderQuantity,
        unitCategory: selectedUnitCategory,
        unit: selectedUnit,
        currency: selectedCurrency,
        category: selectedCategory,
        costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      );

      // Example user ID retrieval
      String userId = _userService.getCurrentUserId()??""; // Replace with actual user ID logic

      await ProductService().addProductToBusiness(userId, product);

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog("Failed to save product: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Product added successfully."),
        actions: [
          TextButton(
            onPressed: ()
            {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Inventory"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Product Name", "Enter product name", _nameController),
            _buildTextField("SKU/Product Code", "Enter SKU", _skuController),
            _buildTextField("Barcode", "Enter barcode", _barcodeController),
            _buildDropdown("Unit Category", selectedUnitCategory, unitOptions.keys.toList(), (value) {
              setState(() {
                selectedUnitCategory = value ?? selectedUnitCategory;
                selectedUnit = unitOptions[selectedUnitCategory]?.first ?? "Pieces (pcs)";
              });
            }),
            _buildQuantityField("Initial Quantity", initialQuantity, (newQuantity) {
              setState(() {
                initialQuantity = newQuantity;
              });
            }),
            _buildQuantityField("Reorder Quantity", reorderQuantity, (newQuantity) {
              setState(() {
                reorderQuantity = newQuantity;
              });
            }),
            _buildDropdown("Unit", selectedUnit, unitOptions[selectedUnitCategory]!, (value) {
              setState(() => selectedUnit = value ?? selectedUnit);
            }),
            _buildDropdown("Currency", selectedCurrency, currencies, (value) {
              setState(() => selectedCurrency = value ?? selectedCurrency);
            }),
            _buildDropdown("Category", selectedCategory, categories, (value) {
              setState(() => selectedCategory = value ?? selectedCategory);
            }),
            _buildTextField("Cost Price", "Enter cost price", _costPriceController, isNumeric: true),
            _buildTextField("Selling Price", "Enter selling price", _sellingPriceController, isNumeric: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveInventory,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: _outlineInputBorder(),
          focusedBorder: _outlineInputBorder(focused: true),
        ),
      ),
    );
  }

  Widget _buildQuantityField(String label, int quantity, ValueChanged<int> onChanged) {
    final TextEditingController controller = TextEditingController(text: quantity.toString());

    return _buildFieldContainer(
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(color: Colors.grey, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (quantity > 0) {
                  onChanged(quantity - 1);
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "0",
                ),
                onChanged: (value) {
                  final int? newQuantity = int.tryParse(value);
                  if (newQuantity != null) {
                    onChanged(newQuantity);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onChanged(quantity + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: _outlineInputBorder(),
          focusedBorder: _outlineInputBorder(focused: true),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22.0),
      borderSide: BorderSide(
        color: focused ? Color(0xFF006A67) : Colors.grey,
        width: 1.0,
      ),
    );
  }
}
