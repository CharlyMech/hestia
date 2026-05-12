import 'package:flutter/cupertino.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// Bottom-sheet form for creating / editing / deleting a [Category].
class CategoryFormContent extends StatefulWidget {
  final Category? existing;
  final String householdId;

  /// Used when [existing] is null.
  final TransactionType initialType;

  const CategoryFormContent({
    super.key,
    this.existing,
    required this.householdId,
    this.initialType = TransactionType.expense,
  });

  @override
  State<CategoryFormContent> createState() => _CategoryFormContentState();
}

class _CategoryFormContentState extends State<CategoryFormContent> {
  late final TextEditingController _name;
  late TransactionType _type;
  late int _colorIdx;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.type ?? widget.initialType;
    _colorIdx = 0;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<Color> _swatches(MyTheme theme) {
    final tints = theme.categoryTints
        .map((h) => Color(int.parse(h.replaceFirst('#', '0xff'))))
        .toList();
    return [
      Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff'))),
      Color(int.parse(theme.colorGreen.replaceFirst('#', '0xff'))),
      ...tints,
      Color(int.parse(theme.colorRed.replaceFirst('#', '0xff'))),
    ];
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final theme = context.myTheme;
    final swatches = _swatches(theme);
    final hex =
        '#${swatches[_colorIdx].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final now = DateTime.now();
    final repo = AppDependencies.instance.categoryRepository;

    setState(() => _saving = true);
    if (widget.existing == null) {
      final cat = Category(
        id: '',
        householdId: widget.householdId,
        name: name,
        type: _type,
        color: hex,
        icon: null,
        isActive: true,
        sortOrder: 0,
        createdAt: now,
        lastUpdate: now,
      );
      final (_, failure) = await repo.createCategory(cat);
      if (!mounted) return;
      setState(() => _saving = false);
      if (failure != null) {
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Could not save'),
            content: Text(failure.message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    } else {
      final updated = Category(
        id: widget.existing!.id,
        householdId: widget.existing!.householdId,
        name: name,
        type: widget.existing!.type,
        color: hex,
        icon: widget.existing!.icon,
        isActive: widget.existing!.isActive,
        sortOrder: widget.existing!.sortOrder,
        createdAt: widget.existing!.createdAt,
        lastUpdate: now,
      );
      final failure = await repo.updateCategory(updated);
      if (!mounted) return;
      setState(() => _saving = false);
      if (failure != null) {
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Could not save'),
            content: Text(failure.message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    if (widget.existing == null) return;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete category'),
        content: const Text(
          'Transactions that used this category keep their history; the category is removed from pickers.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    final failure = await AppDependencies.instance.categoryRepository
        .deleteCategory(widget.existing!.id);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Could not delete'),
          content: Text(failure.message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final border =
        Color(int.parse(theme.borderColor.replaceFirst('#', '0xff')));
    final fg =
        Color(int.parse(theme.onBackgroundColor.replaceFirst('#', '0xff')));
    final muted =
        Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final expense = Color(int.parse(theme.colorRed.replaceFirst('#', '0xff')));
    final swatches = _swatches(theme);
    final isEdit = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          _label('Name', muted),
          Container(
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CupertinoTextField(
              controller: _name,
              placeholder: 'e.g. Groceries',
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              style: AppFonts.body(fontSize: 14, color: fg),
            ),
          ),
          if (!isEdit) ...[
            _label('Type', muted),
            SegmentedControl(
              options: const ['Expense', 'Income'],
              active: _type == TransactionType.expense ? 0 : 1,
              onChanged: (i) => setState(() => _type =
                  i == 0 ? TransactionType.expense : TransactionType.income),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              activeColor: accent,
              activeFg: CupertinoColors.white,
            ),
          ],
          _label('Color', muted),
          ColorSwatchRow(
            colors: swatches,
            selected: _colorIdx,
            onSelected: (i) => setState(() => _colorIdx = i),
            bg: surface,
          ),
          const SizedBox(height: 4),
          Row(
            spacing: 10,
            children: [
              if (isEdit)
                Expanded(
                  child: CupertinoButton(
                    color: surface,
                    onPressed: _saving ? null : _confirmDelete,
                    child: Text(
                      'Delete',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: expense,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: isEdit ? 1 : 2,
                child: CupertinoButton.filled(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CupertinoActivityIndicator()
                      : Text(isEdit ? 'Save' : 'Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t, Color muted) =>
      Text(t.toUpperCase(), style: AppFonts.sectionLabel(color: muted));
}
