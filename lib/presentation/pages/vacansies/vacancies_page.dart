import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/popover.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/core/widgets/vacancy.dart';
import 'package:jobless/data/model/categories.dart';
import 'package:jobless/data/model/location.dart';
import 'package:jobless/data/model/typevacancy.dart';
import 'package:jobless/domain/entities/categories_entity.dart';
import 'package:jobless/domain/entities/location_entity.dart';
import 'package:jobless/domain/entities/typevacancy_entity.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';
import 'package:jobless/presentation/bloc/typevacancy/typevacancy_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:lottie/lottie.dart';

class VacanciesPage extends StatefulWidget {
  const VacanciesPage({super.key});

  @override
  State<VacanciesPage> createState() => _VacanciesPageState();
}

class _VacanciesPageState extends State<VacanciesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textSearchController = TextEditingController();
  String? title;
  bool? isSearch;
  Timer? _debounce;

  late StreamSubscription<VacanciesState> stream;
  late StreamSubscription<CategoriesState> streamCategory;
  late StreamSubscription<TypeVacancyState> streamType;
  late StreamSubscription<LocationState> streamLocation;

  //Categories
  List<ResultCategoriesModel> resultCategori = [];
  List<ResultTypeVacancyEntity> resultType = [];
  List<ResultLocationEntity> resultLocation = [];

  //Vancacies
  List<ResultVacanciesEntity> vacancies = [];
  bool _isSearch = false;
  bool isLastPage = false;
  bool _isLoading = false;
  int page = 1;
  String params = '&status[equals]=active';

  @override
  void initState() {
    Config.params = '';

    streamVacancies();
    streamFilter();
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
  void didChangeDependencies() async {
    var map = ModalRoute.of(context)!.settings.arguments as Map;
    title = map['title'];
    isSearch = map['isSearch'];
    //
    getVacancies();
    super.didChangeDependencies();
  }

  void getVacancies() async {
    if (!isSearch!) {
      await context
          .read<VacanciesCubit>()
          .getvacancies(1, '$params&${Config.recommended}');
    }
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query == '') {
        vacancies.clear();
        setState(() {
          _isSearch = false;
          _isLoading = false;
        });
      } else {
        vacancies.clear();
        setState(() {
          _isSearch = true;
          isLastPage = false;
          page = 1;
          _isLoading = false;
        });
        context.read<VacanciesCubit>().getvacancies(
            page, '$params&${Config.params}&title[contains]=$query');
      }
    });
  }

  void streamVacancies() async {
    if (!mounted) return;
    stream = context.read<VacanciesCubit>().stream.listen((event) {
      if (page == 1) {
        vacancies.clear();
      }

      if (event is VacanciesLoaded) {
        if (vacancies.isEmpty) {
          page = 1;
          isLastPage = false;
        }

        for (var e in event.vacancies.data) {
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
              verify: e.verify,
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

  @override
  void dispose() {
    stream.cancel();
    streamCategory.cancel();
    streamType.cancel();
    streamLocation.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> onLoadmore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await context.read<VacanciesCubit>().getvacancies(page, params);
  }

  void streamFilter() async {
    if (!mounted) return;
    //Category
    streamCategory = context.read<CategoriesCubit>().stream.listen((event) {
      if (resultCategori.isNotEmpty) {
        return;
      }
      resultCategori.clear();
      if (event is CategoriesLoaded) {
        for (var e in event.categories.data) {
          resultCategori.add(ResultCategoriesModel.fromJSON(
              {'id': e.id, 'category': e.category, 'checked': e.checked}));
        }
        resultCategori.sort((a, b) => a.id!.compareTo(b.id!));
      }
    });
    //Type
    streamType = context.read<TypeVacancyCubit>().stream.listen((event) {
      resultType.clear();
      if (event is TypeVacancyLoaded) {
        for (var e in event.typevacancy.data) {
          resultType.add(ResultTypeVacancyModel.fromJSON(
              {'id': e.id, 'type': e.type, 'checked': e.checked}));
        }
        resultType.sort((a, b) => a.id!.compareTo(b.id!));
      }
    });
    //Location
    streamLocation = context.read<LocationCubit>().stream.listen((event) {
      if (resultLocation.isNotEmpty) {
        return;
      }
      resultLocation.clear();
      if (event is LocationLoaded) {
        for (var e in event.location.data) {
          resultLocation.add(ResultLocationModel.fromJSON(
              {'id': e.id, 'location': e.location, 'checked': e.checked}));
        }
        resultLocation.sort((a, b) => a.id!.compareTo(b.id!));
      }
    });
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
          title!,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextFieldCustom(
                    controller: _textSearchController,
                    placeholder: 'search vacancies'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    onChange: _onSearchChanged,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 46,
                  height: 46,
                  child: InkWell(
                    onTap: () {
                      showButtomSheetFilter();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (resultCategori.isEmpty) {
                          context
                              .read<CategoriesCubit>()
                              .getcategories(1, 5, '');
                        }
                        if (resultType.isEmpty) {
                          context
                              .read<TypeVacancyCubit>()
                              .gettypevacancy(1, 10, '');
                        }

                        if (resultLocation.isEmpty) {
                          context.read<LocationCubit>().getLocation(1, 10, '');
                        }
                      });
                    },
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        child: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<VacanciesCubit, VacanciesState>(
            builder: (_, state) {
              if ((state is VacanciesLoading) && !_isLoading) {
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
              } else if (state is VacanciesInitial) {
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
                          'initial job search'.tr(),
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                if (vacancies.isEmpty && !_isLoading) {
                  return SliverToBoxAdapter(
                    child: Padding(
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
                            _isSearch
                                ? 'no results found'.tr()
                                : 'initial job search'.tr(),
                            style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  void showButtomSheetFilter() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: DraggableScrollableSheet(
              initialChildSize: .7,
              maxChildSize: 1,
              minChildSize: .7,
              builder: (context, ScrollController scrollController) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) {
                  return Popover(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'search filter'.tr(),
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    var paramFilter = [];
                                    for (var e in resultCategori) {
                                      if (e.checked!) {
                                        paramFilter.add(
                                            'categoryId[in]=${e.id!.toLowerCase()}');
                                      }
                                    }
                                    for (var e in resultType) {
                                      if (e.checked!) {
                                        paramFilter.add(
                                            'typevacancyId[in]=${e.id!.toLowerCase()}');
                                      }
                                    }
                                    for (var e in resultLocation) {
                                      if (e.checked!) {
                                        paramFilter.add(
                                            'locationId[in]=${e.id!.toLowerCase()}');
                                      }
                                    }
                                    Config.params = paramFilter.isEmpty
                                        ? ''
                                        : paramFilter.join('&');
                                    page = 1;
                                    Future.delayed(
                                        const Duration(milliseconds: 200), () {
                                      context
                                          .read<VacanciesCubit>()
                                          .getvacancies(
                                              page, '$params&${Config.params}');
                                    });
                                  },
                                  child: Text(
                                    'apply filter'.tr(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'field of work'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final res = await Navigator.pushNamed(
                                        context, '/categories');
                                    if (res != null &&
                                        res is ResultCategoriesEntity) {
                                      final idx = resultCategori
                                          .indexWhere((e) => e.id == res.id);
                                      if (idx != -1) {
                                        setState(() {
                                          resultCategori[idx] =
                                              ResultCategoriesModel.fromJSON({
                                            'id': resultCategori[idx].id,
                                            'category':
                                                resultCategori[idx].category,
                                            'checked': true
                                          });
                                        });
                                      } else {
                                        for (var i = 0;
                                            i < resultCategori.length;
                                            i++) {
                                          if (resultCategori[i].checked ==
                                              false) {
                                            setState(() {
                                              resultCategori[i] =
                                                  ResultCategoriesModel
                                                      .fromJSON({
                                                'id': res.id,
                                                'category': res.category,
                                                'checked': true
                                              });
                                            });
                                            return;
                                          }
                                        }
                                      }
                                    }
                                  },
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
                                        color: Theme.of(context)
                                            .primaryIconTheme
                                            .color,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            widgetCategories(setState),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.0),
                              child: Text(
                                'type vacancy'.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            widgetType(setState),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'location'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final res = await Navigator.pushNamed(
                                        context, '/location');
                                    if (res != null &&
                                        res is ResultLocationEntity) {
                                      final idx = resultLocation
                                          .indexWhere((e) => e.id == res.id);
                                      if (idx != -1) {
                                        setState(() {
                                          resultLocation[idx] =
                                              ResultLocationModel.fromJSON({
                                            'id': resultLocation[idx].id,
                                            'location':
                                                resultLocation[idx].location,
                                            'checked': true
                                          });
                                        });
                                      } else {
                                        for (var i = 0;
                                            i < resultLocation.length;
                                            i++) {
                                          if (resultLocation[i].checked ==
                                              false) {
                                            setState(() {
                                              resultLocation[i] =
                                                  ResultLocationModel.fromJSON({
                                                'id': res.id,
                                                'location': res.location,
                                                'checked': true
                                              });
                                            });
                                            return;
                                          }
                                        }
                                      }
                                    }
                                  },
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
                                        color: Theme.of(context)
                                            .primaryIconTheme
                                            .color,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            widgetLocation(setState),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              }),
        );
      },
    );
  }

  Widget widgetCategories(Function(void Function()) setState) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if ((catState is CategoriesInitial) ||
            (catState is CategoriesLoading)) {
          return SizedBox(
            height: 80,
            width: double.infinity,
            child: Wrap(
              spacing: 5.0,
              runSpacing: 6.0,
              children: List.generate(
                  12,
                  (index) => const ShimmerWidget(
                        height: 32,
                        width: 132,
                      )),
            ),
          );
        } else {
          return Wrap(
            spacing: 4.0,
            runSpacing: 2.0,
            children: List.generate(
              resultCategori.length,
              (index) => FilterChip(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                label: Text(
                  resultCategori[index].category!,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: resultCategori[index].checked!
                          ? Colors.white
                          : Theme.of(context).primaryIconTheme.color),
                ),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: resultCategori[index].checked!
                    ? Theme.of(context).primaryColor.withOpacity(.5)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryIconTheme.color!),
                ),
                onSelected: (bool value) {
                  setState(() {
                    resultCategori[index] = ResultCategoriesModel.fromJSON({
                      'id': resultCategori[index].id,
                      'category': resultCategori[index].category,
                      'checked': !resultCategori[index].checked!
                    });
                  });
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget widgetType(Function(void Function()) setState) {
    return BlocBuilder<TypeVacancyCubit, TypeVacancyState>(
      builder: (context, catState) {
        if (catState is TypeVacancyLoading) {
          return SizedBox(
            height: 40,
            width: double.infinity,
            child: Wrap(
              spacing: 5.0,
              runSpacing: 6.0,
              children: List.generate(
                  12,
                  (index) => const ShimmerWidget(
                        height: 32,
                        width: 132,
                      )),
            ),
          );
        } else {
          return Wrap(
            spacing: 4.0,
            runSpacing: 2.0,
            children: List.generate(
              resultType.length,
              (index) => FilterChip(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                label: Text(
                  resultType[index].type!,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: resultType[index].checked!
                          ? Colors.white
                          : Theme.of(context).primaryIconTheme.color),
                ),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: resultType[index].checked!
                    ? Theme.of(context).primaryColor.withOpacity(.5)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryIconTheme.color!),
                ),
                onSelected: (bool value) {
                  setState(() {
                    resultType[index] = ResultTypeVacancyModel.fromJSON({
                      'id': resultType[index].id,
                      'type': resultType[index].type,
                      'checked': !resultType[index].checked!
                    });
                  });
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget widgetLocation(Function(void Function()) setState) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, catState) {
        if ((catState is LocationInitial) || (catState is LocationLoading)) {
          return SizedBox(
            height: 120,
            width: double.infinity,
            child: Wrap(
              spacing: 5.0,
              runSpacing: 6.0,
              children: List.generate(
                  12,
                  (index) => const ShimmerWidget(
                        height: 32,
                        width: 132,
                      )),
            ),
          );
        } else {
          return Wrap(
            spacing: 4.0,
            runSpacing: 2.0,
            children: List.generate(
              resultLocation.length,
              (index) => FilterChip(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                label: Text(
                  resultLocation[index].location!,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: resultLocation[index].checked!
                          ? Colors.white
                          : Theme.of(context).primaryIconTheme.color),
                ),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: resultLocation[index].checked!
                    ? Theme.of(context).primaryColor.withOpacity(.5)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryIconTheme.color!),
                ),
                onSelected: (bool value) {
                  setState(() {
                    resultLocation[index] = ResultLocationModel.fromJSON({
                      'id': resultLocation[index].id,
                      'location': resultLocation[index].location,
                      'checked': !resultLocation[index].checked!
                    });
                  });
                },
              ),
            ),
          );
        }
      },
    );
  }
}
