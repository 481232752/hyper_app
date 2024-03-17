import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_app/administratorPage.dart';
import 'package:hyper_app/controlPage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';



class HorizontalLoginScreen extends StatefulWidget {
  @override
  _HorizontalLoginScreenState createState() => _HorizontalLoginScreenState();
}

class _HorizontalLoginScreenState extends State<HorizontalLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  int administratorCheck=0;
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

  //初始化函数
  void initState() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.initState();
    startListening();
    requestListBoards();
    requestListRooms();
    administratorCheck=0;
    boardShowList.add(DropdownMenuItem(
          child: Text("暂无可用小车"),
          value: boardvalue
          ));

  }
  
  //弹窗函数
  void showDialogF(String title,String text){
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

  //和服务器的线程是app启动就连接了，小车的连接是在用户点击进入按钮才开始连接的
  //点击进入按钮执行
  //进入函数
  Future<void> login() async {
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
      try{
        channel2 = IOWebSocketChannel.connect('ws://${_selectboardnumber}:11451',connectTimeout:new Duration(seconds: 3));
        print('连接ip:ws://${_selectboardnumber}:11451');
        await channel2!.ready;
        isChannel2Connected = true;
      }catch(e){
        print("超时！");
        showDialogF("连接失败", "无法连接到小车，请检查IP地址后重试。");
        channel2=null;
      }
      
      // 只有当 channel2 连接成功时，才导航到 RoomPageDemo 页面
      if (isChannel2Connected) {
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
      }
      print(register);
    } else if (_usernameController.text.isEmpty) {
      //未填写用户名称
      showDialogF("提示：", '请填写用户名称！');
    }else if(checkboardsuccess==false || _selectboardnumber==boardvalue){
      //未选择小车
      showDialogF("提示：", "请选择设备！");
    }else if(checkroomsuccess ==false){
      //未选择房间
      showDialogF("提示：", "请选择房间！");
    }
  }

  //发送更新房间列表请求
  void requestListRooms() {
    setState(() {
      channel.sink.add("request_list_rooms:()");
    });
    print("发送请求，更新房间列表：$roomshowlist");
  }
  
  //发送更新主板列表请求
  void requestListBoards(){
    setState(() {
      channel.sink.add("request_list_boards:()");
      });
    print("发送请求，更新主板列表：$boardShowList");
  }

  //更新房间列表
  List<String> generateRoomList(List<String> numbersList) {
    Set<String> uniqueRooms = {"创建房间"};
    List<String> uniqueRoomids=numbersList.toSet().toList();
    if (uniqueRoomids.length > 1) {
      for (int i = 1; i < numbersList.length; i++) {
        uniqueRooms.add("房间$i:${uniqueRoomids[i]}");
      }
    }

    List<String> result = uniqueRooms.toList();
    return result;
  }
  
  //更新主板列表
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
      print("执行长度为0函数！");
      String valuee="0000";
      result.add(
        DropdownMenuItem(
        child: Text("暂无小车"),
        value: valuee
        )
      );
      print("结果长度:${result.length}");
      print("结果信息:${result[0].child}");
    }
    return result;
  }

  //监听函数（处理服务器发来的信息）1.房间列表信息 2.主板列表信息
  void startListening() {
    subscription = channel.stream.listen(
      (message) {
        if (message.contains("response_list_rooms:")) {
          print(message);
          setState(() {});
          String roomnumberString = message.replaceAll(RegExp(r'response_list_rooms:|\(|\)'), '');
          roomlist = roomnumberString.split(',');
          print(roomlist);
          roomshowlist = generateRoomList(roomlist);
          
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
          
          setState(() {
            boardShowList=generateBoardList(boardResponseList);
          });
          print(message);
          print("Received board message:$boardShowList");
          print("列表长度：${boardResponseList.length}");
          
        }
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }
  
  //生成用户登录信息
  String generateRegisterRoomNumber(String x) {
    String str = '';
    if (x != "创建房间" && x.split(":").length>=2) {
      str = x.split(":")[1];
    } else if(x=="创建房间") {
      str = roomlist[0];
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GestureDetector(
        child: Text('登录'),
        onTap: (){
          administratorCheck+=1;
          print("进入管理员系统step1:$administratorCheck");
        },
        onLongPress: (){
          print("进入管理员系统step2:$administratorCheck");
          if(administratorCheck>=9){
            print("进入管理员系统成功！");
            Navigator.push(context,
            MaterialPageRoute(
            builder: (context) =>DashboardScreen()
            ));
      
          }
          else{
            print("进入管理员系统失败！");
            }
          administratorCheck=0;
        },
        ),),
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
                onTap: () {
                  requestListBoards();},
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
                onTap: () {
                  requestListRooms();} ,
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
  //资源释放
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
