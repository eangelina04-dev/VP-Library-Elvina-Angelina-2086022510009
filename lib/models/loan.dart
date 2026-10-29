class Loan {
  final String id;
  final String bookId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final DateTime? declaredMissingDate;

  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.declaredMissingDate,
  });

  bool get isActive => returnDate == null;

  bool get wasDeclaredMissing => declaredMissingDate != null;

  Loan copyWith({DateTime? returnDate, DateTime? declaredMissingDate}) {
    return Loan(
      id: id,
      bookId: bookId,
      studentId: studentId,
      borrowDate: borrowDate,
      dueDate: dueDate,
      returnDate: returnDate ?? this.returnDate,
      declaredMissingDate: declaredMissingDate ?? this.declaredMissingDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'studentId': studentId,
    'borrowDate': borrowDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'returnDate': returnDate?.toIso8601String(),
    'declaredMissingDate': declaredMissingDate?.toIso8601String(),
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as String,
    bookId: json['bookId'] as String,
    studentId: json['studentId'] as String,
    borrowDate: DateTime.parse(json['borrowDate'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    returnDate: json['returnDate'] == null
        ? null
        : DateTime.parse(json['returnDate'] as String),
    declaredMissingDate: json['declaredMissingDate'] == null
        ? null
        : DateTime.parse(json['declaredMissingDate'] as String),
  );
}