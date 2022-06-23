import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../common/const/color_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/home_enum.dart';
import '../event/event.dart';
import '../common/type/home_title_bar_nav_type.dart';
import '../common/type/tree_node_type.dart';
import 'home_audio_data_list.dart';
import 'home_img_data_list.dart';
import 'home_link_data_list.dart';
import 'home_note_data_list.dart';
import 'home_other_data_list.dart';
import 'home_video_data_list.dart';
import 'home_welcome.dart';
import 'right_title_bar.dart';

class HomeRight extends StatefulWidget {
  const HomeRight({Key? key}) : super(key: key);

  @override
  HomeRightState createState() => HomeRightState();
}

class HomeRightState extends State<HomeRight> {
  late StreamSubscription treeNodeClickSubscription;
  late StreamSubscription homeLeftTreeRefreshSubscription;
  HomeTitleBarNavTabPage current = HomeTitleBarNavTabPage.welcome;
  bool isInit = true;
  TreeNodeType? currentNode;

  final List<HomeTitleBarNavType> homeTitleBarNavTabList = [
    HomeTitleBarNavType(label: "书签", key: HomeTitleBarNavTabPage.link),
    HomeTitleBarNavType(label: "笔记", key: HomeTitleBarNavTabPage.note),
    HomeTitleBarNavType(label: "图片", key: HomeTitleBarNavTabPage.img),
    HomeTitleBarNavType(label: "视频", key: HomeTitleBarNavTabPage.video),
    HomeTitleBarNavType(label: "音频", key: HomeTitleBarNavTabPage.audio),
    HomeTitleBarNavType(label: "其它", key: HomeTitleBarNavTabPage.other)
  ];

  final Map<HomeTitleBarNavTabPage, Widget> homeTitleBarNavTabPage = {};
  final Map<HomeTitleBarNavTabPage, dynamic> homeTitleBarNavTabKey = {};

  @override
  void initState() {
    super.initState();
    initHomeTitleBarNavTabKey();
    initHomeTitleBarNavTabPage();
    initEvent();
  }

  @override
  void dispose() {
    super.dispose();
    treeNodeClickSubscription.cancel();
    homeLeftTreeRefreshSubscription.cancel();
  }

  void initHomeTitleBarNavTabKey() {
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.link] =
        homeLinkDataListGlobalKey;
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.img] =
        homeImgDataListGlobalKey;
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.video] =
        homeVideoDataListGlobalKey;
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.note] =
        homeNodeDataListGlobalKey;
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.audio] =
        homeAudioDataListGlobalKey;
    homeTitleBarNavTabKey[HomeTitleBarNavTabPage.other] =
        homeOtherDataListGlobalKey;
  }

  void initHomeTitleBarNavTabPage() {
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.welcome] =
        const HomeWelcome();
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.link] = HomeLinkDataList(
        key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.link]);
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.note] = HomeNoteDataList(
        key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.note]);
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.img] =
        HomeImgDataList(key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.img]);
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.video] = HomeVideoDataList(
        key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.video]);
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.audio] = HomeAudioDataList(
        key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.audio]);
    homeTitleBarNavTabPage[HomeTitleBarNavTabPage.other] = HomeOtherDataList(
        key: homeTitleBarNavTabKey[HomeTitleBarNavTabPage.other]);
  }

  void initEvent() {
    treeNodeClickSubscription =
        eventBus.on<TreeNodeClickEvent>().listen((event) {
      currentNode = event.node;
      if (isInit) {
        setState(() {
          current = HomeTitleBarNavTabPage.link;
          isInit = false;
          getDataList();
        });
      } else {
        setState(() {
          getDataList();
        });
      }
    });

    homeLeftTreeRefreshSubscription =
        eventBus.on<HomeLeftTreeRefreshEvent>().listen((event) {
      setState(() {
        currentNode = null;
        current = HomeTitleBarNavTabPage.welcome;
        isInit = true;
      });
    });
  }

  void getDataList() {
    var key = homeTitleBarNavTabKey[current];
    if (null != key) {
      Future.delayed(const Duration(milliseconds: 66)).then((value) => {
            key.currentState!.currentNode = currentNode,
            key.currentState!.getDataList()
          });
    }
  }

  Widget? getDataPage() {
    return homeTitleBarNavTabPage[current];
  }

  List<Widget> buildNavTabItem(context) {
    List<Widget> list = [];
    if (current == HomeTitleBarNavTabPage.welcome) {
      list.add(Container(
        color: transparentColor1,
        height: appWindow.titleBarHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: const Text(
          '主页',
          style: homeTitleBarTabNavStyle,
        ),
      ));
      return list;
    }
    for (var element in homeTitleBarNavTabList) {
      list.add(GestureDetector(
        child: Container(
          color: current == element.key ? whiteColor : transparentColor1,
          height: appWindow.titleBarHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Text(
            element.label,
            style: homeTitleBarTabNavStyle,
          ),
        ),
        onTap: () => {
          setState(() {
            current = element.key;
            getDataList();
          })
        },
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          RightTitleBar(
              rightBackground: rightTitleBarHeaderBgColor,
              rightBuilder: (context) => Row(
                    children: buildNavTabItem(context),
                  )),
          Expanded(
              child: Container(
                  decoration: const BoxDecoration(
                    color: whiteColor,
                    border: Border(
                        bottom: BorderSide(color: borderColor1, width: 0.5),
                        top: BorderSide(color: borderColor1, width: 0.5)),
                  ),
                  child: getDataPage()))
        ],
      ),
    );
  }
}
