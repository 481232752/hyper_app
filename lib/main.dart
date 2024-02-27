import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'RoomPage.dart';

class HorizontalLoginScreen extends StatefulWidget {
  @override
  _HorizontalLoginScreenState createState() => _HorizontalLoginScreenState();
}

class _HorizontalLoginScreenState extends State<HorizontalLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();
  bool isChannel2Connected = false;
  String _selectroomnumber = '';
  List<String> roomlist = ['0000'];
  List<String> roomshowlist = ['创建房间'];
  String boardvalue="0000";
  List<String> boardIpList=[];
  List<DropdownMenuItem<String>> boardShowList=[];
  
  String _selectboardnumber ='0000';
  
  StreamSubscription<dynamic>? subscription;
  bool checkroomsuccess = false;
  bool checkboardsuccess=false;
  final WebSocketChannel channel =
      IOWebSocketChannel.connect('ws://1.13.2.149:11451');
  WebSocketChannel? channel2;
  @override
  void initState() {
    super.initState();
    startListening();
    requestListBoards();
    requestListRooms();
    
    boardShowList.add(DropdownMenuItem(
          child: Text(""),
          value: boardvalue
          ));
  }
  //和服务器的线程是app启动就连接了，小车的连接是在用户点击进入按钮才开始连接的

  //点击进入按钮执行
  void login() {
    //要求用户填充好用户名称小车ip并且选择房间号，如果没有填充好便点击进入则弹出提示
    if (checkroomsuccess & _usernameController.text.isNotEmpty & checkboardsuccess && _selectboardnumber!=boardvalue) {
      String username = _usernameController.text;
      String roomnumber = generateRegisterRoomNumber(_selectroomnumber);

      String register = "register_app:($username,$roomnumber)";
      channel.sink.add(register);
      
      _selectroomnumber = '';
      roomlist = ['0000'];
      roomshowlist = ['创建房间'];
      
      // 检查 channel2 的连接状态
        channel2 = IOWebSocketChannel.connect('ws://${_selectboardnumber}:11451',connectTimeout:new Duration(seconds: 3));
        channel2!.sink.add("request_check:()");
        channel2!.stream.timeout(
          Duration(seconds: 3),
          onTimeout: (sink) => <void>{
            sink.close(),
            showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('连接失败'),
              content: Text('无法连接到小车，请检查IP地址后重试。'),
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
        )
          },
        );
        
      
      // 只有当 channel2 连接成功时，才导航到 RoomPageDemo 页面
      if (isChannel2Connected) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomPageDemo(
              channel1: channel,
              //channel2: channel2,
            ),
          ),
        );
      }

      print(register);
    } else if (_usernameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提示：'),
            content: Text('请填写用户名称！'),
            actions: <Widget>[
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
    }else if(checkboardsuccess==false){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提示：'),
            content: Text('请填写小车ip！'),
            actions: <Widget>[
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
    
    }else if(checkroomsuccess ==false){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提示：'),
            content: Text('请选择房间！'),
            actions: <Widget>[
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

  void requestListRooms() {
    setState(() {
      channel.sink.add("request_list_rooms:()");
    });
    print("发送请求，更新房间列表：$roomshowlist");
  }
  void requestListBoards(){
    setState(() {
      channel.sink.add("request_list_boards:()");
      });
    print("发送请求，更新主板列表：$boardShowList");
  }

  List<String> generateRoomList(List<String> numbersList) {
    Set<String> uniqueRooms = {"创建房间"};
    List<String> uniqueRoomids=numbersList.toSet().toList();
    if (uniqueRoomids.length > 1) {
      for (int i = 1; i < numbersList.length; i++) {
        uniqueRooms.add("房间$i:${uniqueRoomids[1]}");
      }
    }

    List<String> result = uniqueRooms.toList();
    return result;
  }
  List<DropdownMenuItem<String>> generateBoardList(List<Match> boardResponseList){
    List<DropdownMenuItem<String>> result=[];
    if(boardResponseList.length!=0){
    for(int i=0;i<boardResponseList.length;i++){
      result.add(
        DropdownMenuItem(
          child: Text("小车编号:${boardResponseList[i].group(1)!}   WIFI名:${boardResponseList[i].group(2)!}"),
          value: boardResponseList[i].group(3)!
          ));
    }
    
    }
    else{
      List<DropdownMenuItem<String>> result=[];
      String valuee="0000";
      result.add(
        DropdownMenuItem(child: Text("暂无小车"),
        value: valuee
        )
      );

    }

    return result;
  }

  void startListening() {
    subscription = channel.stream.listen(
      (message) {
        if (message.contains("response_list_rooms:")) {
          print(message);
          String roomnumberString = message.replaceAll(RegExp(r'response_list_rooms:|\(|\)'), '');
          roomlist = roomnumberString.split(',');
          print(roomlist);
          roomshowlist = generateRoomList(roomlist);
          setState(() {});
          print('Received message: $roomshowlist');
        }
        else if(message.contains("response_list_boards:")){
          RegExp unwrapResponse = RegExp(r'response_list_boards:\((.*)\)');
          //测试
          //String testTxt="response_list_boards:((0,VIRTUAL,192.168.34.23),(1,METRO,192.168.43.99))";
          print("这里是测试第一步:${unwrapResponse.firstMatch(message)!.group(1)}");
          String matchedStr = unwrapResponse.firstMatch(message)!.group(1)!;
          RegExp regex = RegExp(r'\((.*?),(.*?),(.*?)\)');
          Iterable<Match> matches = regex.allMatches(matchedStr);
          List<Match> boardResponseList=matches.toList();
          //print("这是测试第二步：${boardResponseList[1].group(0)},${boardResponseList[0].group(0)}");
          boardShowList=generateBoardList(boardResponseList);
          setState(() {});
          print(message);
          print("Received board message:$boardShowList");
          
        }
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }
  
  String generateRegisterRoomNumber(String x) {
    String str = '';
    if (x != "创建房间") {
      str = x.split(":")[1];
    } else {
      str = roomlist[0];
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录'),),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '用户名称'),
              ),
              SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '选择设备'),
                hint: Text("请选择设备"),
                onTap: () => requestListBoards(),
                onChanged: (String? newPosition) {
                  setState(() {
                    if (newPosition != null) {
                      _selectboardnumber = newPosition;
                      checkboardsuccess = true;
                    } else {
                      _selectboardnumber = '';
                    }
                    print("选择的ip：$_selectboardnumber");
                  });
                },

                items: boardShowList
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '选择房间'),
                hint: Text("请选择房间"),
                onTap: () => requestListRooms(),
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

                items: roomshowlist.map((String roomnumber) {
                  return DropdownMenuItem(value: roomnumber, child: Text(roomnumber));
                }).toList(),
              ),
              
  
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: login,
                child: Text('进入'),
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
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: HorizontalLoginScreen(),
  ));
}
