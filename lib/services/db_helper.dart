import 'package:supabase_flutter/supabase_flutter.dart';

class DBHelper {
  final supabase = Supabase.instance.client;

  Future<void> insertTransaction(Map<String, dynamic> data) async {
    try {
      await supabase.from('transactions').insert(data);
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<void> insertCategory(String name, String type) async {
    try {
      await supabase.from('categories').insert({
        'name': name,
        'type': type,
      });
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(String type) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('type', type);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await supabase
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await supabase
          .from('transactions')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
