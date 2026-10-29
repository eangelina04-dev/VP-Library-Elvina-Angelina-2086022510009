import 'package:flutter/material.dart';

import '../models/book.dart';
import '../viewmodels/book_group.dart';
import '../viewmodels/display_status.dart';
import 'shared.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.status,
    required this.onBorrow,
  });

  final Book book;
  final DisplayStatus status;
  final VoidCallback onBorrow;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(book.author),
                  Text('ID: ${book.id}', style: text.bodySmall),
                  const SizedBox(height: 4),
                  Text('Harga ganti ${formatRupiah(book.replacementPrice)}',
                      style: text.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: status),
                const SizedBox(height: 8),
                FilledButton(onPressed: onBorrow, child: const Text('Pinjam')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookGroupSection extends StatelessWidget {
  const BookGroupSection({
    super.key,
    required this.group,
    required this.availableCount,
    required this.statusOf,
    required this.onBorrow,
  });

  final BookTitleGroup group;
  final int availableCount;
  final DisplayStatus Function(Book book) statusOf;
  final void Function(Book book) onBorrow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final soldOut = availableCount == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.title, style: text.titleMedium),
                    Text(group.author, style: text.bodySmall),
                  ],
                ),
              ),
              Text(
                soldOut
                    ? 'Habis dipinjam'
                    : 'Stok Tersedia $availableCount dari ${group.copies.length}',
                style: text.labelLarge?.copyWith(
                  color: soldOut ? scheme.error : scheme.primary,
                ),
              ),
            ],
          ),
        ),
        for (final copy in group.copies)
          BookCard(
            book: copy,
            status: statusOf(copy),
            onBorrow: () => onBorrow(copy),
          ),
      ],
    );
  }
}