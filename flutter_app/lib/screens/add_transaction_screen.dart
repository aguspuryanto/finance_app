import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import 'manage_category_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedType = 'Pemasukan'; // Default jenis transaksi
  String _selectedCategory = ''; // Kategori yang dipilih
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!['title'];
      _amountController.text = widget.transaction!['amount'].toString();
      _selectedType = widget.transaction!['type'];
      _selectedCategory = widget.transaction!['category'];
      _selectedDate = DateTime.parse(widget.transaction!['date']);
      _notesController.text = widget.transaction!['notes'] ?? '';
    }
    Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories(_selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis Transaksi (Pemasukan/Pengeluaran)
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              'Pemasukan',
                              theme,
                              _selectedType == 'Pemasukan',
                              () => setState(() {
                                _selectedType = 'Pemasukan';
                                _selectedCategory = '';
                                categoryProvider.fetchCategories(_selectedType);
                              }),
                            ),
                          ),
                          Expanded(
                            child: _buildTypeButton(
                              'Pengeluaran',
                              theme,
                              _selectedType == 'Pengeluaran',
                              () => setState(() {
                                _selectedType = 'Pengeluaran';
                                _selectedCategory = '';
                                categoryProvider.fetchCategories(_selectedType);
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Judul Transaksi
                  _buildLabel('Judul Transaksi'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Gaji Bulanan',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Input Jumlah
                  _buildLabel('Jumlah'),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 500000',
                      prefixText: 'Rp ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Jumlah harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Kategori
                  _buildLabel('Kategori'),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: ListTile(
                      title: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                          hint: const Text('Pilih Kategori'),
                          items: categoryProvider.categories
                              .map((cat) => DropdownMenuItem<String>(
                                    value: cat['name'],
                                    child: Text(cat['name']),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageCategoryScreen(type: _selectedType),
                            ),
                          ).then((_) {
                            categoryProvider.fetchCategories(_selectedType);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedCategory.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih kategori transaksi')),
                            );
                            return;
                          }

                          transactionProvider.addTransaction({
                            'title': _titleController.text,
                            'amount': double.parse(_amountController.text),
                            'type': _selectedType,
                            'category': _selectedCategory,
                            'date': DateTime.now().toString().split(' ')[0],
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeButton(String text, ThemeData theme, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
