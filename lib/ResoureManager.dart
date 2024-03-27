import 'package:flutter/material.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();//������������

  factory ResourceManager() {
    return _instance;
  }

  ResourceManager._internal();

  // ��������Ҫ������Ӧ�ó����й������Դ
  // ���磺�ı���ʽ����ɫ��ͼ��ȵ�

  TextStyle get headingTextStyle {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  Color get primaryColor {
    return Colors.blue;
  }

  

}
