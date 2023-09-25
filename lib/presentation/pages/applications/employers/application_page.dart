import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/core/widgets/vacancy.dart';
import 'package:jobless/data/model/chips.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:jobless/presentation/pages/applications/employers/widgets/widget_create_vacancy.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ApplicationEmployersPage extends StatefulWidget {
  const ApplicationEmployersPage({super.key});

  @override
  State<ApplicationEmployersPage> createState() =>
      _ApplicationEmployersPageState();
}

class _ApplicationEmployersPageState extends State<ApplicationEmployersPage> {
  late StreamSubscription<VacanciesState> stream;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnApplyController =
      RoundedLoadingButtonController();

  List<ChipsModel> chipsModel = [];
  List<ResultVacanciesEntity> myVacancies = [];
  int page = 1;
  String params = '';
  bool isLastPage = false;
  bool _isLoading = false;

  @override
  void initState() {
    chipsModel.add(ChipsModel(true, 'all', 'all vacancies'.tr()));
    chipsModel.add(ChipsModel(false, 'active', 'active'.tr()));
    chipsModel.add(ChipsModel(false, 'inactive', 'inactive'.tr()));
    getMyvacancies();
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
    _scrollController.dispose();
    _textSearchController.dispose();
    super.dispose();
  }

  void getMyvacancies() async {
    myVacancies.clear();
    params = '&userId[equals]=${context.read<UserCubit>().user!.id}';
    setState(() {
      isLastPage = false;
      page = 1;
      _isLoading = false;
    });

    if (!mounted) return;

    context.read<VacanciesCubit>().getvacancies(page, params);
    stream = context.read<VacanciesCubit>().stream.listen((event) {
      if (Config.isChangeTab && !_isLoading) {
        myVacancies.clear();
      }

      if (event is VacanciesLoaded) {
        if (myVacancies.isEmpty) {
          page = 1;
          isLastPage = false;
        }

        for (var e in event.vacancies.data) {
          myVacancies.add(ResultVacanciesEntity(
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
              application: e.application));
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
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (Config.params == '') {
      await context.read<VacanciesCubit>().getvacancies(page, params);
    } else {
      await context
          .read<VacanciesCubit>()
          .getvacancies(page, '$params&${Config.params}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: context.select((ThemeCubit themeCubit) =>
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
        title: Text(
          'my vacancies'.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const WidgetCreateVacancy(),
                  ),
                );

                if (res != null && res is bool) {
                  if (!mounted) return;
                  context.read<VacanciesCubit>().getvacancies(page, params);
                }
              },
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                  child: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
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
              height: 122,
              child: Column(
                children: [
                  TextFieldCustom(
                    controller: _textSearchController,
                    placeholder: 'search vacancies'.tr(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: 56,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: List.generate(
                        chipsModel.length,
                        (index) => chips(
                            title: chipsModel[index].text,
                            selected: chipsModel[index].isSelected,
                            i: index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<VacanciesCubit, VacanciesState>(
            builder: (context, state) {
              if ((state is VacanciesLoading || state is VacanciesInitial) &&
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
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                        ),
                      );
                    },
                  ),
                );
              } else {
                if (myVacancies.isEmpty && !_isLoading) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 222,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/job.png',
                                    height: 180,
                                  ),
                                  Text(
                                    'no results found'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  const SizedBox(
                                    height: 12.0,
                                  ),
                                  Text(
                                    'create a job vacancy'.tr(),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              child: RoundedLoadingButton(
                                animateOnTap: false,
                                errorColor: Colors.red.shade200,
                                controller: _btnApplyController,
                                onPressed: () async {
                                  if (!context.mounted) return;

                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                          const WidgetCreateVacancy(),
                                    ),
                                  );
                                },
                                borderRadius: 22,
                                elevation: 0,
                                color: Theme.of(context).primaryColor,
                                height: kToolbarHeight - 12,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'create vacancy now'.tr(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 80.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return widgetVacancies();
              }
            },
          )
        ],
      ),
    );
  }

  Widget widgetVacancies() {
    return SliverFixedExtentList(
        itemExtent: 110,
        delegate: SliverChildBuilderDelegate(
          childCount: myVacancies.length + 1,
          (BuildContext context, int index) {
            if (index == myVacancies.length) {
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
                                  color: Theme.of(context).disabledColor,
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
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                onTap: () async {
                  final res = await Navigator.pushNamed(context, '/vacancy',
                      arguments: {
                        'vacancy': myVacancies[index],
                        'employee': false
                      });
                  if (res != null && res is bool) {
                    setState(() {
                      myVacancies[index] = ResultVacanciesEntity(
                        id: myVacancies[index].id,
                        title: myVacancies[index].title,
                        category: myVacancies[index].category,
                        status: 'inactive',
                        location: myVacancies[index].location,
                        desc: myVacancies[index].desc,
                        requirement: myVacancies[index].requirement,
                        salary: myVacancies[index].salary,
                        typevacancy: myVacancies[index].typevacancy,
                        userCompany: myVacancies[index].userCompany,
                        image: myVacancies[index].image,
                        createdAt: myVacancies[index].createdAt,
                        application: myVacancies[index].application,
                      );
                    });
                  }
                },
                child: WidgetVacancyContainer(
                  data: myVacancies[index],
                  employee: false,
                ),
              ),
            );
          },
        ));
  }

  Widget chips({String? title, bool? selected, int? i}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(
          title!,
          style: TextStyle(
              color: selected!
                  ? Colors.white
                  : Theme.of(context).primaryIconTheme.color),
        ),
        selectedColor: Theme.of(context).primaryColor,
        backgroundColor:
            selected ? Theme.of(context).primaryColor : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
        onSelected: (bool value) async {
          setState(() {
            Config.isChangeTab = true;
            page = 1;
            for (var element in chipsModel) {
              element.isSelected = false;
            }
            chipsModel[i!].isSelected = true;
          });
          if (!mounted) return;
          context.read<HideNavBarCubit>().updateNavBar(false);
          if (chipsModel[i!].options == 'all') {
            Config.params = '';
            context.read<VacanciesCubit>().getvacancies(page, params);
          } else {
            Config.params = 'status=${chipsModel[i].options}';
            context
                .read<VacanciesCubit>()
                .getvacancies(page, '$params&${Config.params}');
          }
        },
      ),
    );
  }
}
