import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/toggle_switch.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show
        Xmark,
        Cart,
        CreditCard,
        Calendar,
        Refresh,
        EditPencil,
        Erase;

class AddEditTransactionScreen extends StatefulWidget {
  final String? transactionId;
  const AddEditTransactionScreen({super.key, this.transactionId});

  bool get isEditing => transactionId != null;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  int _kind = 0; // 0=Expense 1=Income 2=Transfer
  bool _repeat = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final expense = _c(theme.colorRed);

    final keys = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  IconBtn(
                    icon: Xmark(width: 16, height: 16, color: fg),
                    surface: surface,
                    border: border,
                    onTap: () => context.pop(),
                    size: 36,
                    radius: 10,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.isEditing ? 'Edit transaction' : 'New transaction',
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Type tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedControl(
                options: const ['Expense', 'Income', 'Transfer'],
                active: _kind,
                onChanged: (i) => setState(() => _kind = i),
                surface: surface,
                border: border,
                fg: fg,
                muted: muted,
                activeColor: surface2,
              ),
            ),

            const SizedBox(height: 30),

            // Amount
            Column(
              children: [
                Text(
                  'AMOUNT · EUR',
                  style: AppFonts.sectionLabel(color: muted),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '−24',
                      style: AppFonts.numeric(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        color: expense,
                      ),
                    ),
                    Text(
                      '.50',
                      style: AppFonts.numeric(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: expense.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '€',
                      style: AppFonts.body(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _BlinkingCaret(color: accent),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _FieldTile(
                      icon: Cart(width: 18, height: 18, color: tints[0]),
                      iconColor: tints[0],
                      label: 'Category',
                      value: 'Dining',
                      sub: 'Subcat · Restaurants',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                    const SizedBox(height: 8),
                    _FieldTile(
                      icon: CreditCard(width: 18, height: 18, color: tints[2]),
                      iconColor: tints[2],
                      label: 'From',
                      value: 'Ana · Revolut',
                      sub: 'Balance 1,284€',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                    const SizedBox(height: 8),
                    _FieldTile(
                      icon: Calendar(width: 18, height: 18, color: tints[1]),
                      iconColor: tints[1],
                      label: 'Date',
                      value: 'Today',
                      sub: '22 April, 2026',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                    ),
                    const SizedBox(height: 8),
                    _FieldTile(
                      icon: Refresh(width: 18, height: 18, color: tints[3]),
                      iconColor: tints[3],
                      label: 'Repeat',
                      value: _repeat ? 'Recurring' : 'One-time',
                      surface: surface,
                      border: border,
                      fg: fg,
                      muted: muted,
                      trailing: ToggleSwitch(
                        value: _repeat,
                        onChanged: (v) => setState(() => _repeat = v),
                        activeColor: accent,
                        inactiveColor: border,
                        width: 34,
                        height: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: surface,
                        border: Border.all(color: border, width: 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          EditPencil(width: 16, height: 16, color: muted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add a note…',
                              style: AppFonts.body(fontSize: 13, color: muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Keypad
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 46,
                    ),
                    itemCount: keys.length,
                    itemBuilder: (_, i) {
                      final k = keys[i];
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: surface,
                            border: Border.all(color: border, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: k == '⌫'
                              ? Erase(width: 18, height: 18, color: fg)
                              : Text(
                                  k,
                                  style: AppFonts.numeric(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: fg,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.pop(),
                      child: Text(
                        'Save transaction',
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _FieldTile extends StatelessWidget {
  final Widget icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? sub;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Widget? trailing;

  const _FieldTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.sub,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CatTile(icon: icon, color: iconColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppFonts.label(
                    fontSize: 11,
                    color: muted,
                    letterSpacing: 0.55,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    sub!,
                    style: AppFonts.body(
                      fontSize: 11,
                      color: muted.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? ChevronIcon(color: muted),
        ],
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  final Color color;
  const _BlinkingCaret({required this.color});

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_c),
      child: Container(
        width: 2,
        height: 44,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
