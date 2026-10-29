import 'package:flutter/foundation.dart';

import '../models/loan.dart';
import 'display_status.dart';
import 'library_view_model.dart';
import 'operation_result.dart';

class BorrowedBooksViewModel extends ChangeNotifier {
  BorrowedBooksViewModel(this._library) {
    _library.addListener(notifyListeners); // ikut update saat data berubah
  }

  final LibraryViewModel _library;

  @override
  void dispose() {
    _library.removeListener(notifyListeners);
    super.dispose();
  }

  List<Loan> get loansNewestFirst => _library.loans.reversed.toList();
  int get totalFine => _library.totalFine;
  int get activeCount => _library.activeLoans.length;
  int get overdueCount => _library.overdueLoans.length;
  DateTime get today => _library.today;

  String titleOf(Loan loan) => _library.bookById(loan.bookId).title;
  DisplayStatus statusOf(Loan loan) => _library.getOverdueStatus(loan);
  int fineOf(Loan loan) => _library.calculateFine(loan);
  OperationResult returnLoan(Loan loan) => _library.returnBook(loan.id);
}