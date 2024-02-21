import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasklist/models/task.dart';

const taskListKey = 'taskList';

class TaskRepository {
  TaskRepository() {
    SharedPreferences.getInstance().then(
      (value) {
        sharedPreferences = value;
        print(sharedPreferences.getString('taskList'));
      },
    );
  }

  late SharedPreferences sharedPreferences;

  void saveTaskList(List<Task> tasks) {
    final String jsonString = json.encode(tasks);
    sharedPreferences.setString(taskListKey, jsonString);
  }

  Future<List<Task>> getTaskList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(taskListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;

    return jsonDecoded
        .map(
          (e) => Task.fromJson(e),
        )
        .toList();
  }
}
