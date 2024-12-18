import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Group transactions by week
    final Map<String, List<Map<String, dynamic>>> weeklyTransactions = {};
    for (var tx in transactions) {
      final date = DateTime.parse(tx['date']);
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
      
      if (!weeklyTransactions.containsKey(weekKey)) {
        weeklyTransactions[weekKey] = [];
      }
      weeklyTransactions[weekKey]!.add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Mingguan'),
      ),
      body: ListView.builder(
        itemCount: weeklyTransactions.length,
        itemBuilder: (context, index) {
          final weekKey = weeklyTransactions.keys.elementAt(index);
          final weekTx = weeklyTransactions[weekKey]!;
          
          double totalIncome = weekTx
              .where((tx) => tx['type'] == 'Pemasukan')
              .fold(0, (sum, tx) => sum + tx['amount']);
          
          double totalExpense = weekTx
              .where((tx) => tx['type'] == 'Pengeluaran')
              .fold(0, (sum, tx) => sum + tx['amount']);

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minggu ${DateFormat('d MMM').format(DateTime.parse(weekKey))}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pemasukan'),
                          Text(
                            currencyFormat.format(totalIncome),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Pengeluaran'),
                          Text(
                            currencyFormat.format(totalExpense),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 