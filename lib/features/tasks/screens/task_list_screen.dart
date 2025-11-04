import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Task list screen dengan ListView.builder
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Dummy data untuk P5
  late List<TaskModel> tasks;

  // Filter state - defaultnya all untuk menampilkan semua tasks
  TaskStatus? selectedFilter;

  @override
  void initState() {
    super.initState();
    tasks = TaskModel.getDummyTasks();
  }

  // Get filtered tasks based on selected filter
  List<TaskModel> get filteredTasks {
    if (selectedFilter == null) {
      return tasks;
    }
    return tasks.where((task) => task.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myTasks),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: tasks.isEmpty ? _buildEmptyState() : _buildTaskListWithFilter(),
      // P6: FloatingActionButton untuk quick access add task
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noTasks,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListWithFilter() {
    final displayedTasks = filteredTasks;

    if (displayedTasks.isEmpty) {
      return _buildEmptyFilterState();
    }

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: displayedTasks.length,
            itemBuilder: (context, index) {
              final task = displayedTasks[index];
              final originalIndex = tasks.indexOf(task);
              return _buildDismissibleTaskCard(task, originalIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: AppStrings.filterAll,
              isSelected: selectedFilter == null,
              onTap: () {
                setState(() {
                  selectedFilter = null;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: AppStrings.statusPending,
              isSelected: selectedFilter == TaskStatus.pending,
              color: AppColors.statusPending,
              onTap: () {
                setState(() {
                  selectedFilter = TaskStatus.pending;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: AppStrings.statusOverdue,
              isSelected: selectedFilter == TaskStatus.overdue,
              color: AppColors.statusOverdue,
              onTap: () {
                setState(() {
                  selectedFilter = TaskStatus.overdue;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: AppStrings.statusCompleted,
              isSelected: selectedFilter == TaskStatus.completed,
              color: AppColors.statusCompleted,
              onTap: () {
                setState(() {
                  selectedFilter = TaskStatus.completed;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    String statusLabel = '';
    if (selectedFilter == TaskStatus.pending) {
      statusLabel = AppStrings.statusPending;
    } else if (selectedFilter == TaskStatus.overdue) {
      statusLabel = AppStrings.statusOverdue;
    } else if (selectedFilter == TaskStatus.completed) {
      statusLabel = AppStrings.statusCompleted;
    }

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppStrings.noTasksWithStatus} "$statusLabel"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleTaskCard(TaskModel task, int index) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmation(task),
      onDismissed: (direction) => _deleteTask(index),
      child: InkWell(
        onTap: () => _navigateToDetail(task),
        borderRadius: BorderRadius.circular(12),
        child: TaskCard(task: task),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }

  Future<bool?> _showDeleteConfirmation(TaskModel task) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.taskDeleted),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(TaskModel task) {
    Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task);
  }

  // P6: Navigate to add task screen
  void _navigateToAddTask() {
    Navigator.pushNamed(context, AppRoutes.addTask);
  }
}
