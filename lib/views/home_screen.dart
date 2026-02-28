import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final typeFilter = ref.watch(typeFilterProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);

    // Collect unique categories for filter chips
    final categories =
        allTransactions.map((t) => t.category).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Thống kê',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance card
          Padding(
            padding: const EdgeInsets.all(16),
            child: BalanceCard(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              balance: balance,
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo danh mục, ghi chú…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 8),

          // Filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('Thu nhập'),
                    selected: typeFilter == 'income',
                    onSelected: (sel) => ref
                        .read(typeFilterProvider.notifier)
                        .state = sel ? 'income' : null,
                    avatar: const Icon(Icons.arrow_upward, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('Chi tiêu'),
                    selected: typeFilter == 'expense',
                    onSelected: (sel) => ref
                        .read(typeFilterProvider.notifier)
                        .state = sel ? 'expense' : null,
                    avatar: const Icon(Icons.arrow_downward, size: 16),
                  ),
                ),
                ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: categoryFilter == cat,
                        onSelected: (sel) => ref
                            .read(categoryFilterProvider.notifier)
                            .state = sel ? cat : null,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${transactions.length} giao dịch',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Chưa có giao dịch nào',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                        Text('Nhấn + để thêm giao dịch mới',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return TransactionTile(
                        transaction: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddTransactionScreen(existingTransaction: t),
                          ),
                        ),
                        onDelete: () => _deleteWithUndo(context, ref, t),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteWithUndo(BuildContext context, WidgetRef ref, Transaction t) {
    final repo = ref.read(transactionRepositoryProvider);
    repo.delete(t.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "${t.category}" – ${t.note}'),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          onPressed: () => repo.add(t),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
