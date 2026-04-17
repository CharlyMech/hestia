import 'package:flutter/cupertino.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Transactions'),
      ),
      child: Center(
        child: Text('Transactions — TODO'),
      ),
    );
  }
}
