import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../common/const/color_const.dart';
import '../widget/common_confirm_dialog.dart';

class RightTitleBar extends StatelessWidget {
  final WidgetBuilder? rightBuilder;

  final Color rightBackground;

  const RightTitleBar({
    required this.rightBackground,
    this.rightBuilder,
    Key? key,
  }) : super(key: key);

  Widget buildRightEle(context) {
    if (null != rightBuilder) {
      return rightBuilder!(context);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: WindowTitleBarBox(
        child: Container(
          color: rightBackground,
          child: Row(
            children: [
              buildRightEle(context),
              Expanded(child: MoveWindow()),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      child: Container(),
                    ),
                  ),
                  const WindowButtons()
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    mouseOver: primaryColor,
    mouseDown: primaryColor,
    iconNormal: grayColor,
    iconMouseOver: whiteColor,
    iconMouseDown: whiteColor);

final closeButtonColors = WindowButtonColors(
    mouseOver: redAccentColor,
    mouseDown: redColor,
    iconNormal: grayColor,
    iconMouseOver: whiteColor,
    iconMouseDown: whiteColor);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
            colors: closeButtonColors,
            onPressed: () => {
                  CommonConfirmDialog.showCustomConfirmDialog(
                      'exitAppDialog', 280, 160, '你确定关闭应用吗？', (pop) {
                    pop();
                    appWindow.close();
                  }, (pop) {
                    pop();

                    Future.delayed(const Duration(milliseconds: 250), () {
                      appWindow.hide();
                    });
                  }, '关闭应用', '最小化到托盘')
                }),
      ],
    );
  }
}
