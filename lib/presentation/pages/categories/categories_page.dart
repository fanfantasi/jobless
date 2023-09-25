import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/loadmore.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/domain/entities/categories_entity.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late StreamSubscription<CategoriesState> streamCategory;
  final TextEditingController _textSearchController = TextEditingController();
  Timer? _debounce;
  List<ResultCategoriesEntity> categories = [];

  bool isLastPage = false;
  bool isLoadMore = false;
  int page = 1;

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    streamCategory.cancel();
    super.dispose();
  }

  void getCategories() async {
    categories.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<CategoriesCubit>().getcategories(page, 20, '');

    streamCategory = context.read<CategoriesCubit>().stream.listen((event) {
      if (event is CategoriesLoaded) {
        for (var e in event.categories.data) {
          categories.add(ResultCategoriesEntity(
              id: e.id, category: e.category, checked: e.checked));
        }
        if (event.categories.data.isEmpty) {
          isLastPage = true;
        }
      }
    });
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      categories.clear();
      setState(() {
        isLastPage = false;
        page = 1;
      });
      context
          .read<CategoriesCubit>()
          .getcategories(page, 20, '&category[contains]=$query');
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
          'categories'.tr(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          TextFieldCustom(
            controller: _textSearchController,
            placeholder: 'search vacancies'.tr(),
            prefixIcon: const Icon(Icons.search),
            onChange: _onSearchChanged,
          ),
          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading && !isLoadMore) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight * 2.8,
                      child: const LoadingWidget());
                } else {
                  return RefreshLoadmore(
                    isLastPage: isLastPage,
                    onLoadmore: () async {
                      setState(() {
                        isLoadMore = true;
                        page += 1;
                      });
                      await Future.delayed(const Duration(milliseconds: 1), () {
                        context
                            .read<CategoriesCubit>()
                            .getcategories(page, 10, '');
                      });
                    },
                    noMoreWidget: Column(
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
                    ),
                    child: Column(
                      children: List.generate(
                        categories.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 2.0),
                          child: ListTile(
                            style: ListTileStyle.drawer,
                            onTap: () => Navigator.pop(context, categories[i]),
                            title: Text(categories[i].category!),
                            trailing:
                                const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
