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

class _SavingsListScreenState extends State<SavingsListScreen> {
  List<Savings> savingsList = [];
  bool isLoading = true;
  String _selectedType = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadSavings();
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
              ).then((_) {
                // Reload data ketika kembali dari screen manajemen
                _loadSavings();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total per type cards in grid
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: ['Umroh', 'Dana Darurat', 'Pensiun'].map((type) {
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
                ),
                const SizedBox(height: 16),
                
                // Savings type filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _selectedType == 'Semua',
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = 'Semua';
                            });
                            _loadSavings();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...['Umroh', 'Dana Darurat', 'Pensiun'].map((type) =>
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type),
                            selected: _selectedType == type,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                                _loadSavings();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Savings cards
                ...savingsList.map((savings) => Card(
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