import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hour_entry.dart';
import '../providers/hour_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../services/battery_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  int? _hours;
  DateTime? _selectedDate;
  String? _selectedFilePath;

  void _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

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
        title: const Text('Add Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.battery_full),
            tooltip: 'Battery Level',
            onPressed: () => _showBatteryLevel(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) => _category = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a category'
                    : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Hours'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _hours = int.tryParse(value ?? '0'),
                validator: (value) => value == null || int.tryParse(value) == null
                    ? 'Please enter a valid number'
                    : null,
              ),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select a Date'
                      : 'Selected Date: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    setState(() {
                      _selectedFilePath = result.files.single.path;
                    });
                  }
                },
                child: Text(_selectedFilePath == null ? 'Select Document' : 'Change Document'),
              ),
              if (_selectedFilePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Selected: ${_selectedFilePath!.split('/').last}',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date!')),
                      );
                      return;
                    }
                    _formKey.currentState?.save();
                    final newEntry = HourEntry(
                      category: _category!,
                      hours: _hours!,
                      date: _selectedDate!,
                      proofPath: _selectedFilePath,
                    );
                    await Provider.of<HourProvider>(context, listen: false)
                        .addEntry(newEntry);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
