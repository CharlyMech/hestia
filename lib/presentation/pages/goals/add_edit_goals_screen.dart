import 'package:flutter/cupertino.dart';

class AddEditGoalScreen extends StatelessWidget {
  final String? goalId;

  const AddEditGoalScreen({super.key, this.goalId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(goalId != null ? 'Edit Goal' : 'New Goal'),
      ),
      child: const Center(
        child: Text('Add/Edit Goal — TODO'),
      ),
    );
  }
}
