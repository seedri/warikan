import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warikan/providers/theme_provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
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
                  leading: const Icon(Icons.download),
                  title: const Text('データをエクスポート'),
                  subtitle: const Text('計算履歴をCSV形式でエクスポート'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // エクスポート機能（有料機能）
                    _showPremiumFeatureDialog(context);
                  },
                ),
                const Divider(height: 1),
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

  void _showPremiumFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.star, color: Colors.amber, size: 32),
        title: const Text('プレミアム機能'),
        content: const Text(
          'データエクスポート機能はWarikan Proでご利用いただけます。\n\n'
          '• 広告なしの快適な体験\n'
          '• CSV/PDF形式でのデータエクスポート\n'
          '• 月別・年別レポート生成',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('後で'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // プレミアム購入画面へ遷移
            },
            child: const Text('プレミアムにアップグレード'),
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
}
