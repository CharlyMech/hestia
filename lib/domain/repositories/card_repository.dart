import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/payment_card.dart';

abstract class CardRepository {
  Future<(List<PaymentCard>, Failure?)> getCardsByAccount({
    required String accountId,
    bool activeOnly = true,
  });

  Future<(PaymentCard?, Failure?)> createCard(PaymentCard card);

  Future<Failure?> updateCard(PaymentCard card);

  Future<Failure?> deleteCard(String id);

  Future<Failure?> setPrimary(String cardId, String accountId);
}
