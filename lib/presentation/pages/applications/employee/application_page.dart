import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/applicant.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/data/model/chips.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/presentation/bloc/applicants/applicants_cubit.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:lottie/lottie.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  final TextEditingController _textSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChipsModel> chipsModel = [];
  Timer? _debounce;

  late StreamSubscription<ApplicantsState> stream;

  //Applications
  List<ResultApplicantsEntity> applicants = [];
  bool isLastPage = false;
  bool _isLoading = false;
  bool nextPage = false;
  int page = 1;
  String params = '';

  @override
  void initState() {
    params = '&applicantId[equals]=${context.read<UserCubit>().user!.id}';
    chipsModel.add(ChipsModel(true, 'all', 'all'.tr()));
    chipsModel.add(ChipsModel(false, 'accepted', 'accepted'.tr()));
    chipsModel.add(ChipsModel(false, 'rejected', 'rejected'.tr()));
    chipsModel.add(ChipsModel(false, 'interview', 'Interview'));
    stremApplication();
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

  Future<void> stremApplication() async {
    applicants.clear();
    Config.params = '';
    setState(() {
      isLastPage = false;
      page = 1;
    });

    if (!mounted) return;

    context.read<ApplicantsCubit>().getapplicants(page, params);

    stream = context.read<ApplicantsCubit>().stream.listen((event) {
      if (!mounted) return;
      if (Config.isChangeTab && !_isLoading) {
        applicants.clear();
      }
      if (event is ApplicantsLoaded) {
        if (applicants.isEmpty) {
          page = 1;
          isLastPage = false;
        }

        for (var e in event.applicants.data) {
          if (applicants.where((x) => x.id == e.id).isEmpty) {
            applicants.add(
              ResultApplicantsEntity(
                id: e.id,
                applicant: e.applicant,
                vacancy: e.vacancy,
                desc: e.desc,
                cv: e.cv,
                interviewdate: e.interviewdate,
                interviewtime: e.interviewtime,
                joininterview: e.joininterview,
                message: e.message,
                status: e.status,
                updatedAt: e.updatedAt,
                createdAt: e.createdAt,
              ),
            );
          }
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
    if (!mounted) return;
    if (Config.params == '') {
      await context.read<ApplicantsCubit>().getapplicants(page, params);
    } else {
      await context
          .read<ApplicantsCubit>()
          .getapplicants(page, '$params&${Config.params}');
    }
  }

  @override
  void dispose() {
    stream.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query == '') {
        applicants.clear();
        setState(() {
          _isLoading = false;
        });
        context
            .read<ApplicantsCubit>()
            .getapplicants(page, '$params${Config.params}');
      } else {
        applicants.clear();
        setState(() {
          isLastPage = false;
          page = 1;
          _isLoading = false;
        });
        context.read<ApplicantsCubit>().getapplicants(
            page, '$params${Config.params}&vacancies[title][contains]=$query');
      }
    });
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
        title: const Text(
          'Applications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, '/bookmarks'),
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                  child: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        radius: const Radius.circular(8.0),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  TextFieldCustom(
                    controller: _textSearchController,
                    placeholder: 'search vacancies'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    onChange: _onSearchChanged,
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
            BlocBuilder<ApplicantsCubit, ApplicantsState>(
              builder: (context, state) {
                if (state is ApplicantsLoading && !_isLoading) {
                  return shimmerWidet();
                } else {
                  if (applicants.isEmpty && !_isLoading) {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/lottie/searchempty.json',
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                  ),
                                  Text(
                                    'no results found'.tr(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Theme.of(context).disabledColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: applicants.length + 1,
                    itemBuilder: (context, i) {
                      if (i == applicants.length) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _isLoading
                              ? const LoadingWidget()
                              : isLastPage
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            'no more data'.tr(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .disabledColor,
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
                                  : SizedBox.fromSize(),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: InkWell(
                          onTap: () async {
                            final res = await Navigator.pushNamed(
                                context, '/app-employee-detail',
                                arguments: applicants[i].id);
                            if (res != null && res as bool) {
                              if (!mounted) return;

                              await context
                                  .read<ApplicantsCubit>()
                                  .getapplicants(page, params);
                            }
                          },
                          child: WidgetApplicantContainer(
                            data: applicants[i],
                            employee: true,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget shimmerWidet() {
    return SliverFixedExtentList(
      itemExtent: 138,
      delegate: SliverChildBuilderDelegate(
        childCount: 15,
        (BuildContext context, int index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ShimmerWidget(
              height: 110,
              width: MediaQuery.of(context).size.width,
            ),
          );
        },
      ),
    );
  }

  Widget chips({String? title, bool? selected, int? i}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Theme.of(context).primaryIconTheme.color!),
        ),
        onSelected: (bool value) async {
          setState(() {
            page = 1;
            Config.isChangeTab = true;
            for (var element in chipsModel) {
              element.isSelected = false;
            }
            chipsModel[i!].isSelected = true;
          });
          if (!mounted) return;
          if (chipsModel[i!].options == 'all') {
            Config.params = '';
            await BlocProvider.of<ApplicantsCubit>(context)
                .getapplicants(page, params);
          } else {
            Config.params = '&status=${chipsModel[i].options}';
            await BlocProvider.of<ApplicantsCubit>(context)
                .getapplicants(page, '$params${Config.params}');
          }
        },
      ),
    );
  }
}
