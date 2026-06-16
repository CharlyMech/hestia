// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_session_dao.dart';

// ignore_for_file: type=lint
mixin _$ShoppingSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalShoppingSessionsTable get localShoppingSessions =>
      attachedDatabase.localShoppingSessions;
  $LocalShoppingSessionItemsTable get localShoppingSessionItems =>
      attachedDatabase.localShoppingSessionItems;
  ShoppingSessionDaoManager get managers => ShoppingSessionDaoManager(this);
}

class ShoppingSessionDaoManager {
  final _$ShoppingSessionDaoMixin _db;
  ShoppingSessionDaoManager(this._db);
  $$LocalShoppingSessionsTableTableManager get localShoppingSessions =>
      $$LocalShoppingSessionsTableTableManager(
          _db.attachedDatabase, _db.localShoppingSessions);
  $$LocalShoppingSessionItemsTableTableManager get localShoppingSessionItems =>
      $$LocalShoppingSessionItemsTableTableManager(
          _db.attachedDatabase, _db.localShoppingSessionItems);
}
