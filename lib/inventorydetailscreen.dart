import 'package:flutter/material.dart';
import 'package:stockit/EditProduct.dart';
import 'package:stockit/models/product_modal.dart';
import 'package:stockit/services/product_service.dart';
import 'package:stockit/services/user_service.dart';

class InventoryDetailScreen extends StatefulWidget {
  final ProductModel productModel;

  const InventoryDetailScreen({super.key, required this.productModel});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 248, 250),
      appBar: AppBar(
        backgroundColor: Color(0xFF006A67),
        title: const Text("Inventory Details"),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Tombol delete di kanan atas
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete Product",
            onPressed: () async {
              // Dialog konfirmasi
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Product"),
                    content: const Text("Are you sure you want to delete this product?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              // Jika user menekan "Delete"
              if (confirmDelete == true) {
                try {
                  await _productService.deleteProduct(
                    _userService.getCurrentUserId() ?? "",
                    widget.productModel.id,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Kembali ke layar sebelumnya
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Product deleted successfully."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorDialog(context, "Failed to delete product: $e");
                  }
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildInventoryItem(
              context,
              productName: widget.productModel.name,
              sku: widget.productModel.sku,
              barcode: widget.productModel.barcode,
              unitOfMeasure: widget.productModel.unitCategory,
              availableQuantity: widget.productModel.quantity.toString(),
              reorderQuantity: widget.productModel.reorderQuantity.toString(),
              sellingPrice: widget.productModel.sellingPrice.toString(),
              costPrice: widget.productModel.costPrice.toString(),
              category: widget.productModel.category,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStockButton(
                  context,
                  "Stock In",
                  Colors.green,
                  true, // true for Stock In
                ),
                _buildStockButton(
                  context,
                  "Stock Out",
                  Colors.red,
                  false, // false for Stock Out
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(
    BuildContext context, {
    required String productName,
    required String sku,
    required String barcode,
    required String unitOfMeasure,
    required String availableQuantity,
    required String reorderQuantity,
    required String sellingPrice,
    required String costPrice,
    required String category,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<ProductModel>(
              stream: _productService.getProductDetailsStream(_userService.getCurrentUserId()??"", widget.productModel.id), // Memanggil stream yang sudah dibuat
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("Product not found"));
                }

                // Ambil data produk dari snapshot
                ProductModel product = snapshot.data!;

                return Column(
                  children: [
                    _buildDivider(),
                    _buildDetailItem("SKU", product.sku),
                    _buildDivider(),
                    _buildDetailItem("Barcode", product.barcode),
                    _buildDivider(),
                    _buildDetailItem("Unit of Measure", product.unit),
                    _buildDivider(),
                    _buildDetailItem("Available Quantity", product.quantity.toString()),
                    _buildDivider(),
                    _buildDetailItem("Reorder Quantity", product.reorderQuantity.toString()),
                    _buildDivider(),
                    _buildDetailItem("Selling Price", product.sellingPrice.toStringAsFixed(2)),
                    _buildDivider(),
                    _buildDetailItem("Cost Price", product.costPrice.toStringAsFixed(2)),
                    _buildDivider(),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProduct(
          userId: _userService.getCurrentUserId() ?? "",
          productId: widget.productModel.id,
          product: widget.productModel,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    side: BorderSide(
      color: Colors.grey,
      width: 1,
    ),
    padding:
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding lebih kecil
  ),
  child: const Text(
    "Edit Product",
    style: TextStyle(fontSize: 16), // Ukuran font yang pas
  ),
)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.5,
      color: Colors.grey,
    );
  }

  Widget _buildStockButton(
  BuildContext context,
  String label,
  Color borderColor,
  bool isStockIn,
) {
  return ElevatedButton(
    onPressed: () {
      // Trigger popup based on whether it's Stock In or Stock Out
      if (isStockIn) {
        _showStockPopup(context, true); // Show Stock In popup
      } else {
        _showStockPopup(context, false); // Show Stock Out popup
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: borderColor,
      side: BorderSide(
        color: borderColor,
        width: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Padding disesuaikan
      minimumSize: Size(120, 50), // Ukuran minimum tombol agar teks tidak overflow
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 14), // Ukuran font yang pas
      textAlign: TextAlign.center, // Agar teks selalu terpusat
    ),
  );
}


  void _showStockPopup(BuildContext context, bool isStockIn) {
    int productCount = 0; // Menyimpan jumlah produk

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          Navigator.pop(context); // Close the popup
                        },
                      ),
                    ),
                    Text(
                      isStockIn ? "Stock In" : "Stock Out",
                      style: TextStyle(
                        fontSize: 20,
                        color: isStockIn ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStockIn
                          ? "Enter the number of products to add to stock."
                          : "Enter the number of products to be removed from stock.",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Number of products",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(22.0),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (productCount > 0) productCount--;
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.grey),
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                  text: productCount.toString()),
                              onChanged: (value) {
                                setState(() {
                                  productCount = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                productCount++;
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Success Popup
                          Navigator.pop(context);
                          final quantityChange =
                              isStockIn ? productCount : -productCount;

                          await _productService.updateProductStock(
                              _userService.getCurrentUserId() ?? "",
                              widget.productModel.id,
                              quantityChange);

                          if (context.mounted) {
                            _showSuccessDialog(context, isStockIn, productCount);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showErrorDialog(context, e.toString());
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        backgroundColor: isStockIn ? Colors.green : Colors.red,
                      ),
                      child: Text(
                          isStockIn ? "Add to Stock" : "Remove from Stock"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(
      BuildContext context, bool isStockIn, int productCount)async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(
            isStockIn
                ? "Successfully added $productCount products to stock."
                : "Successfully removed $productCount products from stock.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage)async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
