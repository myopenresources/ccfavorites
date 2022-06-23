import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';

import '../common/const/color_const.dart';
import '../common/const/style_const.dart';

class DirectorySelect extends StatefulWidget {
  final String initialDirectory;
  final String label;
  final String helperText;
  final String value;
  final void Function(String path) onChanged;
  final void Function(String path)? onCancel;

  const DirectorySelect(
      {required this.initialDirectory,
      required this.label,
      required this.helperText,
      required this.onChanged,
      required this.value,
      this.onCancel,
      Key? key})
      : super(key: key);

  @override
  DirectorySelectState createState() => DirectorySelectState();
}

class DirectorySelectState extends State<DirectorySelect> {
  TextEditingController directoryPathCtrl = TextEditingController();

  @override
  initState() {
    super.initState();
    directoryPathCtrl.text=widget.value;
  }

  Future<void> openSelectDirectoryPath(BuildContext context) async {
    const String confirmButtonText = '确认';
    final String? directoryPath = await getDirectoryPath(
      initialDirectory: widget.initialDirectory,
      confirmButtonText: confirmButtonText,
    );
    if (directoryPath == null) {
      return;
    }

    widget.onChanged(directoryPath);
    directoryPathCtrl.text = directoryPath;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: directoryPathCtrl,
      minLines: 1,
      maxLines: 1,
      style: inputStyle,
      onChanged: (val) {
        widget.onChanged(val);
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.search_rounded),
            color: primaryColor,
            onPressed: () => openSelectDirectoryPath(context),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
            borderSide: BorderSide(
              color: borderColor1,
              width: 0.5, //边线宽度为2
            ),
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
              borderSide: BorderSide(
                color: borderColor1,
                width: 0.5, //宽度为5
              )),
          isDense: true,
          labelText: widget.label,
          labelStyle: inputLabelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          //errorText: "",
          hintText: "请输入或选择目录！",
          helperText: widget.helperText,
          hintStyle: inputHintStyle,
          helperStyle: inputHelperStyle,
          alignLabelWithHint: true,
          prefixText: widget.label),
    );
  }
}
