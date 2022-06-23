import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'common/const/color_const.dart';
import 'common/util/common_util.dart';
import 'page/home.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    Size minSize = const Size(1080, 760);
    Size initialSize = const Size(1080, 760);
    win.minSize = minSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "收藏";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: CommonUtil.createMaterialColor(primaryColor),
            fontFamily: '宋体',
            dataTableTheme: DataTableThemeData(dataRowColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectColor1;
              }
              return whiteColor;
            })),
            checkboxTheme: const CheckboxThemeData(splashRadius: 18)),
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
        home: const HomePage());
  }
}
