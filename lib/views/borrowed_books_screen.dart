import 'package:flutter/material.dart';

import '../viewmodels/borrowed_books_view_model.dart';
import '../viewmodels/library_view_model.dart';
import 'loan_card.dart';
import 'shared.dart';

class BorrowedBooksScreen extends StatefulWidget {
  const BorrowedBooksScreen({super.key, required this.libraryViewModel});

  final LibraryViewModel libraryViewModel;

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  late final BorrowedBooksViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = BorrowedBooksViewModel(widget.libraryViewModel);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final loans = _vm.loansNewestFirst;

        return Scaffold(
          appBar: AppBar(title: const Text('Pinjaman')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FineSummaryCard(
                totalFine: _vm.totalFine,
                activeCount: _vm.activeCount,
                overdueCount: _vm.overdueCount,
                today: _vm.today,
              ),
              const SizedBox(height: 16),
              if (loans.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada peminjaman.')),
                )
              else
                for (final loan in loans)
                  LoanCard(
                    loan: loan,
                    bookTitle: _vm.titleOf(loan),
                    status: _vm.statusOf(loan),
                    fine: _vm.fineOf(loan),
                    onReturn: () =>
                        showResultSnackBar(context, _vm.returnLoan(loan)),
                  ),
            ],
          ),
        );
      },
    );
  }
}