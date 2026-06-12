import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mappers/card_mapper.dart';
import 'package:hestia/data/services/card_service.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final CardService _service;

  CardRepositoryImpl(this._service);

  @override
  Future<(List<PaymentCard>, Failure?)> getCardsByAccount({
    required String accountId,
    bool activeOnly = true,
  }) async {
    try {
      final data = await _service.getCardsByAccount(
        accountId: accountId,
        activeOnly: activeOnly,
      );
      final cards = data.map(CardMapper.fromJson).toList();
      return (cards, null);
    } catch (e) {
      return (const <PaymentCard>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<(PaymentCard?, Failure?)> createCard(PaymentCard card) async {
    try {
      final dto = CardMapper.toDto(card);
      final data = await _service.createCard(dto.toInsertJson());
      return (CardMapper.fromJson(data), null);
    } catch (e) {
      return (null, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> updateCard(PaymentCard card) async {
    try {
      final dto = CardMapper.toDto(card);
      await _service.updateCard(card.id, dto.toUpdateJson());
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> deleteCard(String id) async {
    try {
      await _service.deleteCard(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> setPrimary(String cardId, String accountId) async {
    try {
      await _service.setPrimary(cardId, accountId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
