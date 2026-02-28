import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:expense_tracker/views/add_transaction_screen.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing with a temp directory
    Hive.init('./test_hive');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    await Hive.openBox<Transaction>('transactions');
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.close();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => TransactionViewModel()..loadTransactions(),
      child: const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
  }

  testWidgets('Form shows validation error when amount is empty',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap submit button without entering anything
    // Find the FilledButton
    final button = find.widgetWithText(FilledButton, 'Thêm giao dịch');
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Should show validation error
    expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
  });

  testWidgets('Amount field only accepts digits (rejects letters)',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Try to enter letters in amount field
    final amountField = find.widgetWithText(TextFormField, 'Số tiền (VNĐ)');
    await tester.enterText(amountField, 'abc');
    await tester.pumpAndSettle();

    // FilteringTextInputFormatter.digitsOnly should block letters
    // The field should be empty since only digits are allowed
    final textField = tester.widget<TextFormField>(amountField);
    final controller =
        textField.controller as TextEditingController;
    expect(controller.text, '');
  });

  testWidgets('Category dropdown shows expense categories by default',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap on the dropdown
    final dropdown = find.widgetWithText(
        DropdownButtonFormField<String>, 'Danh mục');
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Should show expense categories
    expect(find.text('Food'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
  });
}
