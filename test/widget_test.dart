import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:expense_tracker/views/home_screen.dart';

void main() {
  setUpAll(() async {
    Hive.init('./test_hive_widget');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    await Hive.openBox<Transaction>('transactions');
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.close();
  });

  testWidgets('Home screen shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TransactionViewModel()..loadTransactions(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Should show empty state message
    expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
    expect(find.text('Số dư hiện tại'), findsOneWidget);

    // FAB should be present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
