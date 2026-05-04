import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/shopping/shopping_list_form_content.dart';

/// New / edit shopping list (stack route). Tab "+" uses the same form in
/// [showAppBottomSheet] from [ShoppingScreen].
class AddEditShoppingListScreen extends StatefulWidget {
  final String householdId;
  final String userId;
  final ShoppingList? existing;

  const AddEditShoppingListScreen({
    super.key,
    required this.householdId,
    required this.userId,
    this.existing,
  });

  @override
  State<AddEditShoppingListScreen> createState() =>
      _AddEditShoppingListScreenState();
}

class _AddEditShoppingListScreenState extends State<AddEditShoppingListScreen> {
  final GlobalKey<ShoppingListFormContentState> _formKey =
      GlobalKey<ShoppingListFormContentState>();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: widget.existing != null
          ? 'Edit shopping list'
          : 'New shopping list',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _formKey.currentState?.submit(),
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            widget.existing != null ? 'Save' : 'Create',
            style: AppFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
      child: ShoppingListFormContent(
        key: _formKey,
        householdId: widget.householdId,
        userId: widget.userId,
        existing: widget.existing,
        onSuccess: () {
          if (context.mounted) context.pop();
        },
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
