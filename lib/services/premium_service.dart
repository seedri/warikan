import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warikan/models/premium_user.dart';

class PremiumService {
  static const String _premiumProductId = 'warikan_pro_monthly';
  static const String _kPremiumStatusKey = 'premium_status';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Isar isar;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  PremiumService(this.isar);

  // 商品ID一覧
  static const Set<String> _productIds = {_premiumProductId};

  // 購入リスナーの初期化
  void initializePurchaseStream() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
  }

  // ストアでの商品情報を取得
  Future<List<ProductDetails>> getProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('Store not available');
    }

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    
    return response.productDetails;
  }

  // プレミアム購入処理
  Future<void> buyPremium() async {
    final List<ProductDetails> products = await getProducts();
    
    if (products.isEmpty) {
      throw Exception('No products available');
    }

    final ProductDetails premiumProduct = products.firstWhere(
      (product) => product.id == _premiumProductId,
      orElse: () => throw Exception('Premium product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: premiumProduct);
    
    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase failed: $e');
      rethrow;
    }
  }

  // 購入復元処理
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Restore failed: $e');
      rethrow;
    }
  }

  // 購入状態のチェック
  Future<bool> isPremiumUser() async {
    try {
      // まずIsarから確認
      final premiumUser = await isar.premiumUsers.where().findFirst();
      if (premiumUser != null && premiumUser.isPremium) {
        return true;
      }

      // SharedPreferencesからも確認（フォールバック）
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kPremiumStatusKey) ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  // 購入完了時の処理
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // 購入処理中
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 購入完了または復元完了
          await _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          // 購入エラー
          debugPrint('Purchase error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.canceled:
          // 購入キャンセル
          debugPrint('Purchase canceled');
          break;
      }

      // 処理完了後、購入処理を完了する
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // 購入成功時の処理
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Isarに保存
      final premiumUser = PremiumUser(
        productId: purchaseDetails.productID,
        isPremium: true,
        purchaseDate: DateTime.now(),
        originalTransactionId: _getOriginalTransactionId(purchaseDetails),
        transactionId: purchaseDetails.purchaseID,
      );

      await isar.writeTxn(() async {
        // 既存のデータを削除してから新しいデータを保存
        await isar.premiumUsers.clear();
        await isar.premiumUsers.put(premiumUser);
      });

      // SharedPreferencesにも保存（フォールバック）
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPremiumStatusKey, true);

      debugPrint('Premium purchase saved successfully');
    } catch (e) {
      debugPrint('Error saving premium purchase: $e');
    }
  }

  // プラットフォーム固有のトランザクションID取得
  String? _getOriginalTransactionId(PurchaseDetails purchaseDetails) {
    if (Platform.isIOS) {
      // iOS の場合は購入IDをそのまま使用
      return purchaseDetails.purchaseID;
    } else if (Platform.isAndroid) {
      // Android の場合も購入IDをそのまま使用
      return purchaseDetails.purchaseID;
    }
    return purchaseDetails.purchaseID;
  }

  // ストリーム終了時の処理
  void _updateStreamOnDone() {
    debugPrint('Purchase stream done');
  }

  // ストリームエラー時の処理
  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  // リソースの解放
  void dispose() {
    _subscription?.cancel();
  }
}

// Riverpod プロバイダー
final premiumServiceProvider = Provider<PremiumService>((ref) {
  throw UnimplementedError('PremiumService must be overridden');
});

final isPremiumProvider = FutureProvider<bool>((ref) async {
  final premiumService = ref.read(premiumServiceProvider);
  return await premiumService.isPremiumUser();
});