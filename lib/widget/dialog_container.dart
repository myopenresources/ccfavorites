import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../common/const/color_const.dart';
import '../common/type/dialog_type.dart';

class DialogContainer extends StatefulWidget {
  final double dialogWidth;
  final double dialogHeight;
  final double dialogPadding;
  final String dialogTitle;
  final TextStyle dialogTitleStyle;
  final double dialogBorderRadius;
  final Color dialogBg;
  final Color dialogHeaderBg;
  final bool showDialogHeader;
  final bool showDialogFooter;
  final double dialogHeaderHeight;
  final Color dialogHeaderBorderColor;
  final WidgetBuilder? dialogHeaderBuilder;
  final DialogIconStyleType dialogIconStyle;
  final double dialogFooterHeight;
  final Color dialogFooterBorderColor;
  final Color dialogFooterBg;
  final WidgetBuilder? dialogFooterBuilder;
  final WidgetBuilder dialogBodyBuilder;
  final VoidCallback? onDialogClose;
  final bool dialogHeaderCloseBtn;

  const DialogContainer(
      {required this.dialogWidth,
      required this.dialogHeight,
      required this.dialogBodyBuilder,
      this.dialogTitle = '',
      this.dialogPadding = 10,
      this.dialogBorderRadius = 4,
      this.dialogBg = whiteColor,
      this.dialogHeaderHeight = 30,
      this.dialogHeaderBg = whiteColor,
      this.dialogHeaderBorderColor = borderColor1,
      this.dialogHeaderBuilder,
      this.showDialogHeader = true,
      this.showDialogFooter = true,
      this.dialogFooterHeight = 35,
      this.dialogHeaderCloseBtn = true,
      this.dialogFooterBg = whiteColor,
      this.dialogFooterBorderColor = borderColor1,
      this.dialogFooterBuilder,
      this.dialogTitleStyle = const TextStyle(
          fontSize: 15, color: primaryColor, fontWeight: FontWeight.bold),
      this.dialogIconStyle = const DialogIconStyleType(
          size: 20,
          color: grayColor,
          hoverColor: redColor,
          enterColor: redColor),
      this.onDialogClose,
      Key? key})
      : super(key: key);

  @override
  DialogContainerState createState() => DialogContainerState();
}

class DialogContainerState extends State<DialogContainer> {
  late Color closeColor;

  @override
  void initState() {
    super.initState();
    closeColor = widget.dialogIconStyle.color;
  }

  Widget buildHeader(context) {
    if (null != widget.dialogHeaderBuilder) {
      return widget.dialogHeaderBuilder!(context);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dialogTitle,
            style: widget.dialogTitleStyle,
          ),
          const Spacer(),
          if (widget.dialogHeaderCloseBtn)
            MouseRegion(
                cursor: SystemMouseCursors.click,
                onHover: (event) {
                  setState(() {
                    closeColor = widget.dialogIconStyle.hoverColor;
                  });
                },
                onExit: (event) {
                  setState(() {
                    closeColor = widget.dialogIconStyle.color;
                  });
                },
                onEnter: (event) {
                  setState(() {
                    closeColor = widget.dialogIconStyle.enterColor;
                  });
                },
                child: GestureDetector(
                  child: Icon(
                    Icons.close,
                    color: closeColor,
                    size: widget.dialogIconStyle.size,
                  ),
                  onTap: widget.onDialogClose,
                ))
        ],
      );
    }
  }

  Widget buildFooter(context) {
    if (null != widget.dialogFooterBuilder) {
      return widget.dialogFooterBuilder!(context);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.dialogHeight,
      width: widget.dialogWidth,
      padding: EdgeInsets.all(widget.dialogPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.dialogBorderRadius),
        color: widget.dialogBg,
      ),
      child: Column(
        children: [
          if (widget.showDialogHeader)
            Container(
              height: widget.dialogHeaderHeight,
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: widget.dialogHeaderBorderColor, width: 0.5)),
                color: widget.dialogHeaderBg,
              ),
              child: buildHeader(context),
            ),
          Expanded(child: widget.dialogBodyBuilder(context)),
          if (widget.showDialogFooter)
            Container(
              height: widget.dialogFooterHeight,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: widget.dialogFooterBorderColor, width: 0.5)),
                color: widget.dialogFooterBg,
              ),
              child: buildFooter(context),
            )
        ],
      ),
    );
  }
}
