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

    // Calculate grand total
    double grandTotal = totalPerType.values.fold(0, (sum, amount) => sum + amount);

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
              ).then((_) {
                // Reload data ketika kembali dari screen manajemen
                _loadSavings();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160), // Memperbesar ukuran dari 120 ke 160
          child: Column(
            children: [
              // Total cards grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // Total card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currencyFormat.format(grandTotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...['Umroh', 'Dana Darurat', 'Pensiun'].map((type) {
                      return Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyFormat.format(totalPerType[type] ?? 0),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabTypes.map((type) => Tab(text: type)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
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
                    )).toList(),
                  ],
                );
              }).toList(),
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