import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset.dart';

class AssetProvider with ChangeNotifier {
  final List<Asset> _assets = [];
  bool _isLoading = false;

  List<Asset> get assets => [..._assets];
  bool get isLoading => _isLoading;

  final _supabase = Supabase.instance.client;

  Future<void> fetchAssets() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('assets')
          .select()
          .order('created_at', ascending: false);

      _assets.clear();
      _assets.addAll(
        (response as List).map((asset) => Asset.fromMap(asset)).toList(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching assets: $e');
    }
  }

  Future<void> addAsset(Asset asset) async {
    try {
      await _supabase.from('assets').insert(asset.toMap());
      await fetchAssets();
    } catch (e) {
      debugPrint('Error adding asset: $e');
      rethrow;
    }
  }

  Future<void> updateAsset(int id, Asset asset) async {
    try {
      await _supabase.from('assets').update(asset.toMap()).eq('id', id);
      await fetchAssets();
    } catch (e) {
      debugPrint('Error updating asset: $e');
      rethrow;
    }
  }

  Future<void> deleteAsset(int id) async {
    try {
      await _supabase.from('assets').delete().eq('id', id);
      await fetchAssets();
    } catch (e) {
      debugPrint('Error deleting asset: $e');
      rethrow;
    }
  }
} 