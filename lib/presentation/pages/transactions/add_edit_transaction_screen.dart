import 'package:flutter/cupertino.dart';

class AddEditTransactionScreen extends StatelessWidget {
  final String? transactionId;

  const AddEditTransactionScreen({super.key, this.transactionId});

  bool get isEditing => transactionId != null;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Edit Transaction' : 'New Transaction'),
      ),
      child: const Center(
        child: Text('Add/Edit Transaction — TODO'),
      ),
    );
  }
}
