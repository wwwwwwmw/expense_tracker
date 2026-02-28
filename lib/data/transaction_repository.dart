import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

/// Wraps [HiveService] into a testable, injectable repository.
class TransactionRepository {
  static const String _boxName = 'transactions';

  Box<Transaction> get box => Hive.box<Transaction>(_boxName);

  /// Listenable that fires on every box change (used by Riverpod).
  ValueListenable<Box<Transaction>> listenable() => box.listenable();

  /// All transactions sorted newest-first.
  List<Transaction> getAll() {
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Transaction? getById(String id) => box.get(id);

  Future<void> add(Transaction t) => box.put(t.id, t);

  Future<void> update(Transaction t) => box.put(t.id, t);

  Future<void> delete(String id) => box.delete(id);

  /// Hive init – call once at app start.
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    await Hive.openBox<Transaction>(_boxName);
  }
}
