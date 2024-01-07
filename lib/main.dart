import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyPlannerApp());
}

class TaskModel {
  final String title;
  final String detailEvent;
  final DateTime assignDate;
  final DateTime dueDate;
  final String completionTask;

  TaskModel({
    required this.title,
    required this.detailEvent,
    required this.assignDate,
    required this.dueDate,
    required this.completionTask,
  });
}

class TaskService {
  static List<TaskModel> tasks = [];
}

class MyPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UMT Planner App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        textTheme: GoogleFonts.salsaTextTheme(Theme.of(context).textTheme),
      ),
      home: PlannerHomePage(),
    );
  }
}

class PlannerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UMT PLANNER APP'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Column for the Add Task button and its text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddTaskPage()),
                      );
                    },
                    child: Text('START PLAN'),
                  ),
                  SizedBox(height: 8), // Space between button and text
                  Text('Start Planning Your Task Here!'),
                ],
              ),
              // Column for the View Tasks button and its text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50)))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskListPage()),
                      );
                    },
                    child: Text('MY TASK'),
                  ),
                  SizedBox(height: 8), // Space between button and text
                  Text('View Your Task Allocation Here!'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  DateTime selectedAssignDate = DateTime.now();
  DateTime selectedDueDate = DateTime.now();
  String selectedCompletionTask = 'Not Started';

  Future<void> _selectDate(BuildContext context, bool isAssignDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAssignDate ? selectedAssignDate : selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isAssignDate) {
          selectedAssignDate = picked;
        } else {
          selectedDueDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD TASK'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: detailController,
              decoration: InputDecoration(
                labelText: 'Detail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey, // Set border color
                  width: 1.0, // Set border width
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(
                        'Assign Date: ${DateFormat('dd/MM/yyyy').format(selectedAssignDate)}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: Text(
                        'Due Date: ${DateFormat('dd/MM/yyyy').format(selectedDueDate)}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: selectedCompletionTask,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCompletionTask = newValue!;
                });
              },
              items: ['Not Started', 'In Progress', 'Completed']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Completion Status',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                TaskService.tasks.add(
                  TaskModel(
                    title: titleController.text,
                    detailEvent: detailController.text,
                    assignDate: selectedAssignDate,
                    dueDate: selectedDueDate,
                    completionTask: selectedCompletionTask,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, List<TaskModel>> categorizedTasks = {
      'Not Started': [],
      'In Progress': [],
      'Completed': [],
    };

    for (var task in TaskService.tasks) {
      categorizedTasks[task.completionTask]!.add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('MY TASK'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTaskSection(context, categorizedTasks['Not Started']!,
                'Not Started', Colors.red),
            _buildTaskSection(context, categorizedTasks['In Progress']!,
                'In Progress', Colors.yellow),
            _buildTaskSection(context, categorizedTasks['Completed']!,
                'Completed', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection(
      BuildContext context, List<TaskModel> tasks, String title, Color color) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(color: color)),
        children:
            tasks.map((task) => _buildTaskTile(context, task, color)).toList(),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskModel task, Color color) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(
          '${DateFormat.yMd().format(task.assignDate)} - ${DateFormat.yMd().format(task.dueDate)}'),
      tileColor: color.withOpacity(0.1),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
        );
      },
    );
  }
}

class TaskDetailPage extends StatelessWidget {
  final TaskModel task;

  TaskDetailPage({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.yellow, // Set border color
                width: 1.0, // Set border width
              ),
            ),
            child: Card(
              color: Colors.yellow[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Title:', task.title),
                    _buildDetailRow('Detail:', task.detailEvent),
                    _buildDetailRow('Assign Date:',
                        DateFormat('dd/MM/yyyy').format(task.assignDate)),
                    _buildDetailRow('Due Date:',
                        DateFormat('dd/MM/yyyy').format(task.dueDate)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.salsa(fontSize: 14, color: Colors.blueGrey),
          children: [
            TextSpan(
                text: label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}
