import 'package:flutter/cupertino.dart';

class MoneySourcesScreen extends StatelessWidget {
  const MoneySourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Accounts'),
      ),
      child: Center(
        child: Text('Money Sources — TODO'),
      ),
    );
  }
}
