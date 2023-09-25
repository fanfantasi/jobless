import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/domain/entities/tips_entity.dart';
import 'package:jobless/presentation/bloc/tips/tips_cubit.dart';
import 'package:lottie/lottie.dart';

import 'tips_detail_page.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textSearchController = TextEditingController();

  late StreamSubscription<TipsState> stream;

  Timer? _debounce;
  //Vancacies
  List<ResultTipsEntity> tips = [];
  bool _isSearch = false;
  bool isLastPage = false;
  bool _isLoading = false;
  int page = 1;
  String params = '';

  @override
  void initState() {
    streamTips();
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
    _scrollController.dispose();
    super.dispose();
  }

  void streamTips() async {
    if (!mounted) return;
    context.read<TipsCubit>().gettips(page, params);
    stream = context.read<TipsCubit>().stream.listen((event) {
      if (page == 1) {
        tips.clear();
      }

      if (event is TipsLoaded) {
        if (tips.isEmpty) {
          page = 1;
          isLastPage = false;
        }

        for (var e in event.tips.data) {
          tips.add(ResultTipsEntity(
              id: e.id,
              title: e.title,
              desc: e.desc,
              image: e.image,
              read: e.read,
              createdAt: e.createdAt,
              author: e.author));
        }

        if (event.tips.data.isEmpty) {
          isLastPage = true;
        } else {
          isLastPage = false;
        }
      }
    });
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query == '') {
        tips.clear();
        setState(() {
          _isSearch = false;
          _isLoading = false;
        });
        params = '';
      } else {
        tips.clear();
        setState(() {
          _isSearch = true;
          isLastPage = false;
          page = 1;
          _isLoading = false;
        });
        params = '&title[contains]=$query';
      }
      context.read<TipsCubit>().gettips(page, params);
    });
  }

  Future<void> onLoadmore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await context.read<TipsCubit>().gettips(page, params);
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
          'tips for you'.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: TextFieldCustom(
              controller: _textSearchController,
              placeholder: 'search vacancies'.tr(),
              prefixIcon: const Icon(Icons.search),
              onChange: _onSearchChanged,
            ),
          ),
          BlocBuilder<TipsCubit, TipsState>(
            builder: (_, state) {
              if ((state is TipsLoading) && !_isLoading) {
                return SliverFixedExtentList(
                  itemExtent: 160,
                  delegate: SliverChildBuilderDelegate(
                    childCount: 5,
                    (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: ShimmerWidget(
                          width: MediaQuery.of(context).size.width,
                          height: 160,
                        ),
                      );
                    },
                  ),
                );
              } else if (state is TipsInitial) {
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
                if (tips.isEmpty && !_isLoading) {
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
                  itemExtent: 160,
                  delegate: SliverChildBuilderDelegate(
                    childCount: tips.length + 1,
                    (BuildContext context, int index) {
                      if (index == tips.length) {
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
                          onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) =>
                                      TipsDetailpage(tips: tips[index]))),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 4,
                                  blurRadius: 4,
                                  offset: const Offset(
                                      0, 4), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    "${Config.baseUrl}/${Config.imageTips}/${tips[index].image ?? ''}",
                                placeholder: (context, url) => const Center(
                                  child: LoadingWidget(fallingDot: true),
                                ),
                                errorWidget: (context, url, error) =>
                                    SvgPicture.asset(
                                  'assets/icons/Illustrasi.svg',
                                  height: 160,
                                ),
                              ),
                            ),
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
