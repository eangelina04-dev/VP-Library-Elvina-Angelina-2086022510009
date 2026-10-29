import 'package:flutter/material.dart';

import '../models/book.dart';
import '../viewmodels/library_view_model.dart';
import 'book_card.dart';
import 'borrowed_books_screen.dart';
import 'shared.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  Future<void> _borrow(BuildContext context, Book book) async {
    final studentId = await showDialog<String>(
      context: context,
      builder: (_) => _StudentIdDialog(bookTitle: book.title),
    );
    if (studentId == null || !context.mounted) return;
    showResultSnackBar(context, viewModel.borrowBook(book.id, studentId));
  }

  Future<void> _pickTestDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) viewModel.simulateToday(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perpustakaan'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.event),
                tooltip: 'Uji tanggal',
                onSelected: (value) {
                  if (value == 'pick') {
                    _pickTestDate(context);
                  } else {
                    viewModel.simulateToday(null);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'pick', child: Text('Ubah tanggal (uji)')),
                  PopupMenuItem(value: 'reset', child: Text('Reset ke hari ini')),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long),
                tooltip: 'Pinjaman',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BorrowedBooksScreen(libraryViewModel: viewModel),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FineSummaryCard(
                totalFine: viewModel.totalFine,
                activeCount: viewModel.activeLoans.length,
                overdueCount: viewModel.overdueLoans.length,
                today: viewModel.today,
              ),
              const SizedBox(height: 16),
              Text('Katalog buku', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final group in viewModel.bookGroups)
                BookGroupSection(
                  group: group,
                  availableCount: viewModel.availableCount(group),
                  statusOf: viewModel.statusOfBook,
                  onBorrow: (book) => _borrow(context, book),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentIdDialog extends StatefulWidget {
  const _StudentIdDialog({required this.bookTitle});

  final String bookTitle;

  @override
  State<_StudentIdDialog> createState() => _StudentIdDialogState();
}

class _StudentIdDialogState extends State<_StudentIdDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pinjam buku'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'ID mahasiswa',
          helperText: widget.bookTitle,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Pinjam'),
        ),
      ],
    );
  }
}