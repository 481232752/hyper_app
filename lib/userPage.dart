import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:random_color/random_color.dart';

void main() {
  runApp(UserInfoPage(userName: '小明',));
}

void dispose(){
  //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
}

class UserInfoPage extends StatelessWidget {
  final String userName;
  const UserInfoPage({Key? key, required this.userName }):super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '用户信息',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          leading:  IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
              SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
            },
          ),
          title: Text('用户信息页面'),
        ),
        body: Column( // 将Expanded包裹在Column中
          children: [
            Expanded(
              child: UserInfoWidget(userName: userName),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  final String userName;
  UserInfoWidget({Key? key, required this.userName }):super(key: key);

  final RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    final String region = 'New York';
    final String currentRoom = 'Room 123';
    final int gameCount = 100;
    final double winRate = 0.75;
    final List<String> history = List.generate(
      10,
      (index) => 'Game ${index + 1} - ${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10)}',
    );

    final Color color = _randomColor.randomColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('用户名称: $userName', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('地区: $region'),
                Text('当前所在房间: $currentRoom'),
                Text('对战局数: $gameCount'),
                Text('胜率: ${(winRate * 100).toStringAsFixed(2)}%'),
              ],
            ),
          ),
        ),
        Card(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '历史记录',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(history[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: SizedBox(
            height: 300,
            width: 300,
            child: RadarChart.light(
              ticks: [5, 5, 5, 5, 5],
              features: [
                '存活',
                '杀敌',
                '指挥',
                '突破',
                '机动',
              ],
              data: [
                [4, 3, 2, 4, 5],
              ],
            ),
          ),
        ),
      ],
    );
  }
}


