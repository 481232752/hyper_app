import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class RoomPage extends StatefulWidget {
  final Function(Offset) onJoystickChanged;

  const RoomPage({Key? key, required this.onJoystickChanged}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  Offset _position = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
          _position = Offset(_position.dx.clamp(-50, 50), _position.dy.clamp(-50, 50)); // 限制摇杆移动范围
          widget.onJoystickChanged(_position);
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0,0, 600, 0), // 设置左上角位置偏移为 (50, 50)
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: Center(
          child: Transform.translate(
            offset: _position,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomPageDemo extends StatelessWidget {
  final WebSocketChannel channel1;
  //final WebSocketChannel channel2;

  const RoomPageDemo({Key? key, 
  required this.channel1, 
  //测试不需要
  //required this.channel2
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 横屏左向
      DeviceOrientation.landscapeRight, // 横屏右向
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("控制界面"),),
        leading:IconButton( // 添加返回按钮
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 返回到 main 页面并重新加载
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HorizontalLoginScreen()),
              );
          },
        ),
      ),
      body: Center(
        child: RoomPage(
          onJoystickChanged: (Offset offset) {
            // 处理摇杆移动事件
            print(offset);
          },
        ),
      ),
    );
  }
}



