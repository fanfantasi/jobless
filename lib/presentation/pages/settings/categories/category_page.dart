import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/loadmore.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/domain/entities/categories_entity.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';

class CategoriesSettingPage extends StatefulWidget {
  const CategoriesSettingPage({super.key});

  @override
  State<CategoriesSettingPage> createState() => _CategoriesSettingPageState();
}

class _CategoriesSettingPageState extends State<CategoriesSettingPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _textCategoryController = TextEditingController();
  late StreamSubscription<CategoriesState> streamCategory;
  final TextEditingController _textSearchController = TextEditingController();
  Timer? _debounce;
  List<ResultCategoriesEntity> categories = [];

  bool newData = false;

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
        titleSpacing: 0,
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () =>
                  _modalBottomSheetMenu(context, id: '', edited: false),
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
                      await Future.delayed(const Duration(seconds: 1), () {
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
                      children: List.generate(categories.length + 1, (i) {
                        if (i == categories.length) {
                          return newData
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 2.0),
                                  child: ShimmerWidget(
                                      height: 48, width: double.infinity),
                                )
                              : const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 2.0),
                          child: Column(
                            children: [
                              ListTile(
                                dense: true,
                                minLeadingWidth: 12.0,
                                leading: const Icon(Icons.check_circle_outline),
                                style: ListTileStyle.drawer,
                                title: Text(categories[i].category!),
                              ),
                              const Divider(
                                height: 1,
                              )
                            ],
                          ),
                        );
                      }),
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

  void _modalBottomSheetMenu(BuildContext context, {String? id, bool? edited}) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      context: context,
      enableDrag: true,
      builder: (context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Container(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.25,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        child: Container(
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              child: TextFieldCustom(
                                controller: _textCategoryController,
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: 'category is required'.tr()),
                                ]),
                                placeholder: 'categories'.tr(),
                                prefixIcon:
                                    const Icon(Icons.line_style_rounded),
                              ),
                            ),
                            InkResponse(
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    newData = true;
                                  });
                                  Navigator.pop(context);
                                  context
                                      .read<CategoriesCubit>()
                                      .postcategories(
                                          id: id!,
                                          category:
                                              _textCategoryController.text)
                                      .then((value) async {
                                    if (value.error == null) {
                                      setState(() {
                                        if (edited!) {
                                          int idx = categories.indexWhere(
                                              (element) => element.id == id);
                                          if (idx != -1) {
                                            categories[idx] =
                                                ResultCategoriesEntity(
                                                    id: id,
                                                    category:
                                                        _textCategoryController
                                                            .text,
                                                    checked: false);
                                          }
                                        } else {
                                          categories.add(ResultCategoriesEntity(
                                              id: value.data,
                                              category:
                                                  _textCategoryController.text,
                                              checked: false));
                                        }
                                        newData = false;
                                      });
                                      _textCategoryController.clear();
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * .15,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                ),
                                child: Center(
                                  child: Text(
                                    'Ok',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
