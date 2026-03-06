import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../widgets/todo_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoService _todoService = TodoService();

  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all';
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await _todoService.fetchTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Todo> get _filteredTodos {
    var filtered = _todos;

    if (_selectedUserId != null) {
      filtered = filtered.where((t) => t.userId == _selectedUserId).toList();
    }

    switch (_filterStatus) {
      case 'completed':
        return filtered.where((t) => t.completed).toList();
      case 'pending':
        return filtered.where((t) => !t.completed).toList();
      default:
        return filtered;
    }
  }

  int get _completedCount => _todos.where((t) => t.completed).length;
  int get _pendingCount => _todos.where((t) => !t.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'TH3 - Trương Quốc Thái - 2151163723',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          if (!_isLoading && _errorMessage == null) _buildFilterBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Todo List App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quản lý công việc hiệu quả',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          if (!_isLoading && _errorMessage == null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard(
                  'Tổng cộng',
                  _todos.length.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Hoàn thành',
                  _completedCount.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Đang chờ',
                  _pendingCount.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hoàn thành', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đang chờ', 'pending'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildUserDropdown(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: Colors.deepPurple.shade100,
      checkmarkColor: Colors.deepPurple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserDropdown() {
    final userIds = _todos.map((t) => t.userId).toSet().toList()..sort();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedUserId,
          hint: const Text('User', style: TextStyle(fontSize: 14)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tất cả', style: TextStyle(fontSize: 14)),
            ),
            ...userIds.map(
              (id) => DropdownMenuItem<int?>(
                value: id,
                child: Text('User $id', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedUserId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Đang tải danh sách công việc...');
    }

    if (_errorMessage != null) {
      return ErrorDisplayWidget(
        errorMessage: _errorMessage!,
        onRetry: _loadTodos,
      );
    }

    final filteredTodos = _filteredTodos;

    if (filteredTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có công việc nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      color: Colors.deepPurple,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          return TodoCard(todo: filteredTodos[index]);
        },
      ),
    );
  }
}
