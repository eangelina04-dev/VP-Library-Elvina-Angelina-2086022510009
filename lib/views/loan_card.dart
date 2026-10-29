import 'package:flutter/material.dart';

import '../models/loan.dart';
import '../viewmodels/display_status.dart';
import 'shared.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.bookTitle,
    required this.status,
    required this.fine,
    required this.onReturn,
  });

  final Loan loan;
  final String bookTitle;
  final DisplayStatus status;
  final int fine;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final returned = loan.returnDate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(bookTitle, style: text.titleMedium)),
                StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('ID mahasiswa: ${loan.studentId}'),
            Text('Dipinjam: ${formatDate(loan.borrowDate)}'),
            Text('Jatuh tempo: ${formatDate(loan.dueDate)}'),
            if (returned != null) Text('Dikembalikan: ${formatDate(returned)}'),
            if (fine > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tagihan: ${formatRupiah(fine)}',
                  style: text.titleSmall?.copyWith(color: scheme.error),
                ),
              ),
            if (loan.isActive)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onReturn,
                  child: const Text('Kembalikan'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}