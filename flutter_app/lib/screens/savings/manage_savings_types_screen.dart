import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/savings_type.dart';
import 'savings_type_form_screen.dart';

class ManageSavingsTypesScreen extends StatefulWidget {
  const ManageSavingsTypesScreen({super.key});

  @override
  State<ManageSavingsTypesScreen> createState() => _ManageSavingsTypesScreenState();
}

class _ManageSavingsTypesScreenState extends State<ManageSavingsTypesScreen> {
  List<SavingsType> savingsTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavingsTypes();
  }

  Future<void> _loadSavingsTypes() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('savings_types')
          .select()
          .order('name');
      
      setState(() {
        savingsTypes = (response as List)
            .map((item) => SavingsType.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading savings types: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteSavingsType(SavingsType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus jenis tabungan "${type.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('savings_types')
          .delete()
          .eq('id', type.id);
      
      _loadSavingsTypes(); // Reload data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jenis tabungan berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jenis Tabungan'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: savingsTypes.length,
              itemBuilder: (context, index) {
                final type = savingsTypes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      type.iconData ?? Icons.savings,
                      color: type.colorValue,
                    ),
                    title: Text(type.name),
                    subtitle: Text(type.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavingsTypeFormScreen(
                                  savingsType: type,
                                ),
                              ),
                            ).then((updated) {
                              if (updated == true) {
                                _loadSavingsTypes();
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteSavingsType(type),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavingsTypeFormScreen(),
            ),
          ).then((added) {
            if (added == true) {
              _loadSavingsTypes();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 