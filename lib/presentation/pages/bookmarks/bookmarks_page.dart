import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/vacancy.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/bookmarks/bookmarks_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:lottie/lottie.dart';

class BookmaksPage extends StatefulWidget {
  const BookmaksPage({super.key});

  @override
  State<BookmaksPage> createState() => _BookmaksPageState();
}

class _BookmaksPageState extends State<BookmaksPage> {
  final ScrollController _scrollController = ScrollController();
  String? title;
  bool? isSearch;

  late StreamSubscription<VacanciesState> stream;
  late StreamSubscription<BookmarksState> streambookmarks;
  //Vancacies
  List<ResultVacanciesEntity> vacancies = [];
  bool isLastPage = false;
  bool _isLoading = false;
  int page = 1;
  String params = '';

  @override
  void initState() {
    streamBookmarks();

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

  void streamBookmarks() async {
    var paramsbookmarks = [];
    context.read<BookmarksCubit>().bookmaksVacancies();
    streambookmarks = context.read<BookmarksCubit>().stream.listen((event) {
      if (event.bookmarks!.isNotEmpty) {
        for (var e in event.bookmarks!) {
          paramsbookmarks.add('id[in]=$e');
        }
      } else {
        paramsbookmarks.add('id[in]=');
      }
      params = '$params&${paramsbookmarks.join('&')}';
    });
    await Future.delayed(Duration.zero);
    streamVacancies();
  }

  void streamVacancies() async {
    if (!mounted) return;
    context.read<VacanciesCubit>().getvacancies(page, params);
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
    streambookmarks.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> onLoadmore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await context.read<VacanciesCubit>().getvacancies(page, params);
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
          'Bookmarks',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          BlocBuilder<VacanciesCubit, VacanciesState>(
            builder: (_, state) {
              if ((state is VacanciesLoading) && !_isLoading) {
                return SliverFixedExtentList(
                  itemExtent: 110,
                  delegate: SliverChildBuilderDelegate(
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
                        children: [
                          Lottie.asset('assets/lottie/searchempty.json',
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 4),
                          Text(
                            'no results found'.tr(),
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
}
