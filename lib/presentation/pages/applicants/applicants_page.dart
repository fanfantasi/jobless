import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/applicant.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/presentation/bloc/schedule/schedule_cubit.dart';
import 'package:lottie/lottie.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final _calendarControllerToday = AdvancedCalendarController.today();
  final ScrollController _scrollController = ScrollController();
  final eventsAppliants = <DateTime>[];

  //Applications
  late StreamSubscription<ScheduleState> stream;
  List<ResultApplicantsEntity> applicants = [];
  bool isLastPage = false;
  bool nextPage = false;
  bool _isLoading = false;
  int page = 1;
  String params = '';

  String dragCalendar = '';

  @override
  void initState() {
    params =
        '&date[contains]=${DateFormat('yyyy-MM-dd').format(_calendarControllerToday.value)}';
    getApplicantsByMyVacancy();
    dragCalendar = DateFormat('yyyy-MM').format(_calendarControllerToday.value);

    _calendarControllerToday.addListener(() {
      applicants.clear();
      var date =
          DateFormat('yyyy-MM-dd').format(_calendarControllerToday.value);
      params = '&date[contains]=$date';
      context.read<ScheduleCubit>().getapplicants(page, params);
    });
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        if (_isLoading) {
          return;
        }

        setState(() {
          _isLoading = true;
        });

        if (!isLastPage) {
          setState(() {
            page += 1;
          });
          await onLoadmore();
        }

        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    eventsAppliants.clear();
    _scrollController.dispose();
    _calendarControllerToday.dispose();
    super.dispose();
  }

  void getApplicantsByMyVacancy() async {
    applicants.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    if (!mounted) return;
    context.read<ScheduleCubit>().getCalendar('?date[contains]=$dragCalendar');

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<ScheduleCubit>().getapplicants(page, params);
    stream = context.read<ScheduleCubit>().stream.listen((event) {
      if (event is ScheduleApplicantsLoaded) {
        for (var e in event.applicants.data) {
          applicants.add(ResultApplicantsEntity(
              id: e.id,
              applicant: e.applicant,
              vacancy: e.vacancy,
              cv: e.cv,
              desc: e.desc,
              date: e.date,
              status: e.status,
              interviewdate: e.interviewdate,
              interviewtime: e.interviewtime,
              message: e.message,
              joininterview: e.joininterview,
              createdAt: e.createdAt,
              updatedAt: e.updatedAt));
        }
        if (event.applicants.data.isEmpty) {
          isLastPage = true;
        } else {
          isLastPage = false;
        }
      }
    });
  }

  Future<void> onLoadmore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await context.read<ScheduleCubit>().getapplicants(page, params);
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
          'applicants'.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 18.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(1, 1), // changes position of shadow
                  ),
                ],
              ),
              child: BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoaded) {
                    eventsAppliants.clear();
                    for (var e in state.schedule.dates) {
                      eventsAppliants.add(DateTime.parse(e));
                    }

                    return AdvancedCalendar(
                      headerStyle: TextStyle(
                          color: Theme.of(context).primaryIconTheme.color),
                      todayStyle: TextStyle(
                          color: Theme.of(context).primaryIconTheme.color),
                      controller: _calendarControllerToday,
                      events: eventsAppliants,
                      onHorizontalDrag: (p0) {
                        if (dragCalendar != DateFormat('yyyy-MM').format(p0)) {
                          dragCalendar = DateFormat('yyyy-MM').format(p0);
                          Future.delayed(const Duration(milliseconds: 600), () {
                            context
                                .read<ScheduleCubit>()
                                .getCalendar('?date[contains]=$dragCalendar');
                          });
                        }
                      },
                      innerDot: true,
                      startWeekDay: 1,
                    );
                  } else {
                    return AdvancedCalendar(
                      headerStyle: TextStyle(
                          color: Theme.of(context).primaryIconTheme.color),
                      todayStyle: TextStyle(
                          color: Theme.of(context).primaryIconTheme.color),
                      controller: _calendarControllerToday,
                      events: eventsAppliants,
                      innerDot: true,
                      startWeekDay: 1,
                    );
                  }
                },
              ),
            ),
          ),
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              if ((state is ScheduleLoading || state is ScheduleInitial) &&
                  !_isLoading) {
                return SliverFixedExtentList(
                  itemExtent: 180,
                  delegate: SliverChildBuilderDelegate(
                    childCount: 5,
                    (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: ShimmerWidget(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                        ),
                      );
                    },
                  ),
                );
              } else {
                if (applicants.isEmpty && !_isLoading) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Lottie.asset('assets/lottie/searchempty.json',
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 4),
                          Text(
                            'no results found'.tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).disabledColor),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return SliverFixedExtentList(
                  itemExtent: 180,
                  delegate: SliverChildBuilderDelegate(
                    childCount: applicants.length + 1,
                    (BuildContext context, int index) {
                      if (index == applicants.length) {
                        return _isLoading
                            ? const LoadingWidget()
                            : isLastPage
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          'no more data'.tr(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12.0,
                                      ),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Powered By ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withOpacity(.5),
                                            )),
                                        TextSpan(
                                            text: 'Programmer Junior',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(.5),
                                            ))
                                      ])),
                                    ],
                                  )
                                : SizedBox.fromSize();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: InkWell(
                          onTap: () async {
                            final res = await Navigator.pushNamed(
                                context, '/app-employers-detail',
                                arguments: applicants[index]);
                            if (res != null && res as bool) {
                              setState(() {
                                // isLastPage = false;
                                // page = 1;
                                applicants.removeAt(index);
                              });

                              // if (!mounted) return;

                              // BlocProvider.of<ApplicantsCubit>(context)
                              //     .getapplicantsByMyVacancy(page, params);
                            }
                          },
                          child: WidgetApplicantContainer(
                              data: applicants[index],
                              employee: false,
                              onPressedResume: () => Navigator.pushNamed(
                                      context, '/pdf-view',
                                      arguments: {
                                        'pdf':
                                            '${Config.baseUrl}/${Config.resume}/${applicants[index].cv}',
                                        'asset': false
                                      }),
                              onPressedDetail: () async {
                                final res = await Navigator.pushNamed(
                                    context, '/app-employers-detail',
                                    arguments: applicants[index]);
                                if (res != null && res as bool) {
                                  setState(() {
                                    // isLastPage = false;
                                    // page = 1;
                                    applicants.removeAt(index);
                                  });

                                  // if (!mounted) return;

                                  // BlocProvider.of<ApplicantsCubit>(context)
                                  //     .getapplicantsByMyVacancy(page, params);
                                }
                              }),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
