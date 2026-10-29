import 'package:flutter/material.dart';

import '../viewmodels/display_status.dart';
import '../viewmodels/operation_result.dart';


String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp${amount < 0 ? '-' : ''}$buffer';
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';

void showResultSnackBar(BuildContext context, OperationResult result) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          result.message,
          style: result.success ? null : TextStyle(color: scheme.onError),
        ),
        backgroundColor: result.success ? null : scheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
}


class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final DisplayStatus status;

  String get _label => switch (status) {
    DisplayStatus.available => 'Tersedia',
    DisplayStatus.borrowed => 'Dipinjam',
    DisplayStatus.overdue => 'Terlambat',
    DisplayStatus.missing => 'Hilang',
    DisplayStatus.returned => 'Dikembalikan',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (status) {
      DisplayStatus.available => (scheme.primaryContainer, scheme.onPrimaryContainer),
      DisplayStatus.borrowed => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      DisplayStatus.overdue => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      DisplayStatus.missing => (scheme.errorContainer, scheme.onErrorContainer),
      DisplayStatus.returned => (scheme.surfaceContainerHighest, scheme.onSurface),
    };

    return Chip(
      label: Text(_label, style: TextStyle(color: fg)),
      backgroundColor: bg,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class FineSummaryCard extends StatelessWidget {
  const FineSummaryCard({
    super.key,
    required this.totalFine,
    required this.activeCount,
    required this.overdueCount,
    required this.today,
  });

  final int totalFine;
  final int activeCount;
  final int overdueCount;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan denda', style: text.titleMedium),
            const SizedBox(height: 4),
            Text('Tanggal sistem: ${formatDate(today)}', style: text.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _Stat(label: 'Total tagihan', value: formatRupiah(totalFine)),
                ),
                Expanded(child: _Stat(label: 'Aktif', value: '$activeCount')),
                Expanded(child: _Stat(label: 'Terlambat', value: '$overdueCount')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: text.titleLarge),
        ),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}