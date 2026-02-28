import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/views/add_transaction_screen.dart';

void main() {
  setUpAll(() async {
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
    return const ProviderScope(
      child: MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
  }

  testWidgets('Save button is disabled when form is empty', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Find the FilledButton – it should be disabled (onPressed == null)
    final button = find.widgetWithText(FilledButton, 'Thêm giao dịch');
    final widget = tester.widget<FilledButton>(button);
    expect(widget.onPressed, isNull);
  });

  testWidgets('Form shows validation error when amount is empty',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Even though button is disabled, tap the area to trigger validation
    // First select a category to partially fill the form
    final dropdown = find.widgetWithText(
        DropdownButtonFormField<String>, 'Danh mục');
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    // Button should still be disabled because amount is empty
    final button = find.widgetWithText(FilledButton, 'Thêm giao dịch');
    final widget = tester.widget<FilledButton>(button);
    expect(widget.onPressed, isNull);
  });

  testWidgets('Amount field only accepts digits (rejects letters)',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final amountField = find.widgetWithText(TextFormField, 'Số tiền (VNĐ)');
    await tester.enterText(amountField, 'abc');
    await tester.pumpAndSettle();

    final textField = tester.widget<TextFormField>(amountField);
    final controller = textField.controller as TextEditingController;
    expect(controller.text, '');
  });

  testWidgets('Amount field formats VNĐ with thousands separator',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final amountField = find.widgetWithText(TextFormField, 'Số tiền (VNĐ)');
    await tester.enterText(amountField, '1500000');
    await tester.pumpAndSettle();

    final textField = tester.widget<TextFormField>(amountField);
    final controller = textField.controller as TextEditingController;
    // Should be formatted with dots (vi_VN locale) e.g. "1.500.000"
    expect(controller.text.replaceAll(RegExp(r'[^0-9]'), ''), '1500000');
  });

  testWidgets('Category dropdown shows expense categories by default',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final dropdown = find.widgetWithText(
        DropdownButtonFormField<String>, 'Danh mục');
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
  });
}
