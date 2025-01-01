// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../models/menu.dart';
import '../models/phone_contact.dart';
import './admin/menu_manager.dart';
// Trong home_screen.dart và data_service.dart
import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  String currentUniform = 'OCPs';
  String searchQuery = '';
  String todayDate = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _updateDate();
    await _loadRoutineOrder();
  }

  void _updateDate() {
    setState(() {
      todayDate = DateTime.now().toString().split(' ')[0];
    });
  }

  Future<void> _loadRoutineOrder() async {
    try {
      final doc = await _dataService.getRoutineOrder().first;
      if (doc.exists && mounted) {
        setState(() {
          currentUniform = doc.get('uniform') ?? 'OCPs';
        });
      }
    } catch (e) {
      debugPrint('Error loading routine order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          if (_authService.currentUser?.email == 'anhduongxx2403@gmail.com')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuManagerScreen()),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildRoutineOrder(),
                const SizedBox(height: 16),
                _buildEventCountdowns(
                    isAdmin: _authService.currentUser?.email ==
                        'anhduongxx2403@gmail.com'),
                const SizedBox(height: 16),
                _buildMenu(),
                const SizedBox(height: 16),
                _buildSchedule(),
                const SizedBox(height: 16),
                _buildPhoneDirectory(),
                const SizedBox(height: 16),
                _buildScheduleSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return StreamBuilder<List<Schedule>>(
      stream: _dataService.getSchedules(), // Lấy dữ liệu lịch trình từ Firebase
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Hiển thị trạng thái loading nếu chưa có dữ liệu
        }

        final schedules = snapshot.data!;

        if (schedules.isEmpty) {
          return const Center(
            child: Text('Không có lịch trình nào'),
          ); // Hiển thị thông báo nếu không có lịch trình
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(schedule.date), // Ngày
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(schedule.content), // Nội dung lịch trình
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type Pass',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Pass'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _showPassInputDialog, // Gọi phương thức hiển thị form
                  child: const Text('update'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {},
                  child: const Text('close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineOrder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '일과 복장',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_authService.currentUser?.email ==
                    'anhduongxx2403@gmail.com')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditRoutineDialog,
                  ),
              ],
            ),
            Text('날짜: $todayDate'),
            Text('복장: $currentUniform'),
          ],
        ),
      ),
    );
  }

  void _showPassInputDialog() {
    final _formKey = GlobalKey<FormState>();
    String _passType = '외출';
    String _address = '';
    String _time = '';
    String _description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('패스 등록'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _passType,
                decoration: const InputDecoration(labelText: '패스 유형'),
                items: const [
                  DropdownMenuItem(value: '외출', child: Text('외출')),
                  DropdownMenuItem(value: '병원', child: Text('병원')),
                  DropdownMenuItem(value: '특박', child: Text('특박')),
                  DropdownMenuItem(value: '청원휴가', child: Text('청원휴가')),
                ],
                onChanged: (value) => _passType = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '주소'),
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '시간'),
                onSaved: (value) => _time = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '설명'),
                onSaved: (value) => _description = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Thêm dữ liệu vào Firestore
                FirebaseFirestore.instance.collection('passes').add({
                  'passType': _passType,
                  'address': _address,
                  'time': _time,
                  'description': _description,
                  'submittedBy': FirebaseAuth.instance.currentUser?.email,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('패스 정보가 성공적으로 저장되었습니다!')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showEditRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật lệnh thường ngày'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: currentUniform,
              items: const [
                DropdownMenuItem(value: 'OCPs', child: Text('OCPs')),
                DropdownMenuItem(
                    value: 'Service Dress', child: Text('Service Dress')),
                DropdownMenuItem(value: 'PT Gear', child: Text('PT Gear')),
              ],
              onChanged: (value) {
                setState(() => currentUniform = value!);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.updateRoutineOrder(currentUniform);
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTile(String event, String days, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$days ngày',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return StreamBuilder<List<Menu>>(
      stream: _dataService.getMenus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayMenus = snapshot.data!.where((menu) {
          final today = DateTime.now();
          final menuDate = menu.date;
          return menuDate.year == today.year &&
              menuDate.month == today.month &&
              menuDate.day == today.day;
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '밥돌이_오늘메뉴',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (todayMenus.isEmpty)
                  const Text('Chưa có thực đơn cho hôm nay')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayMenus.length,
                    itemBuilder: (context, index) {
                      final menu = todayMenus[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.mealType,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(menu.description),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '일정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_authService.currentUser?.email ==
                    'anhduongxx2403@gmail.com')
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddScheduleDialog,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Schedule>>(
              stream: _dataService.getSchedules(),
              builder: (context, snapshot) {
                // Debugging logs
                print('ConnectionState: ${snapshot.connectionState}');
                print('HasData: ${snapshot.hasData}');
                print('Data length: ${snapshot.data?.length ?? 0}');

                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error handling
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                }

                // No data
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không có lịch trình nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Sort schedules by date
                final schedules = snapshot.data!
                  ..sort((a, b) => a.date.compareTo(b.date));

                // Print schedule details for debugging
                for (var schedule in schedules) {
                  print('Schedule ID: ${schedule.id}');
                  print('Content: ${schedule.content}');
                  print('Date: ${schedule.date}');
                }

                // ListView for schedules
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          DateFormat('dd/MM/yyyy').format(schedule.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          schedule.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _authService.currentUser?.email ==
                                'anhduongxx2403@gmail.com'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEditScheduleDialog(schedule),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _dataService
                                        .deleteSchedule(schedule.id),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String title, String time, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(time),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildPhoneDirectory() {
    return _authService.currentUser?.email == 'anhduongxx2403@gmail.com'
        ? _buildPhoneList()
        : _buildPhoneSearch();
  }

  Widget _buildPhoneList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '전화번호_명단',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddPhoneDialog,
                ),
              ],
            ),
            StreamBuilder<List<PhoneContact>>(
              stream: _dataService.getPhoneContacts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contacts = snapshot.data!;
                if (contacts.isEmpty) {
                  return const Text('Chưa có số điện thoại nào');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _dataService.deletePhoneContact(contact.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPhoneDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전화번호_추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final contact = PhoneContact(
                  id: '',
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                _dataService.addPhoneContact(contact);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCountdowns({required bool isAdmin}) {
    return StreamBuilder<List<Event>>(
      stream: _dataService.getEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddEventDialog(context),
                  ),
              ],
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: events.map((event) {
                final now = DateTime.now();
                final eventDate = event.date;
                final daysUntil = eventDate
                    .difference(DateTime(now.year, now.month, now.day))
                    .inDays;

                return _buildEventTile(
                  event.name,
                  daysUntil.toString(),
                  Colors.blue,
                  isAdmin: isAdmin,
                  onEdit: () => _showEditEventDialog(context, event),
                  onDelete: () => _dataService.deleteEvent(event.id),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventTile(
    String event,
    String days,
    Color color, {
    bool isAdmin = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Card(
      color: color,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$days days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete, color: Colors.white, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedDate = DateTime.now();

    // Tạo StatefulBuilder để cập nhật UI khi chọn ngày
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 730)), // 2 năm
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Text(
                        'Chọn ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                  ),
                  // Hiển thị số ngày còn lại
                  const SizedBox(width: 8),
                  Text(
                    'Còn: ${selectedDate.difference(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        )).inDays} ngày',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final event = Event(
                    id: '',
                    name: nameController.text,
                    date: selectedDate,
                    description: descriptionController.text,
                  );
                  _dataService.addEvent(event);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    final nameController = TextEditingController(text: event.name);
    final descriptionController =
        TextEditingController(text: event.description);
    DateTime selectedDate = event.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              child:
                  Text('Select Date: ${selectedDate.toString().split(' ')[0]}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedEvent = Event(
                  id: event.id,
                  name: nameController.text,
                  date: selectedDate,
                  description: descriptionController.text,
                );
                _dataService.updateEvent(event.id, updatedEvent);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // schedule

  void _showAddScheduleDialog() {
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: '일정 내용',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: Text(
                    'Chọn ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                // In log để debug
                print('Nội dung: ${contentController.text}');
                print('Ngày: $selectedDate');

                if (contentController.text.isNotEmpty) {
                  final currentUser = _authService.currentUser;
                  if (currentUser != null) {
                    final schedule = Schedule(
                      id: '',
                      content: contentController.text,
                      date: selectedDate,
                      userId: currentUser.uid,
                      isPublic: true,
                      createdAt: DateTime.now(),
                    );

                    // In log trước khi thêm
                    print('Đang thêm lịch trình: ${schedule.content}');

                    _dataService.addSchedule(schedule);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng đăng nhập')),
                    );
                  }
                } else {
                  // Thêm cảnh báo nếu nội dung rỗng
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập nội dung lịch trình')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditScheduleDialog(Schedule schedule) {
    final contentController = TextEditingController(text: schedule.content);
    DateTime selectedDate = schedule.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('일정 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: '일정 내용',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: Text(
                    '날짜: ${DateFormat('yyyy년 MM월 dd일').format(selectedDate)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  final updatedSchedule = Schedule(
                    id: schedule.id,
                    content: contentController.text,
                    date: selectedDate,
                    userId: schedule.userId,
                    isPublic: schedule.isPublic,
                    createdAt: schedule.createdAt,
                  );
                  _dataService.updateSchedule(schedule.id, updatedSchedule);
                  Navigator.pop(context);
                }
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tìm kiếm số điện thoại',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: '찾는 이름을 입력해요...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
            if (searchQuery.isNotEmpty)
              StreamBuilder<List<PhoneContact>>(
                stream: _dataService.getPhoneContacts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredContacts = snapshot.data!.where((contact) {
                    return contact.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredContacts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text('결과 없어요'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return ListTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
