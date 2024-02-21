import 'package:flutter/material.dart';
import 'package:tasklist/models/task.dart';
import 'package:tasklist/repositories/task_repository.dart';
import 'package:tasklist/widgets/tasklist_item.dart';

class TasklistPage extends StatefulWidget {
  const TasklistPage({super.key});

  @override
  State<TasklistPage> createState() => _TasklistPageState();
}

class _TasklistPageState extends State<TasklistPage> {
  List<Task> tasks = [];

  final TextEditingController taskController = TextEditingController();
  final TaskRepository taskRepository = TaskRepository();
  Task? deletedTask;
  int? deletedTaskPos;
  String? errorText;

  void onDelete(Task task) {
    deletedTask = task;
    deletedTaskPos = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });

    taskRepository.saveTaskList(tasks);

    // Limpa todas as notificações exibidas no momento
    ScaffoldMessenger.of(context).clearSnackBars();

    // Método que exibe a confirmação de exclusão e desfazer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa: ${task.title} removido!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(deletedTaskPos!, deletedTask!);
            });
          },
          textColor: Colors.white,
        ),
        duration: const Duration(
          seconds: 5,
        ),
      ),
    );
  }

  void showMessageDeleteAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar tudo?'),
        content: const Text(
          'Você está prestes a apagar todas as tarefas, tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff00d7f3),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTasks();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              'Limpar tudo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });

    taskRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Todas as tarefas foram excluidas!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    taskRepository.getTaskList().then(
          (taskListRepository) => setState(() {
            tasks = taskListRepository;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tarefas'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicionar uma tarefa',
                          hintText: 'Ex. Pescar',
                          errorText: errorText,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xff00d7f3),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = taskController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'Informe o nome da tarefa';
                          });
                          return;
                        }

                        Task atualTask = Task(
                          title: text,
                          dateTime: DateTime.now(),
                        );

                        setState(() {
                          tasks.add(atualTask);
                          errorText = null;
                        });

                        taskController.clear();
                        taskRepository.saveTaskList(tasks);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task tarefa in tasks)
                        TaskListItem(
                          task: tarefa,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Você possui ${tasks.length} tarefas pendentes',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showMessageDeleteAllTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Limpar tudo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
