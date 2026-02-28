import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class HiveService {
  static const String _boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<Transaction>(_boxName);
  }

  static Box<Transaction> getTransactionBox() {
    return Hive.box<Transaction>(_boxName);
  }

  // Create
  static Future<void> addTransaction(Transaction transaction) async {
    final box = getTransactionBox();
    await box.put(transaction.id, transaction);
  }

  // Read all
  static List<Transaction> getAllTransactions() {
    final box = getTransactionBox();
    return box.values.toList();
  }

  // Update
  static Future<void> updateTransaction(Transaction transaction) async {
    final box = getTransactionBox();
    await box.put(transaction.id, transaction);
  }

  // Delete
  static Future<void> deleteTransaction(String id) async {
    final box = getTransactionBox();
    await box.delete(id);
  }

  // Close
  static Future<void> close() async {
    await Hive.close();
  }
}
