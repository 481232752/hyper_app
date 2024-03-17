import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_app/leaderboardPage.dart';
import 'package:hyper_app/main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(
    MaterialApp(
      home: ControlPage(
        test: "你好",
        channel1: WebSocketChannel.connect(Uri.parse('ws://1.13.2.149:11451')),
        channel2: WebSocketChannel.connect(Uri.parse('ws://1.13.2.149:11451')),
      ),
    ),
  );
}

// 遥控杆部件
class Joystick extends StatefulWidget {
  final Function(Offset) onJoystickChanged;

  const Joystick({Key? key, required this.onJoystickChanged}) : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _position = Offset(0, 0);
  reset(DragEndDetails details) {
    setState(() {
      _position = Offset(0, 0); // 摇杆归位
      widget.onJoystickChanged(_position);
    });
  }

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
      onPanEnd: reset,
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
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 149, 41, 243),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 操控页面
class ControlPage extends StatefulWidget {
  final WebSocketChannel channel1;
  final WebSocketChannel? channel2;
  final String test;

  const ControlPage({
    Key? key,
    required this.test,
    required this.channel1,
    required this.channel2,
  }) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool _isExpanded = false;
  int _health = 100; // 初始血量为100
  int lightState=0;
  // 添加此方法以便跳转到排行榜页面
  void _navigateToRankings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RankingsScreen(channel1: widget.channel1, channel2: widget.channel2,)),
    );
  }

  // 减少血量
  void _decreaseHealth() {
    setState(() {
      _health -= 10; // 减少10点血量
      if (_health < 0) _health = 0; // 确保血量不会小于0
    });
  }
  //调节灯函数
  void _lightControl(){
    if (lightState ==1){
      lightState=0;
      widget.channel2?.sink.add("update_gpio:(1,0)");
      print("关灯！！！！");
    }
    else{
      lightState=1;
      widget.channel2?.sink.add("update_gpio:(1,1)");
      print("开灯！！！！");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.test);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    widget.channel1.sink.add("hello from roompage!");
    widget.channel2?.sink.add("hello from roompage!");

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                "控制界面",
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HorizontalLoginScreen()),
            );
          },
        ),
        // 添加一个按钮以便跳转到排行榜页面
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard),
            onPressed: () => _navigateToRankings(context),
          ),
        ],
      ),
      //可重叠容器
      body: Stack(
        children: [
          // 添加血条
          Positioned(
            top: 10,
            left: 15,
            child: Container(
              width: 120,
              height: 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: LinearProgressIndicator(
                value: _health / 100, // 血量的百分比
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getHealthColor(),
                ),
              ),
            ),
          ),
          Center(
            child: Joystick(
              onJoystickChanged: (Offset offset) {
                widget.channel1.sink.add(offset.toString());
                widget.channel2?.sink.add(offset.toString());
                print(offset);
              },
            ),
          ),
          if (_isExpanded)
            Positioned(
              top: 5,
              right: 8,
              child: Container(
                height: 150,
                width: 200,
                child: ListView.builder(
                  itemCount: 10, // 假设有10个用户
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '用户名称 ${index + 1}:', // 以用户名称进行占位
                              style: TextStyle(color: Colors.white),
                            ),
                            Spacer(),//填充剩余空间，使得组件靠近两边
                            Expanded(
                              child: Container(
                                height: 15,
                                width: 20,
                                child: LinearProgressIndicator(
                                  value: (Random().nextInt(100) + 1) / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getHealthColor(),
                                  ),
                                ),
                              ),
                            ),
                            // 在悬浮列表的血条上显示血量
                            // Positioned.fill(
                            //   child: Center(
                            //     child: Text(
                            //       '${_health}%',
                            //       style: TextStyle(
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      // 开灯关灯按钮
      floatingActionButton: GestureDetector(
        onTapDown:(_){
          print("灯亮！");
          widget.channel2!.sink.add('update_gpio:(1,1)');
        } ,
        onTapUp:(_){
          widget.channel2!.sink.add('update_gpio:(1,0)');
          print("关灯！");
        } ,
        onTapCancel:(){
          widget.channel2!.sink.add('update_gpio:(1,0)');
          print("关灯！");
        } ,
        
        child: FloatingActionButton(
          onPressed: ()=>_lightControl(),
          child:Icon(Icons.lightbulb),
  ),
),

    );
  }

  Color _getHealthColor() {
    if (_health > 70) {
      return Colors.green;
    } else if (_health > 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}

// class RankingsScreen extends StatelessWidget {
//   final WebSocketChannel channel1;
//   final WebSocketChannel? channel2;

//   const RankingsScreen({
//     Key? key,
//     required this.channel1,
//     required this.channel2,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("排行榜"),
//       ),
//       body: Center(
//         child: Text("Rankings will be displayed here"),
//       ),
//     );
//   }
// }

// class HorizontalLoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Horizontal Login"),
//       ),
//       body: Center(
//         child: Text("Horizontal Login Screen"),
//       ),
//     );
//   }
// }





