import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/applicant.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/presentation/bloc/applicants/applicants_cubit.dart';
import 'package:jobless/presentation/bloc/bell/bell_cubit.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:jobless/presentation/pages/home/widgets/employers/widget_vacancies.dart';
import 'package:lottie/lottie.dart';
import 'package:jobless/injection_container.dart' as di;

class HomeEmployersPage extends StatefulWidget {
  const HomeEmployersPage({super.key});

  @override
  State<HomeEmployersPage> createState() => _HomeEmployersPageState();
}

class _HomeEmployersPageState extends State<HomeEmployersPage> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<ApplicantsState> stream;

  //Vancacies
  List<ResultApplicantsEntity> applicants = [];
  bool isLastPage = false;
  bool _isLoading = false;
  int page = 1;
  String params = '';

  @override
  void initState() {
    getMyVacancies();
    getApplicantsByMyVacancy();
    _scrollController.addListener(() async {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        context.read<HideNavBarCubit>().updateNavBar(true);
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        context.read<HideNavBarCubit>().updateNavBar(false);
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.idle) {
        context.read<HideNavBarCubit>().updateNavBar(false);
      }
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
            Config.isChangeTab = false;
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
    super.dispose();
  }

  void getMyVacancies() async {
    await context.read<VacanciesCubit>().getvacancies(
        1, '&userId[equals]=${context.read<UserCubit>().user!.id}');
  }

  void getApplicantsByMyVacancy() async {
    applicants.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    if (!mounted) return;

    context.read<ApplicantsCubit>().getapplicantsByMyVacancy(page, params);
    stream = context.read<ApplicantsCubit>().stream.listen((event) {
      if (event is ApplicantsLoaded) {
        for (var e in event.applicants.data) {
          applicants.add(ResultApplicantsEntity(
              id: e.id,
              applicant: e.applicant,
              vacancy: e.vacancy,
              cv: e.cv,
              desc: e.desc,
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
    await context
        .read<ApplicantsCubit>()
        .getapplicantsByMyVacancy(page, params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 6,
        leading: Container(
          width: 44,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            // add border
            border: Border.all(
              width: 3,
              color: Theme.of(context).primaryColor.withOpacity(.5),
            ),
            // set border radius
            borderRadius: BorderRadius.circular(52),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  "${Config.baseUrl}/${Config.imageEmployers}/${context.read<UserCubit>().user!.employersProfile!.photo ?? ''}",
              placeholder: (context, url) => const Center(
                  child: LoadingWidget(
                fallingDot: true,
              )),
              errorWidget: (context, url, error) => context.select(
                      (ThemeCubit themeCubit) =>
                          themeCubit.state.themeMode == ThemeMode.dark)
                  ? SvgPicture.asset(
                      'assets/icons/jobless.svg',
                      height: 62,
                    )
                  : SvgPicture.asset(
                      'assets/icons/jobless_dark.svg',
                      height: 62,
                    ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hallo',
              style: TextStyle(fontSize: 12.0),
            ),
            Text(
              context.read<UserCubit>().user!.employersProfile!.companyname ??
                  '',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: 38,
              backgroundColor:
                  Theme.of(context).primaryIconTheme.color!.withOpacity(.1),
              child: InkWell(
                highlightColor: Colors.transparent,
                onTap: () =>
                    Navigator.pushNamed(context, '/notification-employers'),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryIconTheme.color!.withOpacity(.1),
                  radius: 36,
                  child: BlocProvider(
                    create: (context) => di.getIt<BellCubit>()..initialBell(),
                    child: BlocBuilder<BellCubit, BellState>(
                      builder: (context, state) {
                        if (state.bell) {
                          return Lottie.asset('assets/lottie/bell.json',
                              fit: BoxFit.cover, width: 38);
                        } else {
                          return Icon(Icons.notifications_none_rounded,
                              color: Theme.of(context).primaryIconTheme.color);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              height: 284,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'my vacancies'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                            onPressed: () => context
                                .read<NavigationCubit>()
                                .getNavBarItem(1),
                            child: Row(
                              children: [
                                Text(
                                  'see all'.tr(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(.4),
                    child: const WidgetVacancies(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    margin: const EdgeInsets.all(12.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Theme.of(context).primaryIconTheme.color),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'interview timetable'.tr(),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 152,
                              child: AutoSizeText(
                                'interview timetable list'.tr(),
                                minFontSize: 10,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 80,
                          child: IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/schedule'),
                            icon: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 4.0),
                                color: Theme.of(context).colorScheme.onPrimary,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'recent people applied'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/applicants'),
                    child: Row(
                      children: [
                        Text(
                          'see all'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).primaryIconTheme.color,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          BlocBuilder<ApplicantsCubit, ApplicantsState>(
            builder: (context, state) {
              if ((state is ApplicantsLoading || state is ApplicantsInitial) &&
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
