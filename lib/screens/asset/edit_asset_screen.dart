import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/asset_provider.dart';
import '../../models/asset.dart';
import 'package:intl/intl.dart';

class EditAssetScreen extends StatefulWidget {
  final Asset asset;

  const EditAssetScreen({super.key, required this.asset});

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _purchaseValueController;
  late TextEditingController _currentValueController;
  late TextEditingController _notesController;
  late TextEditingController _creditValueController;
  late DateTime _purchaseDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _purchaseValueController = TextEditingController(
      text: widget.asset.purchaseValue.toString(),
    );
    _currentValueController = TextEditingController(
      text: widget.asset.currentValue.toString(),
    );
    _notesController = TextEditingController(text: widget.asset.notes);
    _purchaseDate = DateTime.parse(widget.asset.purchaseDate);
    _status = widget.asset.status;
    _creditValueController = TextEditingController(
      text: widget.asset.creditValue?.toString() ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Aset'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus aset ini?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AssetProvider>(context, listen: false)
                            .deleteAsset(widget.asset.id!)
                            .then((_) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close edit screen
                        });
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Aset',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama aset harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purchaseValueController,
              decoration: const InputDecoration(
                labelText: 'Nilai Beli',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nilai beli harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _creditValueController,
              decoration: const InputDecoration(
                labelText: 'Nilai Kredit',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nilai kredit harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentValueController,
              decoration: const InputDecoration(
                labelText: 'Estimasi Nilai Sekarang',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nilai sekarang harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tanggal Pembelian'),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(_purchaseDate),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _purchaseDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Lunas',
                  child: Text('Lunas'),
                ),
                DropdownMenuItem(
                  value: 'Kredit',
                  child: Text('Kredit'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedAsset = Asset(
                    id: widget.asset.id,
                    name: _nameController.text,
                    purchaseValue: double.parse(_purchaseValueController.text),
                    creditValue: double.parse(_creditValueController.text),
                    currentValue: double.parse(_currentValueController.text),
                    purchaseDate: DateFormat('yyyy-MM-dd').format(_purchaseDate),
                    status: _status,
                    notes: _notesController.text.isEmpty
                        ? null
                        : _notesController.text,
                  );

                  Provider.of<AssetProvider>(context, listen: false)
                      .updateAsset(widget.asset.id!, updatedAsset)
                      .then((_) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aset berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseValueController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();
    _creditValueController.dispose();
    super.dispose();
  }
} 