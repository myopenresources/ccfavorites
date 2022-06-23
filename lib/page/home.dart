import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:tray_manager/tray_manager.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../page_widget/home_left.dart';
import '../page_widget/home_right.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TrayListener {
  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  void showWindow() {
    appWindow.restore();
    appWindow.show();
  }

  Future<void> initSystemTray() async {
    trayManager.addListener(this);

    String path = Platform.isWindows
        ? 'assets/images/app_icon.ico'
        : 'assets/images/app_icon_1x.png';

    await trayManager.setIcon(path);

    List<MenuItem> items = [
      MenuItem(key: appTrayMenuKey['showApp'], label: '显示应用'),
      MenuItem(
        key: appTrayMenuKey['minimizeApp'],
        label: '最小化应用',
      ),
      MenuItem(
        key: appTrayMenuKey['hideApp'],
        label: '隐藏应用',
      ),
      MenuItem(
        key: appTrayMenuKey['exitApp'],
        label: '关闭应用',
      ),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(children: const [HomeLeft(), HomeRight()])));
  }

  @override
  void onTrayIconMouseDown() {
    showWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == appTrayMenuKey['exitApp']) {
      appWindow.close();
    }

    if (menuItem.key == appTrayMenuKey['showApp']) {
      showWindow();
    }

    if (menuItem.key == appTrayMenuKey['minimizeApp']) {
      appWindow.minimize();
    }

    if (menuItem.key == appTrayMenuKey['hideApp']) {
      appWindow.hide();
    }
  }
}
