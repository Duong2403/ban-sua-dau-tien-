// lib/screens/admin/menu_manager.dart
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/menu.dart';

class MenuManagerScreen extends StatefulWidget {
  const MenuManagerScreen({super.key});

  @override
  State<MenuManagerScreen> createState() => _MenuManagerScreenState();
}

class _MenuManagerScreenState extends State<MenuManagerScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _mealTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thực đơn')),
      body: StreamBuilder<List<Menu>>(
        stream: _dataService.getMenus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final menu = snapshot.data![index];
              return ListTile(
                title: Text(menu.mealType),
                subtitle: Text(
                    '${menu.description}\nNgày: ${menu.date.toString().split(' ')[0]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(menu),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _dataService.deleteMenu(menu.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEditDialog(Menu menu) async {
    _mealTypeController.text = menu.mealType;
    _descriptionController.text = menu.description;
    _selectedDate = menu.date;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thực đơn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mealTypeController,
                decoration: const InputDecoration(labelText: 'Loại bữa ăn'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Text(
                    'Chọn ngày: ${_selectedDate.toString().split(' ')[0]}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedMenu = Menu(
                id: menu.id,
                mealType: _mealTypeController.text,
                description: _descriptionController.text,
                date: _selectedDate,
              );
              await _dataService.updateMenu(menu.id, updatedMenu);
              if (mounted) Navigator.pop(context);
              _clearControllers();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog() async {
    _clearControllers();
    _selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thực đơn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mealTypeController,
                decoration: const InputDecoration(labelText: 'Loại bữa ăn'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Text(
                    'Chọn ngày: ${_selectedDate.toString().split(' ')[0]}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_mealTypeController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                final menu = Menu(
                  id: '',
                  mealType: _mealTypeController.text,
                  description: _descriptionController.text,
                  date: _selectedDate,
                );
                await _dataService.addMenu(menu);
                if (mounted) Navigator.pop(context);
                _clearControllers();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _mealTypeController.clear();
    _descriptionController.clear();
  }
}
