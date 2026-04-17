import 'package:flutter/cupertino.dart';

class AddEditMoneySourceScreen extends StatelessWidget {
  final String? sourceId;

  const AddEditMoneySourceScreen({super.key, this.sourceId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(sourceId != null ? 'Edit Account' : 'New Account'),
      ),
      child: const Center(
        child: Text('Add/Edit Money Source — TODO'),
      ),
    );
  }
}
