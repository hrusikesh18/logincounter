import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _value = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserValue();
  }

  void _loadUserValue() async {
    final value = await _dbHelper.getUserValue(widget.username);
    setState(() {
      _value = value ?? 0;
    });
  }

  void _incrementValue() async {
    setState(() {
      _value++;
    });
    await _dbHelper.saveUserValue(widget.username, _value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welome to Counter App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, ${widget.username}',style: TextStyle(fontSize: 30),),
            SizedBox(height: 30),
            Text('Value: $_value', style: TextStyle(fontSize: 24)),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _incrementValue,
              child: Text('Increment' , style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
