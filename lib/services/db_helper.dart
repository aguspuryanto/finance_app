import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await supabase
          .from('transactions')
          .select('*')
          .order('created_at', ascending: false);
      
      debugPrint('Transactions fetched: ${response.toString()}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(String type) async {
    try {
      final response = await supabase
          .from('categories')
          .select('*')
          .eq('type', type)
          .order('name');
      
      debugPrint('Categories fetched: ${response.toString()}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    try {
      await supabase.from('transactions').insert(transaction);
      debugPrint('Transaction inserted successfully');
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
      throw Exception('Failed to insert transaction');
    }
  }

  Future<void> insertCategory(String name, String type) async {
    try {
      await supabase.from('categories').insert({
        'name': name,
        'type': type,
      });
      debugPrint('Category inserted successfully');
    } catch (e) {
      debugPrint('Error inserting category: $e');
      throw Exception('Failed to insert category');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await supabase
          .from('transactions')
          .delete()
          .eq('id', id);
      debugPrint('Transaction deleted successfully');
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await supabase
          .from('categories')
          .delete()
          .eq('id', id);
      debugPrint('Category deleted successfully');
    } catch (e) {
      debugPrint('Error deleting category: $e');
      throw Exception('Failed to delete category');
    }
  }
}
