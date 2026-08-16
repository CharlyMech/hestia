import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/presentation/blocs/cards/cards_bloc.dart';
import 'package:hestia/presentation/widgets/cards/payment_card_widget.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';
import 'package:uuid/uuid.dart';

class AddEditCardScreen extends StatefulWidget {
  final BankAccount account;
  final PaymentCard? existing;

  const AddEditCardScreen({
    super.key,
    required this.account,
    this.existing,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  static const _uuid = Uuid();

  late final TextEditingController _last4;
  late final TextEditingController _cardholderName;

  CardNetwork _network = CardNetwork.visa;
  int _expiryMonth = DateTime.now().month;
  int _expiryYear = DateTime.now().year + 3;
  bool _isVirtual = false;
  bool _saving = false;

  PaymentCard get _preview => PaymentCard(
        id: widget.existing?.id ?? '',
        accountId: widget.account.id,
        network: _network,
        last4: _last4.text.isEmpty ? '0000' : _last4.text.padLeft(4, '0'),
        expiryMonth: _expiryMonth,
        expiryYear: _expiryYear,
        cardholderName: _cardholderName.text.isEmpty
            ? 'CARDHOLDER NAME'
            : _cardholderName.text,
        isVirtual: _isVirtual,
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
        institutionName: widget.account.institution,
      );

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _last4 = TextEditingController(text: c?.last4 ?? '');
    _cardholderName = TextEditingController(text: c?.cardholderName ?? '');
    if (c != null) {
      _network = c.network;
      _expiryMonth = c.expiryMonth;
      _expiryYear = c.expiryYear;
      _isVirtual = c.isVirtual;
    }
  }

  @override
  void dispose() {
    _last4.dispose();
    _cardholderName.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      context.showToast(AppToastConfig(title: msg, type: ToastType.error));

  Future<void> _save() async {
    final last4 = _last4.text.trim();
    if (last4.length != 4 || int.tryParse(last4) == null) {
      _toast('Last 4 digits must be exactly 4 numbers');
      return;
    }
    if (_cardholderName.text.trim().isEmpty) {
      _toast('Cardholder name is required');
      return;
    }

    setState(() => _saving = true);

    final repo = AppDependencies.instance.cardRepository;
    final card = PaymentCard(
      id: widget.existing?.id ?? _uuid.v4(),
      accountId: widget.account.id,
      network: _network,
      last4: last4,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
      cardholderName: _cardholderName.text.trim(),
      isVirtual: _isVirtual,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      lastUpdate: DateTime.now(),
    );

    final failure = widget.existing != null
        ? await repo.updateCard(card)
        : (await repo.createCard(card)).$2;

    if (!mounted) return;
    setState(() => _saving = false);

    if (failure != null) {
      _toast(failure.message);
    } else {
      context.read<CardsBloc>().add(const CardsRefresh());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final surface = hexToColor(theme.surfaceColor);
    final primary = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);
    final isEdit = widget.existing != null;

    return CupertinoPushedRouteShell(
      backgroundColor: hexToColor(theme.backgroundColor),
      navBackground: hexToColor(theme.surfaceColor),
      borderColor: hexToColor(theme.borderColor),
      foregroundColor: fg,
      titleText: isEdit ? 'Edit Card' : 'Add Card',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Live card preview
          AnimatedBuilder(
            animation: Listenable.merge([_last4, _cardholderName]),
            builder: (_, __) => PaymentCardWidget(card: _preview),
          ),
          const SizedBox(height: 24),

          // Network picker
          Text('Network', style: AppFonts.label(fontSize: 12, color: muted)),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: CardNetwork.values.map((n) {
                final selected = n == _network;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _network = n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? primary : surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: selected ? primary : border),
                      ),
                      child: Text(
                        n.value.toUpperCase(),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? CupertinoColors.white : fg,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Last 4 digits
          CupertinoTextField(
            controller: _last4,
            placeholder: 'Last 4 digits',
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
            ),
            style: AppFonts.body(color: fg),
            placeholderStyle: AppFonts.body(color: muted),
          ),
          const SizedBox(height: 12),

          // Cardholder name
          CupertinoTextField(
            controller: _cardholderName,
            placeholder: 'Cardholder name',
            textCapitalization: TextCapitalization.characters,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
            ),
            style: AppFonts.body(color: fg),
            placeholderStyle: AppFonts.body(color: muted),
          ),
          const SizedBox(height: 16),

          // Expiry row
          Row(
            children: [
              Expanded(
                child: _ExpiryPicker(
                  label: 'Month',
                  value: _expiryMonth.toString().padLeft(2, '0'),
                  surface: surface,
                  fg: fg,
                  muted: muted,
                  onTap: () => _pickMonth(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExpiryPicker(
                  label: 'Year',
                  value: _expiryYear.toString(),
                  surface: surface,
                  fg: fg,
                  muted: muted,
                  onTap: () => _pickYear(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Virtual toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Virtual card', style: AppFonts.body(color: fg)),
              CupertinoSwitch(
                value: _isVirtual,
                onChanged: (v) => setState(() => _isVirtual = v),
                activeTrackColor: primary,
              ),
            ],
          ),
          const SizedBox(height: 32),

          PrimaryButton(
            label: isEdit ? 'Save Changes' : 'Add Card',
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _pickMonth(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 220,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoPicker(
          scrollController:
              FixedExtentScrollController(initialItem: _expiryMonth - 1),
          itemExtent: 36,
          onSelectedItemChanged: (i) => setState(() => _expiryMonth = i + 1),
          children: List.generate(
            12,
            (i) => Center(
              child: Text((i + 1).toString().padLeft(2, '0'),
                  style: AppFonts.numeric()),
            ),
          ),
        ),
      ),
    );
  }

  void _pickYear(BuildContext context) {
    final now = DateTime.now().year;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 220,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoPicker(
          scrollController:
              FixedExtentScrollController(initialItem: _expiryYear - now),
          itemExtent: 36,
          onSelectedItemChanged: (i) => setState(() => _expiryYear = now + i),
          children: List.generate(
            12,
            (i) => Center(
              child: Text((now + i).toString(), style: AppFonts.numeric()),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpiryPicker extends StatelessWidget {
  final String label;
  final String value;
  final Color surface;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  const _ExpiryPicker({
    required this.label,
    required this.value,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.label(fontSize: 12, color: muted)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value, style: AppFonts.numeric(color: fg)),
          ),
        ),
      ],
    );
  }
}
