import 'dart:async';

class Task {
  String task;
  bool isCompleted;

  Task({required this.task, this.isCompleted = false});
}

class Brain {
  final _taskController = StreamController<List<Task>>.broadcast();

  Stream<List<Task>> get taskStream => _taskController.stream;

  List<Task> _tasks = [];

  void addTask(String task) {
    _tasks.add(Task(task: task));
    _taskController.sink.add(_tasks); // Notify listeners of the change
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    _taskController.sink.add(_tasks); // Notify listeners of the change
  }

  void toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    _taskController.sink.add(_tasks); // Notify listeners of the change
  }

  int findTaskIndex(String taskName) {
    return _tasks.indexWhere((task) => task.task == taskName);
  }

  List<Task> getTask() {
    for (Task task in _tasks) {
      print(task.task);
    }
    return _tasks;
  }

  bool searchTask(String text) {
    for (Task task in _tasks) {
      if (task.task == text) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _taskController.close();
  }
}
