import 'package:flutter/material.dart';
import 'toDoBrain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.orangeAccent,
          background: Colors.white,
          surface: Colors.grey[50]!,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal[700],
          ),
          headlineMedium: TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: Colors.teal[600],
          ),
          bodyLarge: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.teal),
          ),
          labelStyle: TextStyle(color: Colors.teal),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _todoTaskController = TextEditingController();
  TextEditingController _searchTaskController = TextEditingController();
  final Brain brain = Brain();
  int? _highlightedTaskIndex;
  late AnimationController _colorController;
  late dynamic _colorTween;

  @override
  void initState() {
    super.initState();
    _colorController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _colorTween = ColorTween(begin: Colors.orange, end: Colors.transparent);
  }

  @override
  void dispose() {
    _todoTaskController.dispose();
    _searchTaskController.dispose();
    brain.dispose();
    super.dispose();
    _colorController.dispose();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                  'assets/congratulations.webp'), 
              SizedBox(height: 10),
              Text('You have completed the task!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index, bool isCompleted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text(isCompleted
              ? 'Are you sure you want to delete this task?'
              : 'This task is not completed yet. Are you sure you want to delete it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  brain.removeTask(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _searchTask() {
    String searchQuery = _searchTaskController.text.trim();
    int index = brain.findTaskIndex(searchQuery);
    if (index != -1) {
      setState(() {
        _highlightedTaskIndex = index;
        _colorController.forward(from: 0);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Task Not Found'),
            content: Text('No task found with the name "$searchQuery".'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('To-Do List App'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(2.0, 20, 20, 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: TextField(
                    controller: _searchTaskController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'E.g. Buy groceries',
                      prefixIcon: const Icon(Icons.task),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onSubmitted: (value) {
                      _searchTask();
                    },
                    autocorrect: true,
                  ),
                ),
              ),
              Flexible(child: SizedBox(height: 20)),
              Text(
                'ALL TO DOS',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Flexible(child: SizedBox(height: 20)),
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: brain.taskStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No tasks yet'),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final task = snapshot.data![index];
                        return AnimatedContainer(
                          duration: Duration(seconds: 1),
                          color: _highlightedTaskIndex == index
                              ? _colorTween.animate(_colorController).value
                              : Colors.transparent,
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  brain.toggleTaskCompletion(index);
                                  if (task.isCompleted) {
                                    _showCompletionDialog();
                                  }
                                });
                              },
                            ),
                            title: Text(task.task),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    index, task.isCompleted);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: TextField(
                  controller: _todoTaskController,
                  decoration: InputDecoration(
                    hintText: 'Add a new to-do item',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_todoTaskController.text.trim().isNotEmpty) {
                    brain.addTask(_todoTaskController.text);
                    _todoTaskController.clear();
                  } else {
                    print('Task cannot be empty');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          icon: Icon(Icons.error, color: Colors.red),
                          title: Text(
                            'Task cannot be empty',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
