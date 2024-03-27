import 'package:flutter/material.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();//创建单例对象

  factory ResourceManager() {
    return _instance;
  }

  ResourceManager._internal();

  // 定义您想要在整个应用程序中共享的资源
  // 例如：文本样式、颜色、图像等等

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
