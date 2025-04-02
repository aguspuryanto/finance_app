import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/db_helper.dart';

class CategoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _categories = [];
  final _dbHelper = DBHelper();
  String _currentType = 'Pemasukan';
  RealtimeChannel? _categoryChannel;

  List<Map<String, dynamic>> get categories => [..._categories];

  CategoryProvider() {
    _initializeRealtime();
  }

  void _initializeRealtime() {
    try {
      final supabase = Supabase.instance.client;
      
      _categoryChannel = supabase.channel('categories').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'categories',
        callback: (payload) async {
          await fetchCategories(_currentType);
        },
      );

      _categoryChannel?.subscribe();
    } catch (e) {
      debugPrint('Error initializing realtime: $e');
    }
  }

  Future<void> fetchCategories(String type) async {
    try {
      _currentType = type;
      final categories = await _dbHelper.getCategories(type);
      _categories.clear();
      _categories.addAll(categories);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(String name, String type) async {
    try {
      await _dbHelper.insertCategory(name, type);
      await fetchCategories(type);
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      await fetchCategories(_currentType);
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  @override
  void dispose() {
    _categoryChannel?.unsubscribe();
    super.dispose();
  }
}
