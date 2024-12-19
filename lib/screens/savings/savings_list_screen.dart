import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/savings.dart';
import 'add_savings_screen.dart';
import 'manage_savings_types_screen.dart';

class SavingsListScreen extends StatefulWidget {
  const SavingsListScreen({super.key});

  @override
  State<SavingsListScreen> createState() => _SavingsListScreenState();
}

class _SavingsListScreenState extends State<SavingsListScreen> with SingleTickerProviderStateMixin {
  List<Savings> savingsList = [];
  bool isLoading = true;
  String _selectedType = 'Semua';
  late TabController _tabController;
  final List<String> _tabTypes = ['Semua', 'Umroh', 'Dana Darurat', 'Pensiun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTypes.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedType = _tabTypes[_tabController.index];
        });
        _loadSavings();
      }
    });
    _loadSavings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavings() async {
    final supabase = Supabase.instance.client;
    try {
      final query = supabase
          .from('savings')
          .select();
          
      if (_selectedType != 'Semua') {
        query.filter('type', 'eq', _selectedType);
      }
          
      final response = await query.order('date', ascending: false);
          
      setState(() {
        savingsList = (response as List)
            .map((item) => Savings.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading savings: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Hitung total tabungan per tipe
    Map<String, double> totalPerType = {};
    for (var savings in savingsList) {
      totalPerType[savings.type] = (totalPerType[savings.type] ?? 0) + savings.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSavingsTypesScreen(),
                ),
              ).then((_) => _loadSavings());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Total Row
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.indigo,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Total'),
                      const Spacer(),
                      Text(
                        currencyFormat.format(
                          totalPerType.values.fold(0.0, (sum, amount) => sum + amount)
                        ),
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.mosque,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Umroh'),
                      const Spacer(),
                      Text(
                        currencyFormat.format(totalPerType['Umroh'] ?? 0),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.emergency,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Dana Darurat'),
                      const Spacer(),
                      Text(
                        currencyFormat.format(totalPerType['Dana Darurat'] ?? 0),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.elderly,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Pensiun'),
                      const Spacer(),
                      Text(
                        currencyFormat.format(totalPerType['Pensiun'] ?? 0),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _tabTypes.map((type) => Tab(text: type)).toList(),
          ),

          // TabBarView with transactions
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _tabTypes.map((type) {
                      final filteredList = type == 'Semua'
                          ? savingsList
                          : savingsList.where((saving) => saving.type == type).toList();

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...filteredList.map((savings) => Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Dismissible(
                                  key: Key(savings.id.toString()),
                                  background: Container(
                                    color: Colors.red.shade100,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text('Yakin ingin menghapus tabungan ini?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    try {
                                      await Supabase.instance.client
                                          .from('savings')
                                          .delete()
                                          .eq('id', savings.id);
                                      
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Tabungan berhasil dihapus'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        _loadSavings(); // Refresh data
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currencyFormat.format(savings.amount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          savings.type,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tanggal: ${savings.date}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (savings.notes != null && savings.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            savings.notes!,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSavingsScreen(),
            ),
          );
          if (result == true) {
            _loadSavings();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tabungan'),
      ),
    );
  }
} 