import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<SubTransaction> subTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubTransactions();
  }

  Future<void> _loadSubTransactions() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('sub_transactions')
          .select()
          .eq('transaction_id', widget.transaction['id'])
          .order('date', ascending: false);
      
      setState(() {
        subTransactions = (response as List)
            .map((item) => SubTransaction.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sub transactions: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit transaction
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Transaction details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.transaction['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(widget.transaction['amount']),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.transaction['type'] == 'Pemasukan'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.transaction['category']} • ${widget.transaction['date']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sub transactions section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sub Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah'),
                      onPressed: () {
                        // TODO: Implement add sub transaction
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Sub transactions list
                ...subTransactions.map((sub) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(sub.title),
                    subtitle: Text(sub.date),
                    trailing: Text(
                      currencyFormat.format(sub.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // TODO: Implement edit sub transaction
                    },
                  ),
                )).toList(),
              ],
            ),
    );
  }
} 