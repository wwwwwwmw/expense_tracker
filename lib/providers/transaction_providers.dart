import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction_repository.dart';
import '../domain/transaction_calculator.dart';
import '../models/transaction.dart';

// ───────────────────────── Repository ─────────────────────────
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// ───────────────────────── Reactive transaction list ──────────
/// Listens to the Hive box via ValueListenable and rebuilds on every
/// put / delete.  No manual "loadTransactions()" needed.
final transactionsProvider = Provider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  // This subscribes to Hive's ValueListenable so the provider re-evaluates
  // whenever the box changes.
  final notifier = repo.listenable();
  // We use a manual listener + invalidateSelf for true reactivity.
  void listener() => ref.invalidateSelf();
  notifier.addListener(listener);
  ref.onDispose(() => notifier.removeListener(listener));
  return repo.getAll();
});

// ───────────────────────── Derived (computed) providers ───────
final totalIncomeProvider = Provider<double>((ref) {
  return TransactionCalculator.totalIncome(ref.watch(transactionsProvider));
});

final totalExpenseProvider = Provider<double>((ref) {
  return TransactionCalculator.totalExpense(ref.watch(transactionsProvider));
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

// ───────────────────────── Month selector ─────────────────────
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final monthlyExpenseByCategoryProvider =
    Provider<Map<String, double>>((ref) {
  final txns = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  final filtered = TransactionCalculator.filterByMonth(
      txns, month.year, month.month);
  return TransactionCalculator.expenseByCategory(filtered);
});

final dailyExpenseProvider = Provider<Map<int, double>>((ref) {
  final txns = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  return TransactionCalculator.dailyExpense(txns, month.year, month.month);
});

// ───────────────────────── Search / filter state ──────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final typeFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  var txns = ref.watch(transactionsProvider);
  txns = TransactionCalculator.search(txns, ref.watch(searchQueryProvider));
  txns = TransactionCalculator.filterByType(txns, ref.watch(typeFilterProvider));
  txns = TransactionCalculator.filterByCategory(
      txns, ref.watch(categoryFilterProvider));
  return txns;
});
