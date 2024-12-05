import 'package:flutter/material.dart';
import '../models/hour_entry.dart';
import '../services/database_service.dart';

class HourProvider with ChangeNotifier {
  final List<HourEntry> _entries = [];
  DatabaseService _dbService = DatabaseService();

  // Método para permitir injeção em testes
  void setDbService(DatabaseService dbService) {
    _dbService = dbService;
  }

  HourProvider() {
    // Carrega as entradas salvas ao inicializar
    loadEntries();
  }

  List<HourEntry> get entries => _entries;

  Future<void> loadEntries() async {
    _entries.clear();
    _entries.addAll(await _dbService.getAllHours());
    notifyListeners();
  }

  Future<void> addEntry(HourEntry entry) async {
    await _dbService.insertHour(entry);
    await loadEntries();
  }

  Future<void> updateEntry(HourEntry entry) async {
    await _dbService.updateHour(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await _dbService.deleteHour(id);
    await loadEntries();
  }
}
