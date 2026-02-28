import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/services/transaction_service.dart';

void main() {
  group('TransactionService', () {
    final transactions = [
      Transaction(
        id: '1',
        amount: 5000000,
        type: 'income',
        category: 'Salary',
        date: DateTime.now(),
        note: 'Lương tháng',
      ),
      Transaction(
        id: '2',
        amount: 200000,
        type: 'expense',
        category: 'Food',
        date: DateTime.now(),
        note: 'Ăn trưa',
      ),
      Transaction(
        id: '3',
        amount: 100000,
        type: 'expense',
        category: 'Transport',
        date: DateTime.now(),
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
      expect(TransactionService.totalIncome(transactions), 5000000);
    });

    test('totalExpense returns correct sum', () {
      expect(TransactionService.totalExpense(transactions), 600000);
    });

    test('balance = income - expense', () {
      final income = TransactionService.totalIncome(transactions);
      final expense = TransactionService.totalExpense(transactions);
      expect(income - expense, 4400000);
    });

    test('filterByCurrentMonth returns only current month transactions', () {
      final filtered = TransactionService.filterByCurrentMonth(transactions);
      // Transaction id '4' is from Jan 2025, should be excluded
      expect(filtered.length, 3);
      expect(filtered.any((t) => t.id == '4'), false);
    });

    test('expenseByCategory groups correctly', () {
      final currentMonthExpenses = TransactionService.filterByCurrentMonth(
        transactions.where((t) => t.type == 'expense').toList(),
      );
      final map = TransactionService.expenseByCategory(currentMonthExpenses);
      expect(map['Food'], 200000);
      expect(map['Transport'], 100000);
    });
  });
}
