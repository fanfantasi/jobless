import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart' hide Config;
import 'package:flutter/material.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';

class WidgetPDFViewer extends StatefulWidget {
  const WidgetPDFViewer({super.key});

  @override
  State<WidgetPDFViewer> createState() => _WidgetPDFViewerState();
}

class _WidgetPDFViewerState extends State<WidgetPDFViewer> {
  String? pdf;
  bool? isAsset;
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var map = ModalRoute.of(context)!.settings.arguments as Map;
    pdf = map['pdf'];
    isAsset = map['asset'];

    if (isAsset!) {
      loadAssetDocument();
    } else {
      loadDocument();
    }
    super.didChangeDependencies();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(pdf!);

    setState(() => _isLoading = false);
  }

  loadAssetDocument() async {
    document = await PDFDocument.fromFile(File(pdf!));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                  )),
            )),
        title: Text(
          'see resume'.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const LoadingWidget()
            : PDFViewer(
                backgroundColor: Theme.of(context).colorScheme.onBackground,
                document: document,
                showPicker: false,
                showNavigation: false,
                progressIndicator: const LoadingWidget(),
                zoomSteps: 1,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        width: MediaQuery.of(context).size.width,
        height: kToolbarHeight - 10,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.0,
            ),
            backgroundColor: Theme.of(context).primaryIconTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.arrow_back_ios),
              Expanded(
                child: Text(
                  'back'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
