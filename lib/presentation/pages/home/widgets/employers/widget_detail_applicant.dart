import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/list_widget.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/popover.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text, Style;

class WidgetDetailApplicantEmployers extends StatefulWidget {
  const WidgetDetailApplicantEmployers({super.key});

  @override
  State<WidgetDetailApplicantEmployers> createState() =>
      _WidgetDetailApplicantEmployersState();
}

class _WidgetDetailApplicantEmployersState
    extends State<WidgetDetailApplicantEmployers> {
  ResultApplicantsEntity? data;
  final QuillController quillController = QuillController.basic();
  String? mark;
  String? labelmark;
  DateTime? dateSend;
  String? labelDate;
  TimeOfDay? timeSend;
  String? labelTime;
  final FocusNode editorFocusNode = FocusNode();
  final RoundedLoadingButtonController _btnSendController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    dateSend = DateTime.now();
    labelDate = DateFormat('dd MMMM yyyy').format(dateSend!);
    labelTime = DateFormat('HH:mm a').format(dateSend!);
    timeSend = TimeOfDay(hour: dateSend!.hour, minute: dateSend!.minute);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    data = ModalRoute.of(context)!.settings.arguments as ResultApplicantsEntity;
    super.didChangeDependencies();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateSend!,
        firstDate: DateTime.now(),
        lastDate: DateTime(dateSend!.year, dateSend!.month + 6),
        builder: (context, child) {
          return Theme(
              data: ThemeData(primaryColor: Theme.of(context).primaryColor),
              child: child!);
        });
    if (picked != null && picked != dateSend) {
      setState(() {
        dateSend = picked;
        labelDate = DateFormat('dd MMMM yyyy').format(dateSend!);
      });
    }
  }

  Future<void> selectedTime24Hour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 47),
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: ThemeData(primaryColor: Theme.of(context).primaryColor),
            child: child!);
      },
    );
    if (picked != null && picked != timeSend) {
      setState(() {
        timeSend = picked;
        labelTime = DateFormat('HH:mm a').format(DateTime(dateSend!.year,
            dateSend!.month, dateSend!.hour, picked.hour, picked.minute));
      });
    }
  }

  void sendData() async {
    try {
      if (mark == null) {
        Fluttertoast.showToast(msg: 'mark status as not selected'.tr());
        return;
      }
      if (mark == 'interview') {
        DateTime dateTime = DateTime(dateSend!.year, dateSend!.month,
            dateSend!.day, timeSend!.hour, timeSend!.minute);
        if (dateTime.difference(DateTime.now()).inHours < 1) {
          Fluttertoast.showToast(
              msg: 'the interview schedule is too soon'.tr());
          _btnSendController.reset();
          return;
        }
      }

      var html = DeltaToHTML.encodeJson(
        quillController.document.toDelta().toJson(),
      );

      if (!mounted) return;
      BlocProvider.of<PostDataCubit>(context)
          .patchApplicants(
              id: data!.id,
              applicantId: data!.applicant!.id,
              vacancyId: data!.vacancy!.id,
              desc: data!.desc,
              status: mark!,
              interviewdate: DateFormat('yyyy-MM-dd').format(dateSend!),
              interviewtime: DateFormat('HH:mm:ss').format(DateTime(
                  dateSend!.year,
                  dateSend!.month,
                  dateSend!.day,
                  timeSend!.hour,
                  timeSend!.minute)),
              message: html)
          .then((value) {
        if (value) {
          showButtomSheetInfo(success: value);
        } else {
          showButtomSheetInfo(success: value);
        }
      });
      _btnSendController.reset();
    } catch (_) {
      _btnSendController.reset();
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
                    success ? 'successfull desc'.tr() : 'oop, failed desc'.tr(),
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
        title: Text(
          'applicants'.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Scrollbar(
        radius: const Radius.circular(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 83,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
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
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 72,
                        width: MediaQuery.of(context).size.width / 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                "${Config.baseUrl}/${Config.imageEmployee}/${data!.applicant!.photo ?? ''}",
                            placeholder: (context, url) => const Center(
                                child: LoadingWidget(
                              fallingDot: true,
                            )),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/icons/logo-empty.png',
                              height: MediaQuery.of(context).size.height / 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              data!.applicant!.fullname!,
                              maxLines: 2,
                              minFontSize: 13.0,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.6),
                                  fontWeight: FontWeight.w800),
                            ),
                            AutoSizeText(
                              data!.applicant!.skill!,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.6),
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: "applying for".tr(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                TextSpan(
                                  text: '${data!.vacancy!.title}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: data!.desc != '',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Text(
                          'description'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 4.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).primaryIconTheme.color!,
                            ),
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Html(
                          data: data!.desc ?? '--',
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                    onPressed: () => Navigator.pushNamed(
                        context, '/pdf-view', arguments: {
                      'pdf': '${Config.baseUrl}/${Config.resume}/${data!.cv}',
                      'asset': false
                    }),
                    child: Text(
                      'see resume'.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => showButtomSheetMark(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: getColor(mark), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mark == null ? 'mark status as'.tr() : labelmark!,
                          style: TextStyle(
                              color: getColor(mark),
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.expand_more_rounded, color: getColor(mark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const Divider(
                  height: 1,
                ),
                Visibility(
                  visible: mark == 'interview',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => _selectDate(context),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                  color:
                                      Theme.of(context).primaryIconTheme.color!,
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  labelDate!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.calendar_month,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => selectedTime24Hour(context),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                  color:
                                      Theme.of(context).primaryIconTheme.color!,
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  labelTime!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.schedule,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "message".tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ]),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: RoundedLoadingButton(
          animateOnTap: true,
          errorColor: Colors.red.shade200,
          controller: _btnSendController,
          onPressed: data!.status == 'rejected' || data!.status == 'accepted'
              ? null
              : () => sendData(),
          disabledColor: Theme.of(context).colorScheme.primary.withOpacity(.6),
          borderRadius: 22,
          elevation: 0,
          color: Theme.of(context).primaryColor,
          height: kToolbarHeight - 12,
          width: MediaQuery.of(context).size.width,
          child: Text(
            'send to applicants'.tr(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Color getColor(status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade800;
      case 'rejected':
        return Colors.red.shade800;
      case 'interview':
        return Colors.blue.shade800;
      default:
        return Theme.of(context).primaryIconTheme.color!;
    }
  }

  void showButtomSheetMark() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Container(
            color: Theme.of(context).primaryColor.withOpacity(.01),
            child: Column(
              children: [
                data!.status == 'interview'
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            mark = 'interview';
                            labelmark = 'interview'.tr();
                          });
                        },
                        child: buildListItem(
                          context,
                          title: Text('Interview',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.7))),
                          leading: Icon(Icons.translate,
                              color: Theme.of(context).primaryColor),
                          trailing: mark == 'interview'
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.green.shade600,
                                )
                              : SizedBox.fromSize(),
                        ),
                      ),
                Divider(
                  height: .5,
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      mark = 'accepted';
                      labelmark = 'accepted'.tr();
                    });
                  },
                  child: buildListItem(
                    context,
                    title: Text('accepted'.tr()),
                    leading: Icon(Icons.check,
                        color: Theme.of(context).primaryColor),
                    trailing: mark == 'accepted'
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.green.shade600,
                          )
                        : SizedBox.fromSize(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      mark = 'rejected';
                      labelmark = 'rejected'.tr();
                    });
                  },
                  child: buildListItem(
                    context,
                    title: Text('rejected'.tr()),
                    leading: Icon(Icons.close, color: Colors.red.shade500),
                    trailing: mark == 'rejected'
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.green.shade600,
                          )
                        : SizedBox.fromSize(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
