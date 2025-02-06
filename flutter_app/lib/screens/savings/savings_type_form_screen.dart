import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/savings_type.dart';

class SavingsTypeFormScreen extends StatefulWidget {
  final SavingsType? savingsType;

  const SavingsTypeFormScreen({super.key, this.savingsType});

  @override
  State<SavingsTypeFormScreen> createState() => _SavingsTypeFormScreenState();
}

class _SavingsTypeFormScreenState extends State<SavingsTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.savingsType != null) {
      _nameController.text = widget.savingsType!.name;
      _descriptionController.text = widget.savingsType!.description ?? '';
      _iconController.text = widget.savingsType!.icon ?? '';
      _colorController.text = widget.savingsType!.color ?? '';
    }
  }

  Future<void> _saveSavingsType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'icon': _iconController.text,
        'color': _colorController.text,
      };

      if (widget.savingsType == null) {
        await supabase.from('savings_types').insert(data);
      } else {
        await supabase
            .from('savings_types')
            .update(data)
            .eq('id', widget.savingsType!.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.savingsType == null
            ? 'Tambah Jenis Tabungan'
            : 'Edit Jenis Tabungan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (mosque, emergency, elderly)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Warna (format: #RRGGBB)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveSavingsType,
        icon: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: const Text('Simpan'),
      ),
    );
  }
} 