import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  // 割り勘結果をテキスト形式でフォーマット
  static String formatWarikanResult({
    required int totalAmount,
    required int totalPeople,
    required int perPersonAmount,
    required int remainingAmount,
    String? eventName,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('💰 割り勘結果');
    if (eventName != null && eventName.isNotEmpty) {
      buffer.writeln('📝 イベント: $eventName');
    }
    buffer.writeln('');
    buffer.writeln('合計金額: ¥${_formatCurrency(totalAmount)}');
    buffer.writeln('参加人数: ${totalPeople}人');
    buffer.writeln('');
    buffer.writeln('👤 一人当たり: ¥${_formatCurrency(perPersonAmount)}');
    
    if (remainingAmount > 0) {
      buffer.writeln('余り: ¥${_formatCurrency(remainingAmount)}');
    }
    
    buffer.writeln('');
    buffer.writeln('📱 Warikaアプリで計算しました');
    
    return buffer.toString();
  }

  // 傾斜割り勘結果をテキスト形式でフォーマット
  static String formatKeishaResult({
    required int totalAmount,
    required int totalPeople,
    required int perPersonAmount,
    required int remainingPeople,
    required List<Map<String, dynamic>> groups,
    String? eventName,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('💰 傾斜割り勘結果');
    if (eventName != null && eventName.isNotEmpty) {
      buffer.writeln('📝 イベント: $eventName');
    }
    buffer.writeln('');
    buffer.writeln('合計金額: ¥${_formatCurrency(totalAmount)}');
    buffer.writeln('参加人数: ${totalPeople}人');
    buffer.writeln('');
    
    // グループ情報
    if (groups.isNotEmpty) {
      buffer.writeln('🏷️ グループ別金額:');
      for (final group in groups) {
        final groupName = group['name'] ?? '';
        final groupAmount = group['amount'] ?? 0;
        final groupPeople = group['people'] ?? 0;
        final slope = group['slope'] ?? '';
        buffer.writeln('  • $groupName: ¥${_formatCurrency(groupAmount)} (${groupPeople}人) $slope');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('👤 基本料金: ¥${_formatCurrency(perPersonAmount)}');
    if (remainingPeople > 0) {
      buffer.writeln('基本料金対象: ${remainingPeople}人');
    }
    
    buffer.writeln('');
    buffer.writeln('📱 Warikaアプリで計算しました');
    
    return buffer.toString();
  }

  // 通貨フォーマット（カンマ区切り）
  static String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 汎用共有機能
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: subject));
    } catch (e) {
      debugPrint('共有に失敗しました: $e');
      rethrow;
    }
  }

  // LINEで共有
  static Future<void> shareToLine(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final lineUrl = 'https://line.me/R/msg/text/?$encodedText';
      
      if (await canLaunchUrl(Uri.parse(lineUrl))) {
        await launchUrl(Uri.parse(lineUrl), mode: LaunchMode.externalApplication);
      } else {
        // LINEアプリがない場合は通常の共有
        await shareText(text);
      }
    } catch (e) {
      debugPrint('LINE共有に失敗しました: $e');
      // フォールバックとして通常の共有
      await shareText(text);
    }
  }

  // Xで共有
  static Future<void> shareToX(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final xUrl = 'https://x.com/intent/tweet?text=$encodedText';
      
      if (await canLaunchUrl(Uri.parse(xUrl))) {
        await launchUrl(Uri.parse(xUrl), mode: LaunchMode.externalApplication);
      } else {
        // Xアプリがない場合は通常の共有
        await shareText(text);
      }
    } catch (e) {
      debugPrint('X共有に失敗しました: $e');
      // フォールバックとして通常の共有
      await shareText(text);
    }
  }

  // 共有オプションを表示するダイアログ
  static void showShareDialog({
    required BuildContext context,
    required String shareText,
    required bool isPremium,
    required VoidCallback onPremiumRequired,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '割り勘結果を共有',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (!isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'プレミアム機能',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const Text(
                            'SNS共有はWarikan Proでご利用いただけます',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPremiumRequired();
                      },
                      child: const Text('アップグレード'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 共有オプション
            _buildShareOption(
              context: context,
              icon: Icons.share,
              title: '他のアプリで共有',
              subtitle: '標準の共有機能を使用',
              onTap: isPremium ? () {
                Navigator.pop(context);
                ShareService.shareText(shareText);
              } : null,
            ),
            
            _buildShareOption(
              context: context,
              icon: Icons.message,
              title: 'LINEで共有',
              subtitle: 'LINEアプリで開く',
              color: const Color(0xFF00B900),
              onTap: isPremium ? () {
                Navigator.pop(context);
                shareToLine(shareText);
              } : null,
            ),
            
            _buildShareOption(
              context: context,
              icon: Icons.alternate_email,
              title: 'Xで共有',
              subtitle: 'X (Twitter) アプリで開く',
              color: Colors.black,
              onTap: isPremium ? () {
                Navigator.pop(context);
                shareToX(shareText);
              } : null,
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: isEnabled,
        leading: CircleAvatar(
          backgroundColor: isEnabled 
            ? (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1)
            : Colors.grey.shade200,
          child: Icon(
            icon,
            color: isEnabled 
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isEnabled ? Colors.grey.shade600 : Colors.grey,
          ),
        ),
        trailing: isEnabled 
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : Icon(Icons.lock, color: Colors.grey.shade400, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}