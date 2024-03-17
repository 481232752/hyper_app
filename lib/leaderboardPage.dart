import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(
    MaterialApp(
      home: RankingsScreen(
        channel1: WebSocketChannel.connect(Uri.parse('ws://1.13.2.149:11451')),
        channel2: WebSocketChannel.connect(Uri.parse('ws://1.13.2.149:11451')),
      ),
    ),
  );
}

class RankingsScreen extends StatefulWidget {
  final WebSocketChannel channel1;
  final WebSocketChannel? channel2;
  const RankingsScreen({Key? key, required this.channel1,required this.channel2}) : super(key: key);

  @override
  _RankingsScreenState createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  late List<User> user_rank_all=[];
  late List<User> user_rank_month=[];
  late List<User> user_rank_week=[];
  var myStreamController = StreamController<String>.broadcast();
  

  @override
  //初始化函数
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    startListening();
  
  }
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,]);
    super.dispose();
  
  }

  //开始监听
  void startListening() {
    // Simulating receiving ranking list data
    user_rank_all = _generateUsers(16);
    user_rank_month = _generateUsers(16);
    user_rank_week = _generateUsers(6);
    myStreamController.stream.listen((message) {
      if (message.contains("response_rank_list:")) {
        setState(() {
          user_rank_all = _generateUsers(16);
          user_rank_month = _generateUsers(16);
          user_rank_week = _generateUsers(6);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('排行榜'),
            centerTitle: false,
            actions: [
              //返回按钮
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                  
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: '总榜'),
                Tab(text: '月榜'),
                Tab(text: '地区周榜'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildRankingList('总榜', user_rank_all, true),
              _buildRankingList('月榜', user_rank_month, true),
              _buildRankingList('地区周榜', user_rank_week, false),
            ],
          ),
        ),
      ),
    );
  }

  List<User> _generateUsers(int count) {
    List<User> users = [];
    for (int i = 1; i <= count; i++) {
      users.add(User('选手$i', 100 - i * 5, i, '地区$i'));
    }
    return users;
  }
  
  Widget _buildRankingList(String category, List<User> users, bool showArea) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: users.map((user) {
          return _buildRankingCard(user.rank, user.name, user.score, showArea ? user.area : null);
        }).toList(),
      ),
    );
  }

  Widget _buildRankingCard(int rank, String name, int score, String? area) {
    Color rankColor = rank == 1 ? const Color.fromARGB(255, 252, 211, 3) :
                      rank == 2 ? const Color.fromARGB(255, 201, 201, 201) :
                      rank == 3 ? const Color.fromARGB(255, 226, 117, 8) : Colors.transparent;
    Color fontColor = rank == 1 ? Colors.purpleAccent:
                      rank == 2 ? const Color.fromARGB(255, 254, 184, 6):
                      rank == 3 ? const Color.fromARGB(255, 69, 227, 2) : Colors.black;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: rankColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              '排名: ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$rank',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: fontColor,
              ),
            ),
            const SizedBox(width: 32.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '姓名: $name',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  if (area != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      '地区: $area',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  SizedBox(height: 4.0),
                  Text(
                    '得分: $score',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String name;
  final int score;
  final int rank;
  final String area;

  User(this.name, this.score, this.rank, this.area);

}

