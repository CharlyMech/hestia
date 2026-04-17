import 'package:flutter/cupertino.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Goals'),
      ),
      child: Center(
        child: Text('Goals — TODO'),
      ),
    );
  }
}
