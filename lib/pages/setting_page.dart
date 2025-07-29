import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warikan/providers/theme_provider.dart';
import 'package:warikan/services/premium_service.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // プレミアム機能セクション
          isPremiumAsync.when(
            data: (isPremium) => _buildPremiumSection(context, ref, isPremium),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // テーマ設定セクション
          _buildSectionHeader('表示設定'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('テーマ'),
                  subtitle: Text(currentTheme.displayName),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showThemeDialog(context, ref),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // アプリ情報セクション
          _buildSectionHeader('アプリ情報'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('バージョン'),
                  subtitle: Text('1.1.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('アプリを評価'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // レビュー画面へ遷移
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('ヘルプ・お問い合わせ'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // ヘルプ画面へ遷移
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // データ管理セクション
          _buildSectionHeader('データ管理'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red.shade700),
                  title: Text(
                    'すべてのデータを削除',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  subtitle: const Text('この操作は取り消せません'),
                  onTap: () {
                    _showDeleteConfirmDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 80), // ナビゲーションバーの高さ分のスペース
        ],
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context, WidgetRef ref, bool isPremium) {
    if (isPremium) {
      // プレミアムユーザーの場合
      return Column(
        children: [
          _buildSectionHeader('Warikan Pro'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade50,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.star, color: Colors.amber.shade600),
                  title: const Text(
                    'Warikan Pro',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('プレミアム機能をご利用中'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('購入を復元'),
                  subtitle: const Text('他のデバイスでの購入を復元'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _restorePurchases(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    } else {
      // 無料ユーザーの場合
      return Column(
        children: [
          _buildSectionHeader('Warikan Pro'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.star, color: Colors.amber.shade600),
                  title: const Text(
                    'Warikan Proにアップグレード',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('広告なし・高度な機能'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showPremiumPurchaseDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('購入を復元'),
                  subtitle: const Text('他のデバイスでの購入を復元'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _restorePurchases(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeControllerProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テーマを選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((theme) {
            return RadioListTile<AppTheme>(
              title: Text(theme.displayName),
              value: theme,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeControllerProvider.notifier).setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning, color: Colors.red.shade700, size: 32),
        title: const Text('データ削除'),
        content: const Text(
          'すべての計算履歴が削除されます。\nこの操作は取り消すことができません。\n\n本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // データ削除処理
              _showDeleteSuccessSnackBar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべてのデータを削除しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPremiumPurchaseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.star, color: Colors.amber, size: 40),
        title: const Text('Warikan Pro'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プレミアム機能で割り勘をもっと便利に！',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.block, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('広告なしの快適な体験')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('カスタムタグ・カテゴリ機能')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('高度な統計・分析グラフ')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('メンバー管理・履歴機能')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.share, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('SNS共有機能（LINE・X）')),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '月額 ¥300',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('後で'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _purchasePremium(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('今すぐ購入'),
          ),
        ],
      ),
    );
  }

  void _purchasePremium(BuildContext context, WidgetRef ref) async {
    try {
      final premiumService = ref.read(premiumServiceProvider);
      await premiumService.buyPremium();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入処理を開始しました'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _restorePurchases(BuildContext context, WidgetRef ref) async {
    try {
      final premiumService = ref.read(premiumServiceProvider);
      await premiumService.restorePurchases();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入の復元を開始しました'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('復元に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
