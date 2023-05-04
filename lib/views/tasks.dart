import 'package:flutter/material.dart';
import 'package:todo_app/widgets/update_task_dialog.dart';
import 'package:todo_app/services/api_service.dart';

import '../utils/colors.dart';
import '../widgets/delete_task_dialog.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key}) : super(key: key);
  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  bool _isLoading = false;
  List _data = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    if (_isLoading == true) {
      return;
    }
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      Api.get(
        "todos",
      ).then((response) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _data =
                response == null || response.data == null ? [] : response.data;
          });
        }
      }).catchError((onError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 5.0),
            );
          } else if (_data.isEmpty) {
            return const Text('No tasks to display');
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                return _fetchTasks();
              },
              child: ListView(
                children: _data.map((data) {
                  Color taskColor = AppColors.blueShadeColor;
                  bool taskStatus = data['completed'];
                  if (taskStatus) {
                    taskColor = AppColors.greenShadeColor;
                  } else {
                    taskColor = AppColors.redShadeColor;
                  }
                  return Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 5.0,
                          offset:
                              Offset(0, 5), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    child: ListTile(
                      minVerticalPadding: 10.0,
                      leading: Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: taskColor,
                        ),
                      ),
                      title: Text(data['title']),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: 'edit',
                              child: const Text(
                                'Edit',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              onTap: () {
                                int taskId = (data['id']);
                                String taskName = (data['title']);
                                bool taskStatus = (data['completed']);
                                Future.delayed(
                                  const Duration(seconds: 0),
                                  () => showDialog(
                                    context: context,
                                    builder: (context) => UpdateTaskAlertDialog(
                                      taskId: taskId,
                                      taskName: taskName,
                                      taskStatus: taskStatus,
                                    ),
                                  ),
                                );
                              },
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              onTap: () {
                                int taskId = (data['id']);
                                String taskName = (data['title']);
                                Future.delayed(
                                  const Duration(seconds: 0),
                                  () => showDialog(
                                    context: context,
                                    builder: (context) => DeleteTaskDialog(
                                      taskId: taskId,
                                      taskName: taskName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ];
                        },
                      ),
                      dense: true,
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
