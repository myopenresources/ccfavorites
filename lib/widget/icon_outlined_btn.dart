import 'package:flutter/material.dart';

import '../common/const/color_const.dart';
import '../common/enum/btn_enum.dart';

class IconOutlinedBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BtnType btnType;
  final IconData? icon;
  final double iconSize;

  const IconOutlinedBtn(
      {required this.text,
      this.btnType = BtnType.outlinedGray,
      this.onPressed,
      this.icon,
      this.iconSize = 15,
      Key? key})
      : super(key: key);

  Widget buildBtnContent() {
    if (null != icon) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            icon,
            size: iconSize,
          ),
          Text(" " + text)
        ],
      );
    } else {
      return Text(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle style;
    if (btnType == BtnType.outlinedGreen) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: greenColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return greenColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: greenColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return whiteColor;
            }
            //默认不使用背景颜色
            return whiteColor;
          }));
    } else if (btnType == BtnType.outlinedRed) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: redColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return redColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: redColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return whiteColor;
            }
            //默认不使用背景颜色
            return whiteColor;
          }));
    } else if (btnType == BtnType.outlinedBlue) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: blueColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return blueColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: blueColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return whiteColor;
            }
            //默认不使用背景颜色
            return whiteColor;
          }));
    } else if (btnType == BtnType.outlinedPrimary) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: primaryColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return primaryColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: primaryColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return whiteColor;
            }
            //默认不使用背景颜色
            return whiteColor;
          }));
    }else if (btnType == BtnType.red) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: whiteColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return whiteColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: redColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return redColor;
            }
            //默认不使用背景颜色
            return redColor;
          }));
    } else if (btnType == BtnType.green) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: whiteColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return whiteColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: greenColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return greenColor;
            }
            //默认不使用背景颜色
            return greenColor;
          }));
    } else if (btnType == BtnType.blue) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: whiteColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return whiteColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: blueColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return blueColor;
            }
            //默认不使用背景颜色
            return blueColor;
          }));
    } else if (btnType == BtnType.gray) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: blackColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return blackColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: grayColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return lightGrayColor0;
            }
            //默认不使用背景颜色
            return lightGrayColor0;
          }));
    }else if (btnType == BtnType.primary) {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: whiteColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return whiteColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: primaryColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return primaryColor;
            }
            //默认不使用背景颜色
            return primaryColor;
          }));
    } else {
      style = ButtonStyle(
          shadowColor: MaterialStateProperty.resolveWith((states) {
            return transparentColor1;
          }),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, color: blackColor)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return blackColor;
          }),
          side: MaterialStateProperty.all(
            const BorderSide(width: 0.25, color: grayColor),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return whiteColor;
            }
            //默认不使用背景颜色
            return whiteColor;
          }));
    }

    return ElevatedButton(
      child: buildBtnContent(),
      style: style,
      onPressed: onPressed,
    );
  }
}
