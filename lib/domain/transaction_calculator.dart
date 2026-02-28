import '../models/transaction.dart';

/// Pure functions – no side effects, easy to unit-test.
class TransactionCalculator {
  const TransactionCalculator._();

  static double totalIncome(List<Transaction> txns) =>
      txns.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);

  static double totalExpense(List<Transaction> txns) =>
      txns.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);

  static double balance(List<Transaction> txns) =>
      totalIncome(txns) - totalExpense(txns);

  /// Filter transactions by a specific year + month.
  static List<Transaction> filterByMonth(
    List<Transaction> txns,
    int year,
    int month,
  ) =>
      txns
          .where((t) => t.date.year == year && t.date.month == month)
          .toList();

  /// Group expense amounts by category.
  static Map<String, double> expenseByCategory(List<Transaction> txns) {
    final map = <String, double>{};
    for (final t in txns) {
      if (t.type == 'expense') {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// Daily expense totals for bar-chart, keyed by day-of-month.
  static Map<int, double> dailyExpense(
    List<Transaction> txns,
    int year,
    int month,
  ) {
    final map = <int, double>{};
    for (final t in txns) {
      if (t.type == 'expense' &&
          t.date.year == year &&
          t.date.month == month) {
        map[t.date.day] = (map[t.date.day] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// Search + filter helpers.
  static List<Transaction> search(
    List<Transaction> txns,
    String query,
  ) {
    if (query.isEmpty) return txns;
    final q = query.toLowerCase();
    return txns
        .where((t) =>
            t.category.toLowerCase().contains(q) ||
            t.note.toLowerCase().contains(q))
        .toList();
  }

  static List<Transaction> filterByType(
    List<Transaction> txns,
    String? type,
  ) {
    if (type == null) return txns;
    return txns.where((t) => t.type == type).toList();
  }

  static List<Transaction> filterByCategory(
    List<Transaction> txns,
    String? category,
  ) {
    if (category == null) return txns;
    return txns.where((t) => t.category == category).toList();
  }
}
