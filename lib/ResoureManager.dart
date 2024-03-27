
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();//创建单例对象
  WebSocketChannel? channel2; // 第二个WebSocket通道，未使用
  factory ResourceManager() {
    return _instance;
  }
  ResourceManager._internal(){
    _initWebSocket();
  }//私有构造函数


  final String _webSocketUrl = 'ws://1.13.2.149:11451';
  late final IOWebSocketChannel _channel;
  late final Stream<dynamic> _stream;
  List<String> roomshowlist = ['创建房间']; // 房间号显示列表
  List<DropdownMenuItem<String>> boardShowList = []; // 设备显示列表

  void _initWebSocket() {
    _channel = IOWebSocketChannel.connect(_webSocketUrl);
    _stream = _channel.stream;
  }
  Stream<dynamic> get stream => _stream;
  void streamAdd(String content){
    _channel.sink.add(content);
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
  
  void heartAble() {
    _stream.listen((message) {
      if(message.contains("request_check:()")){
        ResourceManager().streamAdd("check:()");
      }
      else if (message.contains("response_list_rooms:")) {
          String roomnumberString =
              message.replaceAll(RegExp(r'response_list_rooms:|\(|\)'), '');
          roomshowlist = generateRoomList(roomnumberString.split(','));
      }
      else if (message.contains("response_list_boards:")) {
          RegExp unwrapResponse = RegExp(r'response_list_boards:\((.*)\)');
          String matchedStr = unwrapResponse.firstMatch(message)!.group(1)!;
          RegExp regex = RegExp(r'\((.*?),(.*?),(.*?)\)');
          Iterable<Match> matches = regex.allMatches(matchedStr);
          List<Match> boardResponseList = matches.toList();
          boardShowList = generateBoardList(boardResponseList);

      }
    });
  }

}
