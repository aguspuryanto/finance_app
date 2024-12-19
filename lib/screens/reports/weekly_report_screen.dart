import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  late DateTime selectedDate;
  late int selectedYear;
  late int selectedMonth;
  late int selectedWeek;
  List<DateTime> weekStarts = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedYear = selectedDate.year;
    selectedMonth = selectedDate.month;
    _generateWeekStarts();
    // Set selected week based on current date
    selectedWeek = weekStarts.indexWhere((date) {
      return date.isBefore(selectedDate) && 
             date.add(const Duration(days: 7)).isAfter(selectedDate);
    });
    if (selectedWeek == -1) selectedWeek = 0;
  }

  void _generateWeekStarts() {
    weekStarts = [];
    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    var currentDay = firstDayOfMonth;

    // Go back to the first Monday before or on the first day of month
    while (currentDay.weekday != DateTime.monday) {
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    // Generate all week starts until we're past the end of the month
    while (currentDay.month == selectedMonth || 
           weekStarts.isEmpty || 
           currentDay.month == firstDayOfMonth.month) {
      weekStarts.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 7));
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

    // Get selected week's start and end dates
    final weekStart = weekStarts[selectedWeek];
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final thisWeekTransactions = transactions.where((tx) {
      final txDate = DateTime.parse(tx['date']);
      return txDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             txDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    final totalIncome = thisWeekTransactions
        .where((tx) => tx['type'] == 'Pemasukan')
        .fold(0.0, (sum, tx) => sum + tx['amount']);
    
    final totalExpense = thisWeekTransactions
        .where((tx) => tx['type'] == 'Pengeluaran')
        .fold(0.0, (sum, tx) => sum + tx['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Mingguan'),
      ),
      body: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedWeek,
              items: List.generate(weekStarts.length, (index) {
                final start = weekStarts[index];
                final end = start.add(const Duration(days: 6));
                return DropdownMenuItem(
                  value: index,
                  child: Text(
                    '${DateFormat('d MMM y').format(start)} - ${DateFormat('d MMM y').format(end)}',
                  ),
                );
              }),
              onChanged: (week) {
                if (week != null) {
                  setState(() {
                    selectedWeek = week;
                  });
                }
              },
            ),
          ),
          // Date Range Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM y').format(weekEnd)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
              itemCount: thisWeekTransactions.length,
              itemBuilder: (context, index) {
                final tx = thisWeekTransactions[index];
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
                            color: tx['type'] == 'Pemasukan' ? Colors.green : Colors.red,
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
                          DateFormat('E, d MMM y').format(DateTime.parse(tx['date'])),
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