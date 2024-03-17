import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_app/roomDetailPage.dart';
import 'package:hyper_app/userPage.dart';

void main() {
  // 设置为横屏
  runApp(ServerManagementApp());
}

class ServerManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '服务器管理',
      theme: ThemeData(
        primarySwatch: Colors.purple, // 主题颜色为紫色
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int userCount = 0;
  List<User> users = [];
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    // 示例数据
    userCount = 20;
    users = List.generate(20, (index) => User('用户 $index', '房间 ${index % 5}'));
    rooms = List.generate(5, (index) => Room('房间 $index'));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text('服务器管理页面'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Card(
                child: SizedBox(
                  height: 360,
                  width: 360,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '当前在线用户：$userCount',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(
                          color: Color.fromARGB(255, 149, 41, 243),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(users[index].name),
                                subtitle:
                                    Text('所在房间：${users[index].room}'),
                                onTap: () {
                                  //跳转至用户信息界面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserInfoPage(
                                        userName: users[index].name,
                                      ),
                                    ),
                                  );
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.portraitUp,
                                    DeviceOrientation.portraitDown,
                                  ]);
                                  print(
                                      '选择的用户：${users[index].name}，房间：${users[index].room}');
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Card(
                child: SizedBox(
                  height: 360,
                  width: 360,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '当前已创建房间：${rooms.length}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(
                          color: Color.fromARGB(255, 149, 41, 243),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(rooms[index].name),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RoomPage(roomName: rooms[index].name)));
                                  print('选择的房间：${rooms[index].name}');
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ), // 添加一点间距
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]); // 恢复为竖屏
    super.dispose();
  }
}

class User {
  final String name;
  final String room;

  User(this.name, this.room);
}

class Room {
  final String name;

  Room(this.name);
}
