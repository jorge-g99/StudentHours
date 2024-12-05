import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../providers/hour_provider.dart';
import '../screens/add_entry_screen.dart';
import 'package:intl/intl.dart';
import '../services/battery_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showBatteryLevel(BuildContext context) async {
    final batteryLevel = await BatteryService.getBatteryLevel();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Battery Level'),
        content: Text(batteryLevel),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complementary Hours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.battery_full),
            tooltip: 'Battery Level',
            onPressed: () => _showBatteryLevel(context),
          ),
        ],
      ),
      body: Consumer<HourProvider>(
        builder: (context, provider, _) {
          final entries = provider.entries;
          if (entries.isEmpty) {
            return const Center(child: Text('No entries yet.'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.category, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horas: ${entry.hours}'),
                    Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(entry.date)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Garante que os botões não ocupem muito espaço
                  children: [
                    if (entry.proofPath != null)
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.blue),
                        onPressed: () {
                          // Abrir o documento com o pacote open_file
                          OpenFile.open(entry.proofPath!);
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Delete Entry'),
                            content: Text('Are you sure you want to delete this entry?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed ?? false) {
                          await Provider.of<HourProvider>(context, listen: false)
                              .deleteEntry(entry.id!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddEntryScreen(),
          ));
        },
      ),
    );
  }
}
