import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/applicant.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/presentation/bloc/applicants/applicants_cubit.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class WidgetDetailApplicantEmployee extends StatefulWidget {
  const WidgetDetailApplicantEmployee({super.key});

  @override
  State<WidgetDetailApplicantEmployee> createState() =>
      _WidgetDetailApplicantEmployeeState();
}

class _WidgetDetailApplicantEmployeeState
    extends State<WidgetDetailApplicantEmployee> {
  late StreamSubscription<ApplicantsState> stream;
  String? id;
  ResultApplicantsEntity? data;

  final RoundedLoadingButtonController _btnSubmitController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    streamApplication();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    id = ModalRoute.of(context)!.settings.arguments as String;
    context.read<ApplicantsCubit>().getApplicationFindOne(id!);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    stream.cancel();
    _btnSubmitController.reset();
    super.dispose();
  }

  void streamApplication() {
    if (!mounted) return;

    stream = context.read<ApplicantsCubit>().stream.listen((event) {
      if (event is ApplicantionFindOneLoaded) {
        data = event.applicant;
      }
    });
  }

  void joinInterview() {
    try {
      context
          .read<PostDataCubit>()
          .joinInterview(id: data!.id, join: true)
          .then((value) {
        if (value) {
          if (!mounted) return;
          Navigator.pop(context, value);
        } else {
          Fluttertoast.showToast(msg: 'try again'.tr());
          _btnSubmitController.reset();
          return;
        }
      });
    } catch (_) {
      _btnSubmitController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              color: Theme.of(context).primaryColor.withOpacity(.1),
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        title: const Text(
          'Applications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ApplicantsCubit, ApplicantsState>(
          builder: (context, state) {
        if (state is ApplicantsLoading || state is ApplicantsInitial) {
          return Container(
            height: MediaQuery.of(context).size.height - 162,
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: const LoadingWidget(),
          );
        } else if (state is ApplicantionFindOneLoaded) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetApplicantContainer(
                          data: data!,
                          employee: true,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        const Divider(
                          height: 1,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        infowidget(
                          context,
                          attr: 'salary'.tr(),
                          value: data!.vacancy!.salary == '0'
                              ? 'not mentioned'.tr()
                              : Config()
                                  .number
                                  .format(int.tryParse(data!.vacancy!.salary!)),
                        ),
                        infowidget(context,
                            attr: 'type job'.tr(),
                            value: data!.vacancy!.typevacancy),
                        infowidget(context,
                            attr: 'location'.tr(),
                            value: data!.vacancy!.location),
                        const SizedBox(
                          height: 12.0,
                        ),
                        const Divider(
                          height: 1,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        data!.status == 'interview'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      'scheduled to interview'.tr(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  infowidget(context,
                                      attr: 'date'.tr(),
                                      value: DateFormat('E, dd MMM yyyy')
                                          .format(DateTime.parse(
                                              data!.interviewdate!))),
                                  infowidget(
                                    context,
                                    attr: 'time'.tr(),
                                    value: DateFormat('HH:mm').format(DateTime(
                                        dateTime.year,
                                        dateTime.month,
                                        dateTime.day,
                                        int.parse(data!.interviewtime!
                                            .substring(0, 2)),
                                        int.parse(data!.interviewtime!
                                            .substring(3, 5)))),
                                  ),
                                  const SizedBox(
                                    height: 12.0,
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  const SizedBox(
                                    height: 12.0,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        data!.status == 'pending'
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height / 4,
                                child: Center(
                                  child: Text(
                                    'waiting for review'.tr(),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(.2)),
                                  ),
                                ),
                              )
                            : Html(
                                data: data!.message ?? '',
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
                                          .withOpacity(.8)),
                                  'ol': Style(
                                      padding: HtmlPaddings.only(left: 16.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(.8))
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: data == null
                      ? const SizedBox.shrink()
                      : Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 12.0,
                          ),
                          child: RoundedLoadingButton(
                            animateOnTap: true,
                            errorColor: Colors.red.shade200,
                            controller: _btnSubmitController,
                            onPressed: data!.joininterview!
                                ? null
                                : data!.status == 'pending'
                                    ? null
                                    : () {
                                        if (data!.status == 'interview') {
                                          joinInterview();
                                        }
                                      },
                            borderRadius: 22,
                            elevation: 0,
                            color: Theme.of(context).primaryColor,
                            height: kToolbarHeight - 12,
                            width: MediaQuery.of(context).size.width - 24,
                            child: Text(
                              infoText(status: '${data!.status}'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                )
              ],
            ),
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height - 162,
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/notfound.json',
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height / 4),
                Text(
                  'page not found'.tr(),
                  style: TextStyle(color: Theme.of(context).disabledColor),
                )
              ],
            ),
          );
        }
      }),
    );
  }

  String infoText({String? status}) {
    switch (status) {
      case 'pending':
        return 'waiting for review'.tr();
      case 'rejected':
        return 'discover another job'.tr();
      case 'accepted':
        return 'send message to recruiter now'.tr();
      default:
        return 'join interview'.tr();
    }
  }

  Widget infowidget(context, {String? attr, String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            attr!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          Text(
            value!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
