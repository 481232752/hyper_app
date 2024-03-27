import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hyper_app/administratorPage.dart';
import 'package:hyper_app/controlPage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HorizontalLoginScreen extends StatefulWidget {
  @override
  _HorizontalLoginScreenState createState() => _HorizontalLoginScreenState();
}

class _HorizontalLoginScreenState extends State<HorizontalLoginScreen> {
  // 初始化变量
  final TextEditingController _usernameController = TextEditingController(); // 用户名输入控制器
  final TextEditingController _passwordController = TextEditingController(); // 密码输入控制器
  bool checkroomsuccess = false; // 是否选择房间成功标志
  bool checkboardsuccess = false; // 是否选择设备成功标志
  String _selectroomnumber = ''; // 选定的房间号
  List<String> roomlist = ['0000']; // 房间号列表
  List<String> roomshowlist = ['创建房间']; // 房间号显示列表
  String boardvalue = "0000"; // 默认设备号
  List<String> boardIpList = []; // 设备IP列表
  List<DropdownMenuItem<String>> boardShowList = []; // 设备显示列表
  String _selectboardnumber = '0000'; // 选定的设备号
  StreamSubscription<dynamic>? subscription; // WebSocket监听
  final WebSocketChannel channel = IOWebSocketChannel.connect('ws://1.13.2.149:11451'); // WebSocket通道
  WebSocketChannel? channel2; // 第二个WebSocket通道，未使用
  bool isChannel2Connected=false;
  int administratorCheck = 0; // 管理员检查计数器

  @override
  void initState() {
    // 设定APP支持所有屏幕方向
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.initState();
    startListening();
    requestListBoards();
    requestListRooms();
    administratorCheck = 0;
    boardShowList.add(DropdownMenuItem(
      child: Text("暂无可用小车"),
      value: boardvalue,
    ));
  }

  // 弹窗函数，参数：标题，内容
  void showDialogF(String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 登录函数
  Future<void> login() async {
    if (checkroomsuccess &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        checkboardsuccess &&
        _selectboardnumber != boardvalue) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      String roomnumber = generateRegisterRoomNumber(_selectroomnumber);

      String register = "register_app:($username,$roomnumber)";
      channel.sink.add(register);
      try{
        channel2 = IOWebSocketChannel.connect('ws://${_selectboardnumber}:11451',connectTimeout:new Duration(seconds: 3));
        print('连接ip:ws://${_selectboardnumber}:11451');
        await channel2!.ready;
        isChannel2Connected=true;
        
        
      }catch(e){
        print("超时！");
        showDialogF("连接失败", "无法连接到小车，请检查IP地址后重试。");
        channel2=null;
      }
      
      try {
        final response = await http.post(
          Uri.parse('http://mineralsteins.icu:11452/test'),
          body: {
            'username': username,
            'password': password,
          },
        );

        if (response.statusCode == 200 && isChannel2Connected) {
          // 如果服务器返回成功响应，则执行一些逻辑
          print('登录成功');
          // 登录成功后的逻辑在这里执行
          channel2!.sink.add("request_occupy:()");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ControlPage(
                test: "连接成功！",
                channel1: channel,
                channel2: channel2,
              ),
            ),
          );
          print(register);
      // 向服务器发送用户名和密码
        } else {
          // 如果响应不是成功的，则抛出异常
          throw Exception('登录失败');
        }
      } catch (e) {
        // 捕获异常并显示错误弹窗
        print('错误: $e');
        showDialogF("错误", "登录失败，请检查网络连接并重试。");
      }

    } else if (_usernameController.text.isEmpty) {
      showDialogF("提示：", '请输入手机号！');
    } else if (_passwordController.text.isEmpty) {
      showDialogF("提示：", '请输入密码！');
    } else if (checkboardsuccess == false || _selectboardnumber == boardvalue) {
      showDialogF("提示：", "请选择设备！");
    } else if (checkroomsuccess == false) {
      showDialogF("提示：", "请选择房间！");
    }
  }

  // 请求房间列表
  void requestListRooms() {
    setState(() {
      channel.sink.add("request_list_rooms:()");
    });
  }

  // 请求设备列表
  void requestListBoards() {
    setState(() {
      channel.sink.add("request_list_boards:()");
    });
  }

  // 生成房间号列表
  List<String> generateRoomList(List<String> numbersList) {
    Set<String> uniqueRooms = {"创建房间"};
    List<String> uniqueRoomids = numbersList.toSet().toList();
    if (uniqueRoomids.length > 1) {
      for (int i = 1; i < numbersList.length; i++) {
        uniqueRooms.add("房间$i:${uniqueRoomids[i]}");
      }
    }

    List<String> result = uniqueRooms.toList();
    return result;
  }

  // 生成设备列表
  List<DropdownMenuItem<String>> generateBoardList(
      List<Match> boardResponseList) {
    List<DropdownMenuItem<String>> result = [];

    if (boardResponseList.length != 0) {
      for (int i = 0; i < boardResponseList.length; i++) {
        result.add(DropdownMenuItem(
            child: Text(
                "小车编号:${boardResponseList[i].group(1)!}   WIFI名:${boardResponseList[i].group(2)!}"),
            value: boardResponseList[i].group(3)!));
      }
    } else {
      String valuee = "0000";
      result.add(DropdownMenuItem(child: Text("暂无小车"), value: valuee));
    }
    return result;
  }

  // 开始监听WebSocket
  void startListening() {
    subscription = channel.stream.listen(
      (message) {
        if (message.contains("response_list_rooms:")) {
          setState(() {});
          String roomnumberString =
              message.replaceAll(RegExp(r'response_list_rooms:|\(|\)'), '');
          roomlist = roomnumberString.split(',');
          roomshowlist = generateRoomList(roomlist);
        } else if (message.contains("response_list_boards:")) {
          RegExp unwrapResponse = RegExp(r'response_list_boards:\((.*)\)');
          String matchedStr = unwrapResponse.firstMatch(message)!.group(1)!;
          RegExp regex = RegExp(r'\((.*?),(.*?),(.*?)\)');
          Iterable<Match> matches = regex.allMatches(matchedStr);
          List<Match> boardResponseList = matches.toList();

          setState(() {
            boardShowList = generateBoardList(boardResponseList);
          });
        }
      },
      onError: (error) {
        print('错误: $error');
      },
    );
  }

  // 生成注册的房间号
  String generateRegisterRoomNumber(String x) {
    String str = '';
    if (x != "创建房间" && x.split(":").length >= 2) {
      str = x.split(":")[1];
    } else if (x == "创建房间") {
      str = roomlist[0];
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text('登录'),
          onTap: () {
            print("当前连击数：$administratorCheck");
            administratorCheck += 1;
          },
          onLongPress: () {
            if (administratorCheck >= 9) {
              print("进入管理员系统成功！");
              // 导航到管理员页面
            Navigator.push(context,
            MaterialPageRoute(
            builder: (context) =>DashboardScreen()
            ));
            } else {
              print("进入管理员系统失败！");
            }
            administratorCheck = 0;
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '手机号'), // 手机号输入框
                keyboardType: TextInputType.phone, // 键盘类型为手机号
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // 限制只能输入数字
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '密码'), // 密码输入框
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: '选择设备'),
                hint: Text("请选择设备"),
                onTap: () {
                  requestListBoards();
                },
                onChanged: (String? newPosition) {
                  setState(() {
                    if (newPosition != null) {
                      _selectboardnumber = newPosition;
                      checkboardsuccess = true;
                    } else {
                      _selectboardnumber = '';
                    }
                  });
                },
                items: boardShowList,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: '选择房间'),
                hint: Text("请选择房间"),
                onTap: () {
                  requestListRooms();
                },
                onChanged: (String? newPosition) {
                  setState(() {
                    if (newPosition != null) {
                      _selectroomnumber = newPosition;
                      checkroomsuccess = true;
                    } else {
                      _selectroomnumber = '';
                    }
                  });
                },
                items: roomshowlist
                    .map((String roomnumber) {
                      return DropdownMenuItem(
                          value: roomnumber, child: Text(roomnumber));
                    })
                    .toList(),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: login,
                child: Text('进入'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      print("注册账户");
                    },
                    child: Text('注册账户'),
                  ),
                  TextButton(
                    onPressed: () {
                      print("忘记密码");
                    },
                    child: Text('忘记密码'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    channel2!.sink.close();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: HorizontalLoginScreen(),
  ));
}

