import '../models/transaction.dart';

class TransactionService {
  static double totalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double totalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static List<Transaction> filterByCurrentMonth(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
  }

  static Map<String, double> expenseByCategory(List<Transaction> expenses) {
    final map = <String, double>{};
    for (final t in expenses) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }
}
