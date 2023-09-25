import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text, Style;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/popover.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class WidgetSendVacancy extends StatefulWidget {
  const WidgetSendVacancy({
    super.key,
  });

  @override
  State<WidgetSendVacancy> createState() => _WidgetSendVacancyState();
}

class _WidgetSendVacancyState extends State<WidgetSendVacancy> {
  ResultVacanciesEntity? vacancy;
  final QuillController quillController = QuillController.basic();

  final RoundedLoadingButtonController _btnApplyController =
      RoundedLoadingButtonController();

  File? fileUpload;
  String? filename;

  @override
  void didChangeDependencies() {
    vacancy =
        ModalRoute.of(context)!.settings.arguments as ResultVacanciesEntity;
    super.didChangeDependencies();
  }

  Future<void> openMediaModal() async {
    final action = CupertinoActionSheet(
      actions: [
        Material(
          child: InkWell(
            onTap: () async {
              Navigator.pop(context);
              FilePickerResult? result = await FilePicker.platform
                  .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

              if (result != null) {
                setState(() {
                  fileUpload = File(result.files.single.path!);
                  filename = result.files.single.path!.split('/').last;
                });
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Icon(CupertinoIcons.doc_on_clipboard_fill,
                      color: Colors.blue[400]),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Text(
                    "File",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "cancel".tr(),
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  void sendData() async {
    try {
      var html = DeltaToHTML.encodeJson(
        quillController.document.toDelta().toJson(),
      );

      if (!mounted) return;

      BlocProvider.of<PostDataCubit>(context)
          .patchApplicants(
              id: '',
              applicantId: context.read<UserCubit>().user!.id,
              vacancyId: vacancy!.id,
              desc: html,
              status: 'pending',
              file: fileUpload)
          .then((value) {
        if (value) {
          showButtomSheetInfo(success: value);
        } else {
          showButtomSheetInfo(success: value);
        }
      });
      _btnApplyController.reset();
    } catch (_) {
      _btnApplyController.reset();
    }
  }

  Future<void> showButtomSheetInfo({bool? success}) async {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Center(
                  child: Lottie.asset(
                      success!
                          ? 'assets/lottie/success.json'
                          : 'assets/lottie/error.json',
                      fit: BoxFit.cover,
                      height: kToolbarHeight * 4),
                ),
                Text(
                  success ? 'successful'.tr() : 'oops, failed'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Theme.of(context).primaryColor),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    success
                        ? 'successfull applicant desc'.tr()
                        : 'oop, failed desc'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.8)),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  width: double.infinity,
                  height: kToolbarHeight - 10,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                        backgroundColor:
                            Theme.of(context).primaryIconTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: Text(
                        success ? 'Ok' : 'try again'.tr(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (success) Navigator.pop(context, true);
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        title: const Text(
          'Jobs Details',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ]),
                child: Row(
                  children: [
                    SizedBox(
                      height: 82,
                      width: MediaQuery.of(context).size.width / 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${Config.baseUrl}/${Config.imageEmployers}/${vacancy!.image ?? vacancy!.userCompany!.photo}',
                          placeholder: (context, url) => const Center(
                              child: LoadingWidget(
                            fallingDot: true,
                          )),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/icons/logo-empty.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12.0,
                    ),
                    const SizedBox(
                      width: 12.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: AutoSizeText(
                              vacancy!.title!,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.6),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            vacancy!.userCompany!.companyname!,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(.6),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.6),
                                    size: 16.0,
                                  ),
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  Text(
                                    timeago.format(
                                        DateTime.parse(vacancy!.createdAt!),
                                        locale: 'locale'.tr()),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'applicants'.tr(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                    TextSpan(
                                      text: ' (${vacancy!.application ?? '0'})',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(
                height: .5,
              ),
              const SizedBox(
                height: 16.0,
              ),
              Text(
                'upload resume'.tr(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text('upload resume desc'.tr()),
              const SizedBox(
                height: 16.0,
              ),
              Visibility(
                visible: fileUpload != null,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).primaryColor),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/pdf-view',
                        arguments: {'pdf': fileUpload!.path, 'asset': true}),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(filename ?? 'FIle name.pdf',
                            style: const TextStyle(color: Colors.white)),
                        InkWell(
                          onTap: () {
                            setState(() {
                              filename = null;
                              fileUpload = null;
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.1)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, .5),
                      blurRadius: 4,
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: fileUpload == null ? () => openMediaModal() : null,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .primaryIconTheme
                              .color!
                              .withOpacity(.1),
                          radius: 33,
                          child: Icon(Icons.cloud_upload_rounded,
                              color: fileUpload == null
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'upload resume'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.4)),
                      ),
                    )
                  ],
                ),
              ),
              Text(
                'desc'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text('tell us about yourself briefly'.tr()),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryIconTheme.color!,
                    ),
                    borderRadius: BorderRadius.circular(16.0)),
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    final res = await Navigator.pushNamed(
                      context,
                      '/text-editor',
                      arguments: {
                        'title': 'desc',
                        'controller': quillController
                      },
                    );
                    if (res != null && res is bool) {
                      setState(() {});
                    }
                  },
                  child: Html(
                    data: DeltaToHTML.encodeJson(
                      quillController.document.toDelta().toJson(),
                    ),
                    style: {
                      'p': Style(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.8),
                      ),
                      'ul': Style(
                        padding: HtmlPaddings.only(left: 8.0),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.8),
                      ),
                      'ol': Style(
                        padding: HtmlPaddings.only(left: 18.0),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.8),
                      )
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: RoundedLoadingButton(
          animateOnTap: true,
          errorColor: Colors.red.shade200,
          controller: _btnApplyController,
          onPressed: () async {
            if (!context.mounted) return;

            if (fileUpload == null) {
              _btnApplyController.error();
              Fluttertoast.showToast(msg: 'upload resume desc'.tr());
              Future.delayed(const Duration(seconds: 1), () {
                _btnApplyController.reset();
              });
            } else {
              sendData();
            }
          },
          borderRadius: 22,
          elevation: 0,
          color: Theme.of(context).primaryColor,
          height: kToolbarHeight - 12,
          width: MediaQuery.of(context).size.width,
          child: Text(
            'apply now'.tr(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
