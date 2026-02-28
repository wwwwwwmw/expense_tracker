import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/domain/transaction_calculator.dart';

void main() {
  group('TransactionCalculator', () {
    final now = DateTime.now();
    final transactions = [
      Transaction(
        id: '1',
        amount: 5000000,
        type: 'income',
        category: 'Salary',
        date: now,
        note: 'Lương tháng',
      ),
      Transaction(
        id: '2',
        amount: 200000,
        type: 'expense',
        category: 'Food',
        date: now,
        note: 'Ăn trưa',
      ),
      Transaction(
        id: '3',
        amount: 100000,
        type: 'expense',
        category: 'Transport',
        date: now,
        note: 'Grab',
      ),
      Transaction(
        id: '4',
        amount: 300000,
        type: 'expense',
        category: 'Food',
        date: DateTime(2025, 1, 15), // Old month
        note: 'Ăn tối tháng trước',
      ),
    ];

    test('totalIncome returns correct sum', () {
      expect(TransactionCalculator.totalIncome(transactions), 5000000);
    });

    test('totalExpense returns correct sum of ALL expenses', () {
      // 200k + 100k + 300k
      expect(TransactionCalculator.totalExpense(transactions), 600000);
    });

    test('balance = income - expense', () {
      expect(TransactionCalculator.balance(transactions), 4400000);
    });

    test('filterByMonth returns only matching month', () {
      final filtered = TransactionCalculator.filterByMonth(
        transactions,
        now.year,
        now.month,
      );
      // id '4' is Jan 2025 → excluded
      expect(filtered.length, 3);
      expect(filtered.any((t) => t.id == '4'), false);
    });

    test('expenseByCategory groups correctly (current month only)', () {
      final currentMonth = TransactionCalculator.filterByMonth(
        transactions,
        now.year,
        now.month,
      );
      final map = TransactionCalculator.expenseByCategory(currentMonth);
      expect(map['Food'], 200000);
      expect(map['Transport'], 100000);
      // Salary is income → not in map
      expect(map.containsKey('Salary'), false);
    });

    test('dailyExpense returns per-day totals', () {
      final map = TransactionCalculator.dailyExpense(
          transactions, now.year, now.month);
      expect(map[now.day], 300000); // 200k + 100k on same day
    });

    test('search filters by category and note', () {
      expect(
        TransactionCalculator.search(transactions, 'grab').length,
        1,
      );
      expect(
        TransactionCalculator.search(transactions, 'food').length,
        2,
      );
      expect(
        TransactionCalculator.search(transactions, '').length,
        transactions.length,
      );
    });

    test('filterByType returns only matching type', () {
      final expenses =
          TransactionCalculator.filterByType(transactions, 'expense');
      expect(expenses.length, 3);
      final incomes =
          TransactionCalculator.filterByType(transactions, 'income');
      expect(incomes.length, 1);
      final all = TransactionCalculator.filterByType(transactions, null);
      expect(all.length, transactions.length);
    });

    test('filterByCategory returns only matching category', () {
      final food =
          TransactionCalculator.filterByCategory(transactions, 'Food');
      expect(food.length, 2);
      final all =
          TransactionCalculator.filterByCategory(transactions, null);
      expect(all.length, transactions.length);
    });
  });
}
