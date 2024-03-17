import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(RoomPage(roomName: "房间1")); // 传入房间名称
}

class User {
  final String name;
  int health;

  User({required this.name, required this.health});
}

class RoomPage extends StatefulWidget {
  final String roomName; // 添加房间名称参数

  RoomPage({required this.roomName});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<User> users = [];
  String roomLocation = "浙江省";

  @override
  void initState() {
    super.initState();
    // Generate some dummy user data
    for (int i = 1; i <= 5; i++) {
      users.add(User(name: "用户$i", health: Random().nextInt(100) + 1));
    }
    // Start a timer to update user health randomly
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        for (var user in users) {
          user.health = Random().nextInt(100) + 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading:  IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              //返回
              Navigator.pop(context);
              SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
            },
          ),
          title: Text('房间信息 - ${widget.roomName}'), // 显示房间名称
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child:
              Text(
                '房间位置: $roomLocation',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${users[index].name}'),
                    subtitle: Stack(
                      children: [
                        LinearProgressIndicator(
                          value: users[index].health / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColor(users[index].health),
                          ),
                          minHeight: 15,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              '${users[index].health}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(int health) {
    if (health > 70) {
      return Colors.green;
    } else if (health > 30) {
      return Color.fromARGB(255, 245, 138, 6);
    } else {
      return Colors.red;
    }
  }
}



