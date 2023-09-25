import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class TextEditDesc extends StatefulWidget {
  const TextEditDesc({super.key});

  @override
  State<TextEditDesc> createState() => _TextEditDescState();
}

class _TextEditDescState extends State<TextEditDesc> {
  QuillController? controller;
  String? title;

  @override
  void didChangeDependencies() {
    var map = ModalRoute.of(context)!.settings.arguments as Map;
    controller = map['controller'];
    title = map['title'];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                )),
          ),
        ),
        title: Text(
          title!.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: .5,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.3)),
                    borderRadius: BorderRadius.circular(12.0)),
                child: QuillEditor.basic(
                  controller: controller!,
                  padding: const EdgeInsets.all(12),
                  autoFocus: true,
                  readOnly: false,
                  expands: false,
                ),
              ),
            ),
            QuillToolbar.basic(
              toolbarIconSize: 22,
              multiRowsDisplay: false,
              showAlignmentButtons: true,
              controller: controller!,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showListCheck: false,
              showIndent: false,
              showSearchButton: false,
              showLink: false,
              iconTheme: QuillIconTheme(
                  iconSelectedColor: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
