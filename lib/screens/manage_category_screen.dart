import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class ManageCategoryScreen extends StatefulWidget {
  final String type; // 'Pemasukan' atau 'Pengeluaran'

  const ManageCategoryScreen({super.key, required this.type});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori ${widget.type}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Form Tambah Kategori
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_categoryController.text.isNotEmpty) {
                      categoryProvider.addCategory(
                          _categoryController.text, widget.type);
                      _categoryController.clear();
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Daftar Kategori
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      categoryProvider.deleteCategory(category['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
