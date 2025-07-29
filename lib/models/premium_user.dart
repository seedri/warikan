import 'package:isar/isar.dart';

part 'premium_user.g.dart';

@collection
class PremiumUser {
  Id id = Isar.autoIncrement;

  @Index()
  String? productId;

  @Index()
  bool isPremium;

  DateTime? purchaseDate;

  String? originalTransactionId;

  String? transactionId;

  PremiumUser({
    this.productId,
    this.isPremium = false,
    this.purchaseDate,
    this.originalTransactionId,
    this.transactionId,
  });
}