import 'package:flutter/material.dart';

// ��һ��ҳ���ʾ������Ҫ�滻����ʵ�ʵ�ҳ����
class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('��һ��ҳ��'),
      ),
      body: Center(
        child: Text('������һ��ҳ��'),
      ),
    );
  }
}
