import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Group transactions by month
    final Map<String, List<Map<String, dynamic>>> monthlyTransactions = {};
    for (var tx in transactions) {
      final date = DateTime.parse(tx['date']);
      final monthKey = DateFormat('yyyy-MM').format(date);
      
      if (!monthlyTransactions.containsKey(monthKey)) {
        monthlyTransactions[monthKey] = [];
      }
      monthlyTransactions[monthKey]!.add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
      ),
      body: ListView.builder(
        itemCount: monthlyTransactions.length,
        itemBuilder: (context, index) {
          final monthKey = monthlyTransactions.keys.elementAt(index);
          final monthTx = monthlyTransactions[monthKey]!;
          
          double totalIncome = monthTx
              .where((tx) => tx['type'] == 'Pemasukan')
              .fold(0, (sum, tx) => sum + tx['amount']);
          
          double totalExpense = monthTx
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
                    DateFormat('MMMM yyyy').format(DateTime.parse('$monthKey-01')),
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