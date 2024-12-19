import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late DateTime selectedDate;
  late int selectedMonth;
  List<DateTime> monthStarts = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _generateMonthStarts();
    selectedMonth = monthStarts.indexWhere((date) =>
        date.year == selectedDate.year && date.month == selectedDate.month);
    if (selectedMonth == -1) selectedMonth = 0;
  }

  void _generateMonthStarts() {
    monthStarts = [];
    final now = DateTime.now();
    // Generate last 24 months
    for (int i = 0; i < 24; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      monthStarts.insert(0, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Get selected month's start and end dates
    final monthStart = monthStarts[selectedMonth];
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    final thisMonthTransactions = transactions.where((tx) {
      final txDate = DateTime.parse(tx['date']);
      return txDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          txDate.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final totalIncome = thisMonthTransactions
        .where((tx) => tx['type'] == 'Pemasukan')
        .fold(0.0, (sum, tx) => sum + tx['amount']);

    final totalExpense = thisMonthTransactions
        .where((tx) => tx['type'] == 'Pengeluaran')
        .fold(0.0, (sum, tx) => sum + tx['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
      ),
      body: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedMonth,
              items: List.generate(monthStarts.length, (index) {
                final date = monthStarts[index];
                return DropdownMenuItem(
                  value: index,
                  child: Text(DateFormat('MMMM y').format(date)),
                );
              }),
              onChanged: (month) {
                if (month != null) {
                  setState(() {
                    selectedMonth = month;
                  });
                }
              },
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalIncome),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengeluaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalExpense),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: thisMonthTransactions.length,
              itemBuilder: (context, index) {
                final tx = thisMonthTransactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tx['title'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          currencyFormat.format(tx['amount']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tx['type'] == 'Pemasukan'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          tx['category'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('E, d MMM y').format(
                              DateTime.parse(tx['date'])),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
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