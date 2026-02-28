import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';
import '../services/transaction_service.dart';

class TransactionViewModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  double get totalIncome => TransactionService.totalIncome(_transactions);
  double get totalExpense => TransactionService.totalExpense(_transactions);
  double get balance => totalIncome - totalExpense;

  List<Transaction> get currentMonthExpenses =>
      TransactionService.filterByCurrentMonth(
        _transactions.where((t) => t.type == 'expense').toList(),
      );

  Map<String, double> get expenseByCategory =>
      TransactionService.expenseByCategory(currentMonthExpenses);

  void loadTransactions() {
    _transactions = HiveService.getAllTransactions();
    // Sort by date descending (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await HiveService.addTransaction(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await HiveService.updateTransaction(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    loadTransactions();
  }
}
