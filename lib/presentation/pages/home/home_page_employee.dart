import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/core/widgets/vacancy.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/recommendations/recommendation_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:lottie/lottie.dart';

import 'widgets/employee/widget_categories.dart';
import 'widgets/employee/widget_tips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textSearchController = TextEditingController();

  late StreamSubscription<RecommendationState> streamVacancies;

  //Vancacies
  List<ResultVacanciesEntity> vacancies = [];
  bool isLastPage = false;
  bool _isLoading = false;
  bool nextPage = false;
  int page = 1;
  String params = '&status[equals]=active';

  @override
  void initState() {
    var jobcategory =
        context.read<UserCubit>().user!.employeeProfile!.jobcategories!;
    var paramrecommend = [];
    for (var e in jobcategory) {
      paramrecommend.add('categoryId[in]=${e.categoryId}');
    }
    Config.recommended = paramrecommend.join('&');
    getrecommendations();
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

  void getrecommendations() async {
    vacancies.clear();
    Config.params = '';
    setState(() {
      isLastPage = false;
      page = 1;
    });

    if (!mounted) return;

    context
        .read<RecommendationCubit>()
        .recommendations(page, '$params&${Config.recommended}');

    streamVacancies =
        context.read<RecommendationCubit>().stream.listen((event) {
      if (!mounted) return;

      if (Config.isChangeTab && !_isLoading) {
        vacancies.clear();
      }

      if (event is RecommendationLoaded) {
        if (vacancies.isEmpty) {
          page = 1;
          isLastPage = false;
        }

        for (var e in event.vacancies.data) {
          if (vacancies.where((x) => x.id == e.id).isEmpty) {
            vacancies.add(ResultVacanciesEntity(
                id: e.id,
                title: e.title,
                category: e.category,
                status: e.status,
                location: e.location,
                desc: e.desc,
                requirement: e.requirement,
                salary: e.salary,
                typevacancy: e.typevacancy,
                userCompany: e.userCompany,
                image: e.image,
                createdAt: e.createdAt,
                bookmarks: false,
                verify: e.verify,
                application: e.application));
          }
        }

        if (event.vacancies.data.isEmpty) {
          isLastPage = true;
        } else {
          isLastPage = false;
        }
      }
    });
  }

  Future<void> onLoadmore() async {
    if (!mounted) return;
    if (Config.params == '') {
      await context.read<RecommendationCubit>().recommendations(page, params);
    } else {
      await context
          .read<RecommendationCubit>()
          .recommendations(page, '$params&${Config.params}');
    }
  }

  @override
  void dispose() {
    streamVacancies.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
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
            borderRadius: BorderRadius.circular(50.0),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  "${Config.baseUrl}/${Config.imageEmployee}/${context.read<UserCubit>().user!.employeeProfile!.photo ?? ''}",
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
              context.read<UserCubit>().user!.employeeProfile!.fullname ?? '',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            )
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
                    Navigator.pushNamed(context, '/notification-employee'),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryIconTheme.color!.withOpacity(.1),
                  radius: 36,
                  child: Icon(Icons.notifications_none_rounded,
                      color: Theme.of(context).primaryIconTheme.color),
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
              height: 310,
              child: Column(
                children: [
                  TextFieldCustom(
                    controller: _textSearchController,
                    placeholder: 'search'.tr(),
                    readOnly: true,
                    prefixIcon: const Icon(Icons.search),
                    onSubmitted: () => Navigator.pushNamed(
                        context, '/vacancies', arguments: {
                      'title': "job search".tr(),
                      'isSearch': true
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'tips for you'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/tips'),
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
                  const WidgetTips(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: kToolbarHeight * 1.5,
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
                          'recommendations'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/vacancies',
                                arguments: {
                                  'title': "recommendations".tr(),
                                  'isSearch': false
                                });
                          },
                          child: Row(
                            children: [
                              Text(
                                'see all'.tr(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
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
                  Container(
                    height: 32,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    child: const WidgetCategories(),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<RecommendationCubit, RecommendationState>(
            builder: (context, state) {
              if ((state is RecommendationLoading ||
                      state is RecommendationInitial) &&
                  !_isLoading) {
                return SliverFixedExtentList(
                  itemExtent: 110,
                  delegate: SliverChildBuilderDelegate(
                    childCount: 5,
                    (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: ShimmerWidget(
                          height: 110,
                          width: MediaQuery.of(context).size.width,
                        ),
                      );
                    },
                  ),
                );
              } else {
                if (vacancies.isEmpty && !_isLoading) {
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
                  itemExtent: 110,
                  delegate: SliverChildBuilderDelegate(
                    childCount: vacancies.length + 1,
                    (BuildContext context, int index) {
                      if (index == vacancies.length) {
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
                                        text: TextSpan(
                                          children: [
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
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.fromSize();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, '/vacancy',
                              arguments: {
                                'vacancy': vacancies[index],
                                'employee': true
                              }),
                          child: WidgetVacancyContainer(
                            data: vacancies[index],
                            employee: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
