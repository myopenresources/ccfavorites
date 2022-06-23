import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';

class LeftTitleBar extends StatelessWidget {
  final double titleWidth;

  final WidgetBuilder? leftBuilder;

  final Color leftBackground;

  const LeftTitleBar({
    required this.titleWidth,
    required this.leftBackground,
    this.leftBuilder,
    Key? key,
  }) : super(key: key);

  Widget buildLeftEle(context) {
    if (null != leftBuilder) {
      return leftBuilder!(context);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: leftTitleBarHeaderBgColor,
      width: titleWidth,
      child: WindowTitleBarBox(
          child: Row(children: [
        MoveWindow(
          child: Container(
            alignment: Alignment.centerLeft,
            padding:
                const EdgeInsets.symmetric(vertical: 0.25, horizontal: 8.0),
            child: Builder(
              builder: (context) {
                return Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon_1x.png',
                      width: 16,
                      height: 16,
                    ),
                    const Text(
                      ' 河马宝藏库'+currentVersion,
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    )
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          child: MoveWindow(),
        ),
        Container(child: buildLeftEle(context))
      ])),
    );
  }
}
