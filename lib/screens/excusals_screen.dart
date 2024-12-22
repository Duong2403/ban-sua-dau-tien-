import 'package:flutter/material.dart';

class ExcusalsScreen extends StatefulWidget {
  const ExcusalsScreen({super.key});

  @override
  State<ExcusalsScreen> createState() => _ExcusalsScreenState();
}

class _ExcusalsScreenState extends State<ExcusalsScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excusals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewExcusalDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecurringExcusals(),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringExcusals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recurring Excusals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecurringExcusalItem('IC Status', 'DDT, Silver Saturday'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringExcusalItem(String title, String description) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(description),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            // Handle delete
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        Text(
          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
          },
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return const Center(
      child: Text('No Events'),
    );
  }

  void _showNewExcusalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Excusal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExcusalTypeDropdown(),
            const SizedBox(height: 16),
            _buildExcusalReasonDropdown(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildExcusalTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Excusal Type',
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Events')),
        DropdownMenuItem(value: 'mdays', child: Text('M Days')),
        DropdownMenuItem(value: 'tdays', child: Text('T Days')),
      ],
      onChanged: (value) {
        // Handle selection
      },
    );
  }

  Widget _buildExcusalReasonDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Reason',
      ),
      items: const [
        DropdownMenuItem(value: 'sca', child: Text('SCA')),
        DropdownMenuItem(value: 'athletic', child: Text('Competitive Athletic Club')),
        DropdownMenuItem(value: 'mission', child: Text('Mission Support Club')),
        DropdownMenuItem(value: 'airmanship', child: Text('Airmanship')),
        DropdownMenuItem(value: 'ic', child: Text('IC Status')),
        DropdownMenuItem(value: 'bedrest', child: Text('Bedrest')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: (value) {
        // Handle selection
      },
    );
  }
}