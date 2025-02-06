import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_installment.dart';

class AssetInstallmentProvider with ChangeNotifier {
  final List<AssetInstallment> _installments = [];
  bool _isLoading = false;

  List<AssetInstallment> get installments => [..._installments];
  bool get isLoading => _isLoading;

  final _supabase = Supabase.instance.client;

  Future<void> fetchInstallments(int assetId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('asset_installments')
          .select()
          .eq('asset_id', assetId)
          .order('due_date');

      _installments.clear();
      _installments.addAll(
        (response as List).map((item) => AssetInstallment.fromMap(item)).toList(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching installments: $e');
    }
  }

  Future<void> addInstallment(AssetInstallment installment) async {
    try {
      await _supabase.from('asset_installments').insert(installment.toMap());
      await fetchInstallments(installment.assetId);
    } catch (e) {
      debugPrint('Error adding installment: $e');
      rethrow;
    }
  }

  Future<void> updateInstallment(int id, AssetInstallment installment) async {
    try {
      await _supabase
          .from('asset_installments')
          .update(installment.toMap())
          .eq('id', id);
      await fetchInstallments(installment.assetId);
    } catch (e) {
      debugPrint('Error updating installment: $e');
      rethrow;
    }
  }

  Future<void> deleteInstallment(int id, int assetId) async {
    try {
      await _supabase.from('asset_installments').delete().eq('id', id);
      await fetchInstallments(assetId);
    } catch (e) {
      debugPrint('Error deleting installment: $e');
      rethrow;
    }
  }

  Future<void> markAsPaid(int id, int assetId) async {
    try {
      await _supabase.from('asset_installments').update({
        'is_paid': true,
        'paid_date': DateTime.now().toIso8601String().split('T')[0],
      }).eq('id', id);
      await fetchInstallments(assetId);
    } catch (e) {
      debugPrint('Error marking installment as paid: $e');
      rethrow;
    }
  }
} 