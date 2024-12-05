import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:student_hours/models/hour_entry.dart';
import 'package:student_hours/providers/hour_provider.dart';
import 'package:student_hours/services/database_service.dart';
import 'hour_provider_test.mocks.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
void main() {
  late MockDatabaseService mockDatabaseService;
  late HourProvider hourProvider;

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    hourProvider = HourProvider();
    hourProvider.setDbService(mockDatabaseService);
  });

  test('should load entries from database on initialization', () async {
    List<HourEntry> fakeEntries = [
      HourEntry(id: 1, category: 'Palestra', hours: 5, date: DateTime.now()),
      HourEntry(id: 2, category: 'Curso Flutter', hours: 50, date: DateTime.now().subtract(Duration(days: 1))),
    ];

    when(mockDatabaseService.getAllHours()).thenAnswer((_) async => fakeEntries);

    await hourProvider.loadEntries();

    expect(hourProvider.entries, fakeEntries);
    verify(mockDatabaseService.getAllHours()).called(1);
  });

  test('should add a new entry and update the entries list', () async {
    HourEntry newEntry = HourEntry(id: 3, category: 'Exercise', hours: 2, date: DateTime.now());

    when(mockDatabaseService.insertHour(newEntry)).thenAnswer((_) async => 1);
    when(mockDatabaseService.getAllHours()).thenAnswer((_) async => [newEntry]);

    await hourProvider.addEntry(newEntry);

    expect(hourProvider.entries, [newEntry]);
    verify(mockDatabaseService.insertHour(newEntry)).called(1);
    verify(mockDatabaseService.getAllHours()).called(1);
  });

  test('should update an existing entry and reflect changes', () async {
    // Primeiro registro dos testes -> HourEntry(id: 1, category: 'Palestra', hours: 5, date: DateTime.now());
    HourEntry updatedEntry = HourEntry(
        id: 1,
        category: 'Palestra',
        hours: 6, // Hora atualizada para update
        date: DateTime.now()
    );

    when(mockDatabaseService.updateHour(updatedEntry)).thenAnswer((_) async => 1);
    when(mockDatabaseService.getAllHours()).thenAnswer((_) async => [updatedEntry]);

    await hourProvider.updateEntry(updatedEntry);

    expect(hourProvider.entries, [updatedEntry]);
    verify(mockDatabaseService.updateHour(updatedEntry)).called(1);
    verify(mockDatabaseService.getAllHours()).called(1);
  });

  test('should delete an entry and update the entries list', () async {
    // HourEntry(id: 1, category: 'Palestra', hours: 6, date: DateTime.now());

    when(mockDatabaseService.deleteHour(1)).thenAnswer((_) async => 1);
    when(mockDatabaseService.getAllHours()).thenAnswer((_) async => []);

    await hourProvider.deleteEntry(1);

    expect(hourProvider.entries, []);
    verify(mockDatabaseService.deleteHour(1)).called(1);
    verify(mockDatabaseService.getAllHours()).called(1);
  });
}
