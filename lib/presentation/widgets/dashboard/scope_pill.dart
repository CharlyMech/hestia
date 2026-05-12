import 'package:flutter/widgets.dart';

enum ScopeKind { shared, personal }

class ScopePill extends StatelessWidget {
  final ScopeKind kind;
  final String? label;

  const ScopePill({super.key, required this.kind, this.label});

  @override
  Widget build(BuildContext context) {
    final shared = kind == ScopeKind.shared;
    final fg = shared ? const Color(0xFF9BC8F0) : const Color(0xFFB8BEC9);
    final bg = shared ? const Color(0x1A0077B6) : const Color(0xFF1A2230);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label ?? (shared ? 'Shared' : 'Personal'),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
