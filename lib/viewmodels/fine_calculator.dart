class FineCalculator {
  static const int freeDays = 6;
  static const int baseDailyRate = 5000;
  static const int daysPerTier = 7;
  static const int missingAfterMonths = 6;

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateTime addMonths(DateTime date, int months) {
    final total = date.year * 12 + (date.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime.utc(year, month, day);
  }

  static int daysLate(DateTime dueDate, DateTime endDate) {
    final diff = _dateOnly(endDate).difference(_dateOnly(dueDate)).inDays;
    return diff < 0 ? 0 : diff;
  }

  static int overdueFine(DateTime dueDate, DateTime endDate) {
    final late = daysLate(dueDate, endDate);
    var total = 0;
    for (var day = freeDays + 1; day <= late; day++) {
      final tier = (day - (freeDays + 1)) ~/ daysPerTier + 1;
      total += baseDailyRate * tier;
    }
    return total;
  }

  static DateTime missingDate(DateTime dueDate) =>
      addMonths(_dateOnly(dueDate), missingAfterMonths);

  static bool isMissing(DateTime dueDate, DateTime endDate) =>
      !_dateOnly(endDate).isBefore(missingDate(dueDate));

  static int calculateFine({
    required DateTime dueDate,
    required DateTime endDate,
    required int replacementPrice,
  }) {
    if (isMissing(dueDate, endDate)) {
      return overdueFine(dueDate, missingDate(dueDate)) + replacementPrice;
    }
    return overdueFine(dueDate, endDate);
  }
}