import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sub_transaction.dart';

class SubTransactionForm extends StatefulWidget {
  final Map<String, dynamic> parentTransaction;
  final SubTransaction? subTransaction;

  const SubTransactionForm({
    super.key,
    required this.parentTransaction,
    this.subTransaction,
  });

  @override
  State<SubTransactionForm> createState() => _SubTransactionFormState();
}

class _SubTransactionFormState extends State<SubTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.subTransaction != null) {
      _titleController.text = widget.subTransaction!.title;
      _amountController.text = widget.subTransaction!.amount.toString();
      _notesController.text = widget.subTransaction!.notes ?? '';
      _selectedDate = DateTime.parse(widget.subTransaction!.date);
    }
  }

  Future<void> _saveSubTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;
    try {
      final data = {
        'transaction_id': widget.parentTransaction['id'],
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'date': _selectedDate.toIso8601String().split('T')[0],
        'notes': _notesController.text,
      };

      if (widget.subTransaction == null) {
        await supabase.from('sub_transactions').insert(data);
      } else {
        await supabase
            .from('sub_transactions')
            .update(data)
            .eq('id', widget.subTransaction!.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subTransaction == null
            ? 'Tambah Sub Transaksi'
            : 'Edit Sub Transaksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Jumlah harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSubTransaction,
        icon: const Icon(Icons.save),
        label: const Text('Simpan'),
      ),
    );
  }
} 