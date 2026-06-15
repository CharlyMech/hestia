import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/data/services/image_upload_service.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/presentation/blocs/transaction_sources/transaction_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/image_picker_field.dart';
import 'package:uuid/uuid.dart';

/// Bottom-sheet form for creating / editing / deleting a [TransactionSource].
class TransactionSourceSheetForm extends StatefulWidget {
  final TransactionSource? existing;
  final String householdId;
  final String userId;

  const TransactionSourceSheetForm({
    super.key,
    this.existing,
    required this.householdId,
    required this.userId,
  });

  @override
  State<TransactionSourceSheetForm> createState() => _TransactionSourceSheetFormState();
}

class _TransactionSourceSheetFormState extends State<TransactionSourceSheetForm> {
  late final TextEditingController _name;
  late TransactionSourceKind _kind;
  late int _colorIdx;
  late String? _imageUrl;
  late final String _formId;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _kind = widget.existing?.kind ?? TransactionSourceKind.merchant;
    _colorIdx = 0;
    _imageUrl = widget.existing?.imageUrl;
    _formId = widget.existing?.id ?? const Uuid().v4();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<Color> _swatches(MyTheme theme) {
    final tints = theme.categoryTints
        .map((h) => hexToColor(h))
        .toList();
    return [
      hexToColor(theme.primaryColor),
      hexToColor(theme.colorGreen),
      ...tints,
      hexToColor(theme.colorRed),
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
        imageUrl: _imageUrl,
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
        imageUrl: _imageUrl,
        clearImageUrl: _imageUrl == null,
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
        hexToColor(theme.surfaceColor);
    final border =
        hexToColor(theme.borderColor);
    final fg =
        hexToColor(theme.onBackgroundColor);
    final muted =
        hexToColor(theme.onInactiveColor);
    final accent =
        hexToColor(theme.primaryColor);
    final swatches = _swatches(theme);
    final isEdit = widget.existing != null;

    final fallbackText = _name.text.trim().isEmpty
        ? '?'
        : _name.text.trim().substring(0, 1).toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Center(
            child: ImagePickerField(
              bucket: ImageBuckets.sources,
              path: '${widget.householdId}/$_formId.jpg',
              value: _imageUrl,
              onChanged: (v) => setState(() => _imageUrl = v),
              size: 88,
              circle: false,
              fallbackColor: swatches[_colorIdx],
              fallbackText: fallbackText,
            ),
          ),
          _label('Name', muted),
          FTextField(
            controller: _name,
            hint: 'e.g. Netflix',
            textCapitalization: TextCapitalization.sentences,
          ),
          _label('Kind', muted),
          SegmentedControl(
            options: const [
              'Merchant',
              'Employer',
              'Service',
              'Platform',
              'Other'
            ],
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
                  child: AnimatedButton(
                    onTap: _confirmDelete,
                    child: Text(
                      'Delete',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hexToColor(
                            theme.colorRed),
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
