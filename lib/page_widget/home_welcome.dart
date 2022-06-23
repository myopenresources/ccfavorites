import 'package:flutter/cupertino.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: fontColor8);
    final top = MediaQuery.of(context).size.height / 4.0;

    return Container(
      color: welcomeBgColor,
      padding: EdgeInsets.only(
        top: top,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "assets/images/welcome.png",
            width: 300,
          ),
          Container(
            width: 350,
            height: 235,
            margin: const EdgeInsets.only(left: 40.0, top: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '欢迎使用',
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                  child: const Text(
                    '欢迎使用河马宝藏库，使用前请阅读以下内容：',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: const Text(
                    '1.本软件适用于个人，且完全免费。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: const Text(
                    '2.目前仅支持书签、笔记、图片、视频等功能。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: const Text(
                    '3.首次使用时请您先添加目录。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: const Text(
                    '4.每一个目录既能添加内容，也可以添加子目录。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: const Text(
                    '5.存储的目录可通过配置进行修改。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: const Text(
                    '6.作者享有一切解释权，如有疑问请联系QQ：332557712。',
                    style: style,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: const Text(
                    '7.当前软件版本' + currentVersion + '，后续会根据情况进行更新。',
                    style: style,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
