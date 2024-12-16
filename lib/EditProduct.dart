import 'package:flutter/material.dart';
import 'package:stockit/models/product_modal.dart';
import 'package:stockit/services/product_service.dart';

class EditProduct extends StatefulWidget {
  final String userId;
  final String productId;
  final ProductModel product;

  EditProduct({
    required this.userId,
    required this.productId,
    required this.product,
  });
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _productService = ProductService();

  late TextEditingController nameController;
  late TextEditingController skuController;
  late TextEditingController barcodeController;
  late TextEditingController costPriceController;
  late TextEditingController sellingPriceController;

  int reorderQuantity = 0;
  String selectedUnitCategory = "Count / Quantity";
  String selectedUnit = "Pieces (pcs)";
  String selectedCurrency = "IDR";
  String selectedCategory = "Add New Category";

  @override
  void initState() {
    super.initState();

    // Initialize controllers with product data
    nameController = TextEditingController(text: widget.product.name);
    skuController = TextEditingController(text: widget.product.sku);
    barcodeController = TextEditingController(text: widget.product.barcode);
    costPriceController =
        TextEditingController(text: widget.product.costPrice.toString());
    sellingPriceController =
        TextEditingController(text: widget.product.sellingPrice.toString());

    reorderQuantity = widget.product.reorderQuantity;
    selectedUnitCategory = widget.product.unitCategory;
    selectedUnit = widget.product.unit;
    selectedCurrency = widget.product.currency;
    selectedCategory = widget.product.category;
  }

  Future<void> _updateProduct() async {
    final updatedProduct = ProductModel(
      id: widget.productId,
      name: nameController.text,
      sku: skuController.text,
      barcode: barcodeController.text,
      quantity: widget.product.quantity,
      reorderQuantity: reorderQuantity,
      unitCategory: selectedUnitCategory,
      unit: selectedUnit,
      currency: selectedCurrency,
      category: selectedCategory,
      costPrice: double.tryParse(costPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(sellingPriceController.text) ?? 0.0,
    );

    try {
      await _productService.updateProduct(
        widget.userId,
        widget.productId,
        updatedProduct,
      );

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, size: 40, color: Colors.green),
          content: const Text("Product updated successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.error, size: 40, color: Colors.red),
          content: Text("Error updating product: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  final Map<String, List<String>> unitOptions = {
    "Count / Quantity": [
      "Units (units)",
      "Pieces (pcs)",
      "Items (items)",
      "Packs (packs)",
      "Boxes (boxes)",
      "Other"
    ],
    "Volume": [
      "Liters (l)",
      "Milliliters (ml)",
      "Fluid Ounces (fl oz)",
      "Cups (cup)",
      "Other"
    ],
    "Weight": ["Kilograms (kg)", "Grams (g)", "Ounces (oz)", "Other"],
    "Length": [
      "Kilometers (km)",
      "Meters (m)",
      "Centimeters (cm)",
      "Inches (in)",
      "Feet (ft)",
      "Other"
    ],
  };

  final List<String> categories = [
    "Add New Category",
    "Electronics",
    "Groceries",
    "Fashion"
  ];

  final List<String> currencies = [
    "EUR",
    "USD",
    "IDR",
    "JPY",
    "KRW",
    "AUD",
    "None"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Edit Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              buildTextField("Product Name", nameController),
              buildTextField("SKU/Product Code", skuController),
              buildTextField("Enter Barcode", barcodeController),
              buildQuantityField("Reorder Quantity", reorderQuantity, (newQuantity) {
                setState(() {
                  reorderQuantity = newQuantity;
                });
              }),
              buildDropdown(
                "Select a unit of measure",
                selectedUnitCategory,
                unitOptions.keys.toList(),
                (value) {
                  setState(() {
                    selectedUnitCategory = value ?? selectedUnitCategory;
                    selectedUnit = unitOptions[selectedUnitCategory]?.first ??
                        "Pieces (pcs)";
                  });
                },
              ),
              buildDropdown(
                "Select Currency",
                selectedCurrency,
                currencies,
                (value) {
                  setState(() {
                    selectedCurrency = value ?? selectedCurrency;
                  });
                },
              ),
              buildDropdown(
                "Select Category",
                selectedCategory,
                categories,
                (value) {
                  if (value == "Add New Category") {
                    _showInputDialog(
                      context,
                      "Add New Category",
                      (newValue) {
                        setState(() {
                          categories.add(newValue);
                          selectedCategory = newValue;
                        });
                      },
                    );
                  } else {
                    setState(() {
                      selectedCategory = value ?? selectedCategory;
                    });
                  }
                },
              ),
              buildTextField("Cost Price", costPriceController),
              buildTextField("Selling Price", sellingPriceController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A67),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Update Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $label",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuantityField(
      String label, int quantity, ValueChanged<int> onChanged) {
    final TextEditingController controller =
        TextEditingController(text: quantity.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
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
        ],
      ),
    );
  }

  void _showInputDialog(
      BuildContext context, String title, ValueChanged<String> onSubmitted) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter value"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSubmitted(controller.text);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
