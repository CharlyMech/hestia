import 'package:flutter/cupertino.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Goal Details'),
      ),
      child: Center(
        child: Text('Goal Detail — TODO'),
      ),
    );
  }
}
