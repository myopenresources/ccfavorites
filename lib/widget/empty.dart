import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class Empty extends StatelessWidget {
  final String assetName;
  final double width;
  final String label;

  const Empty(
      {this.assetName = 'assets/images/default_empty.svg',
      this.width = 150,
      this.label = '暂无数据!',
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          assetName,
          width: width,
        ),
        Text(label)
      ],
    );
  }
}
