import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // Jika null = Tambah, Jika ada = Edit
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final product = Product(
        id: widget.product?.id ?? 0,
        name: _nameCtrl.text,
        price: double.parse(_priceCtrl.text),
        description: _descCtrl.text,
      );

      bool success;
      if (widget.product == null) {
        success = await _apiService.createProduct(product);
      } else {
        success = await _apiService.updateProduct(product.id, product);
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil disimpan!"), backgroundColor: Color.fromARGB(255, 241, 117, 140),));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Tambah Produk" : "Edit Produk", style: TextStyle(fontWeight: FontWeight.bold),), backgroundColor: Color.fromARGB(255, 238, 132, 151), foregroundColor: const Color.fromARGB(255, 255, 255, 255)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Produk", prefixIcon: Icon(Icons.label_outline)),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga (Rp)", prefixIcon: Icon(Icons.attach_money)),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Deskripsi", prefixIcon: Icon(Icons.description_outlined)),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text("SIMPAN PRODUK"),
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}