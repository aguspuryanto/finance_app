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
              ).then((_) => _loadSavings());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          AspectRatio(
            aspectRatio: 1.5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    childAspectRatio: isTablet ? 2.0 : 1.6,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    String title;
                    double amount;
                    Color color;

                    switch (index) {
                      case 0:
                        title = 'Total';
                        amount = grandTotal;
                        color = Theme.of(context).primaryColor;
                        break;
                      case 1:
                        title = 'Umroh';
                        amount = totalPerType['Umroh'] ?? 0;
                        color = Colors.green;
                        break;
                      case 2:
                        title = 'Dana Darurat';
                        amount = totalPerType['Dana Darurat'] ?? 0;
                        color = Colors.orange;
                        break;
                      default:
                        title = 'Pensiun';
                        amount = totalPerType['Pensiun'] ?? 0;
                        color = Colors.blue;
                    }

                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.1),
                              color.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currencyFormat.format(amount),
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 13,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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