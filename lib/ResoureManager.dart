
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();//������������
  WebSocketChannel? channel2; // �ڶ���WebSocketͨ����δʹ��
  factory ResourceManager() {
    return _instance;
  }
  ResourceManager._internal(){
    _initWebSocket();
  }//˽�й��캯��


  final String _webSocketUrl = 'ws://1.13.2.149:11451';
  late final IOWebSocketChannel _channel;
  late final Stream<dynamic> _stream;
  List<String> roomshowlist = ['��������']; // �������ʾ�б�
  List<DropdownMenuItem<String>> boardShowList = []; // �豸��ʾ�б�

  void _initWebSocket() {
    _channel = IOWebSocketChannel.connect(_webSocketUrl);
    _stream = _channel.stream;
  }
  Stream<dynamic> get stream => _stream;
  void streamAdd(String content){
    _channel.sink.add(content);
  }
    // ���ɷ�����б�
  List<String> generateRoomList(List<String> numbersList) {
    Set<String> uniqueRooms = {"��������"};
    List<String> uniqueRoomids = numbersList.toSet().toList();
    if (uniqueRoomids.length > 1) {
      for (int i = 1; i < numbersList.length; i++) {
        uniqueRooms.add("����$i:${uniqueRoomids[i]}");
      }
    }

    List<String> result = uniqueRooms.toList();
    return result;
  }
  
  // �����豸�б�
  List<DropdownMenuItem<String>> generateBoardList(
      List<Match> boardResponseList) {
    List<DropdownMenuItem<String>> result = [];

    if (boardResponseList.length != 0) {
      for (int i = 0; i < boardResponseList.length; i++) {
        result.add(DropdownMenuItem(
            child: Text(
                "С�����:${boardResponseList[i].group(1)!}   WIFI��:${boardResponseList[i].group(2)!}"),
            value: boardResponseList[i].group(3)!));
      }
    } else {
      String valuee = "0000";
      result.add(DropdownMenuItem(child: Text("����С��"), value: valuee));
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
