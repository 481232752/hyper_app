import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';

// 遥感部件
class Joystick extends StatefulWidget {
  final Function(Offset) onJoystickChanged;

  const Joystick({Key? key, required this.onJoystickChanged}) : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
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
        margin: EdgeInsets.fromLTRB(0, 0, 600, 0), // 设置左上角位置偏移为 (50, 50)
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

// 房间页面
class RoomPage extends StatelessWidget {
  final WebSocketChannel channel1;
  final WebSocketChannel? channel2;
  final String test;

  const RoomPage({
    Key? key,
    required this.test,
    required this.channel1,
    required this.channel2,
  }) : super(key: key);

  void startListening() {
    channel2!.stream.listen(
      (message) {},
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(test);
    channel1.sink.add("hello form roompage!");
    channel2!.sink.add("hello form roompage!");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 横屏左向
      DeviceOrientation.landscapeRight, // 横屏右向
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("控制界面")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HorizontalLoginScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Joystick(
              onJoystickChanged: (Offset offset) {
                channel1.sink.add(offset.toString());
                channel2?.sink.add(offset.toString());
                print(offset);
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                print("灯亮!");
                channel2!.sink.add('updata_gpio:((0,1))');
                //(a,b) a为部件编号 b为状态
              },
              child: Text("开灯"),
            ),
          ),
        ],
      ),
    );
  }
}





