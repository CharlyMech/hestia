import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/blocs/transaction_sources/transaction_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

/// Bottom-sheet form for creating / editing / deleting a [TransactionSource].
class TransactionSourceForm extends StatefulWidget {
  final TransactionSource? existing;
  final String householdId;
  final String userId;

  const TransactionSourceForm({
    super.key,
    this.existing,
    required this.householdId,
    required this.userId,
  });

  @override
  State<TransactionSourceForm> createState() => _TransactionSourceFormState();
}

class _TransactionSourceFormState extends State<TransactionSourceForm> {
  late final TextEditingController _name;
  late TransactionSourceKind _kind;
  late int _colorIdx;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _kind = widget.existing?.kind ?? TransactionSourceKind.merchant;
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

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final theme = context.myTheme;
    final swatches = _swatches(theme);
    final hex =
        '#${swatches[_colorIdx].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final now = DateTime.now();

    if (widget.existing == null) {
      final src = TransactionSource(
        id: '',
        householdId: widget.householdId,
        name: name,
        kind: _kind,
        color: hex,
        createdBy: widget.userId,
        createdAt: now,
        lastUpdate: now,
      );
      context.read<TransactionSourcesBloc>().add(TransactionSourcesCreate(src));
    } else {
      final updated = widget.existing!.copyWith(
        name: name,
        kind: _kind,
        color: hex,
        lastUpdate: now,
      );
      context
          .read<TransactionSourcesBloc>()
          .add(TransactionSourcesUpdate(updated));
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete source'),
        content: const Text(
            'Past transactions linked to it stay; the source itself is removed.'),
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
    if (ok == true && mounted) {
      context
          .read<TransactionSourcesBloc>()
          .add(TransactionSourcesDelete(widget.existing!.id));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final border =
        Color(int.parse(theme.borderColor.replaceFirst('#', '0xff')));
    final fg = Color(int.parse(theme.onBackgroundColor.replaceFirst('#', '0xff')));
    final muted =
        Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final swatches = _swatches(theme);
    final isEdit = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              placeholder: 'e.g. Netflix',
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              style: AppFonts.body(fontSize: 14, color: fg),
            ),
          ),
          _label('Kind', muted),
          SegmentedControl(
            options: const ['Merchant', 'Employer', 'Service', 'Platform', 'Other'],
            active: TransactionSourceKind.values.indexOf(_kind),
            onChanged: (i) =>
                setState(() => _kind = TransactionSourceKind.values[i]),
            surface: surface,
            border: border,
            fg: fg,
            muted: muted,
            activeColor: accent,
            activeFg: CupertinoColors.white,
          ),
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
                    onPressed: _confirmDelete,
                    child: Text(
                      'Delete',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(int.parse(
                            theme.colorRed.replaceFirst('#', '0xff'))),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: isEdit ? 1 : 2,
                child: CupertinoButton.filled(
                  onPressed: _save,
                  child: Text(isEdit ? 'Save' : 'Create'),
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
