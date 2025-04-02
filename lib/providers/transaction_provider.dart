import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _transactions = [];
  final _dbHelper = DBHelper();
  RealtimeChannel? _transactionChannel;
  bool _isLoading = true;

  List<Map<String, dynamic>> get transactions => [..._transactions];
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _initializeRealtime();
    fetchTransactions();
  }

  void _initializeRealtime() {
    try {
      final supabase = Supabase.instance.client;
      
      _transactionChannel = supabase.channel('transactions').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'transactions',
        callback: (payload) async {
          await fetchTransactions();
        },
      );

      _transactionChannel?.subscribe();
    } catch (e) {
      debugPrint('Error initializing realtime: $e');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final transactions = await _dbHelper.getTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      await _dbHelper.insertTransaction(transaction);
      await fetchTransactions(); // Manual fetch for immediate UI update
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      await fetchTransactions(); // Refresh the list
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  @override
  void dispose() {
    _transactionChannel?.unsubscribe();
    super.dispose();
  }
}
