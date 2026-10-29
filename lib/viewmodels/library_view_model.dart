import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/library_repository.dart';
import '../models/loan.dart';
import 'book_group.dart';
import 'display_status.dart';
import 'fine_calculator.dart';
import 'operation_result.dart';

class LibraryViewModel extends ChangeNotifier {
  static const int loanDays = 7;

  final LibraryRepository _repository;
  List<Book> _books = [];
  List<Loan> _loans = [];
  DateTime? _simulatedToday;

  LibraryViewModel({LibraryRepository? repository})
      : _repository = repository ?? LibraryRepository();
  Future<void> init() async {
    await _repository.init();
    _books = _repository.getBooks();
    _loans = _repository.getLoans();
    if (_declareMissingLoans()) _save();
    notifyListeners();
  }

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);

  List<Loan> get activeLoans =>
      List.unmodifiable(_loans.where((l) => l.isActive));

  List<Loan> get overdueLoans => List.unmodifiable(_loans.where((l) {
    if (!l.isActive) return false;
    final s = getOverdueStatus(l);
    return s == DisplayStatus.overdue || s == DisplayStatus.missing;
  }));

  /// Katalog dikelompokkan per judul; urutan mengikuti urutan data.
  List<BookTitleGroup> get bookGroups {
    final byTitle = <String, List<Book>>{};
    for (final book in _books) {
      byTitle.putIfAbsent('${book.title}|${book.author}', () => []).add(book);
    }
    return byTitle.values
        .map((copies) => BookTitleGroup(
      title: copies.first.title,
      author: copies.first.author,
      copies: List.unmodifiable(copies),
    ))
        .toList();
  }

  /// Jumlah salinan yang benar-benar tersedia untuk dipinjam.
  int availableCount(BookTitleGroup group) => group.copies
      .where((b) => statusOfBook(b) == DisplayStatus.available)
      .length;

  int get totalFine => _loans.fold(0, (sum, l) => sum + calculateFine(l));

  DateTime get today => _dateOnly(_simulatedToday ?? DateTime.now());

  void simulateToday(DateTime? date) {
    _simulatedToday = date;
    if (_declareMissingLoans()) _save();
    notifyListeners();
  }

  Book bookById(String id) => _books.firstWhere((b) => b.id == id);

  Loan? activeLoanForBook(String bookId) {
    for (final loan in _loans) {
      if (loan.bookId == bookId && loan.isActive) return loan;
    }
    return null;
  }

  int calculateFine(Loan loan) {
    return FineCalculator.calculateFine(
      dueDate: loan.dueDate,
      endDate: loan.returnDate ?? today,
      replacementPrice: bookById(loan.bookId).replacementPrice,
    );
  }

  DisplayStatus getOverdueStatus(Loan loan) {
    final endDate = loan.returnDate ?? today;
    if (loan.wasDeclaredMissing ||
        FineCalculator.isMissing(loan.dueDate, endDate)) {
      return DisplayStatus.missing;
    }
    if (!loan.isActive) return DisplayStatus.returned;
    if (FineCalculator.daysLate(loan.dueDate, endDate) > 0) {
      return DisplayStatus.overdue;
    }
    return DisplayStatus.borrowed;
  }

  DisplayStatus statusOfBook(Book book) {
    if (book.status == BookStatus.missing) return DisplayStatus.missing;
    final loan = activeLoanForBook(book.id);
    if (loan == null) return DisplayStatus.available;
    return getOverdueStatus(loan);
  }

  OperationResult borrowBook(String bookId, String studentId) {
    final student = studentId.trim();
    if (student.isEmpty) {
      return const OperationResult.error('ID mahasiswa wajib diisi.');
    }

    _declareMissingLoans();

    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex == -1) {
      return const OperationResult.error('Buku tidak ditemukan.');
    }
    final book = _books[bookIndex];

    if (book.status != BookStatus.available ||
        activeLoanForBook(bookId) != null) {
      return const OperationResult.error('Buku sedang tidak tersedia.');
    }

    final now = today;
    final loan = Loan(
      id: _newLoanId(),
      bookId: bookId,
      studentId: student,
      borrowDate: now,
      dueDate: DateTime(now.year, now.month, now.day + loanDays),
    );

    _loans.add(loan);
    _books[bookIndex] = book.copyWith(status: BookStatus.borrowed);

    _save();
    notifyListeners();
    return OperationResult.ok('Buku "${book.title}" berhasil dipinjam.');
  }

  OperationResult returnBook(String loanId) {
    _declareMissingLoans();

    final loanIndex = _loans.indexWhere((l) => l.id == loanId);
    if (loanIndex == -1) {
      return const OperationResult.error('Data peminjaman tidak ditemukan.');
    }
    final loan = _loans[loanIndex];
    if (!loan.isActive) {
      return const OperationResult.error('Buku ini sudah dikembalikan.');
    }

    _loans[loanIndex] = loan.copyWith(returnDate: today);

    final bookIndex = _books.indexWhere((b) => b.id == loan.bookId);
    if (bookIndex != -1) {
      _books[bookIndex] =
          _books[bookIndex].copyWith(status: BookStatus.available);
    }

    _save();
    notifyListeners();

    if (loan.wasDeclaredMissing) {
      return const OperationResult.ok(
          'Buku dikembalikan. Tagihan buku hilang tetap tercatat; '
              'penyelesaiannya mengikuti kebijakan perpustakaan.');
    }
    return const OperationResult.ok('Buku berhasil dikembalikan.');
  }

  bool _declareMissingLoans() {
    var changed = false;
    for (var i = 0; i < _loans.length; i++) {
      final loan = _loans[i];
      if (!loan.isActive || loan.wasDeclaredMissing) continue;
      if (!FineCalculator.isMissing(loan.dueDate, today)) continue;

      _loans[i] = loan.copyWith(
        declaredMissingDate: FineCalculator.missingDate(loan.dueDate),
      );
      final bookIndex = _books.indexWhere((b) => b.id == loan.bookId);
      if (bookIndex != -1) {
        _books[bookIndex] =
            _books[bookIndex].copyWith(status: BookStatus.missing);
      }
      changed = true;
    }
    return changed;
  }

  void _save() {
    _repository.saveLoans(_loans);
    _repository.saveBooks(_books);
  }

  String _newLoanId() =>
      'L-${(_loans.length + 1).toString().padLeft(3, '0')}';

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}