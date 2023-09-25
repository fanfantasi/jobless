import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/loadmore.dart';
import 'package:jobless/core/widgets/radiobutton.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';

class CategoriesJobPage extends StatefulWidget {
  const CategoriesJobPage({super.key});

  @override
  State<CategoriesJobPage> createState() => _CategoriesJobPageState();
}

class _CategoriesJobPageState extends State<CategoriesJobPage> {
  late StreamSubscription<CategoriesState> stream;
  List<RadioModel> categoriesJobs = [];

  bool isLastPage = false;
  bool isLoadMore = false;
  int page = 1;
  @override
  void initState() {
    categories();
    super.initState();
  }

  @override
  void dispose() {
    page = 1;
    isLastPage = false;
    stream.cancel();
    super.dispose();
  }

  Future<void> categories() async {
    categoriesJobs.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<CategoriesCubit>().getcategories(page, 10, '');
    stream = context.read<CategoriesCubit>().stream.listen((event) {
      if (event is CategoriesLoaded) {
        for (var e in event.categories.data) {
          categoriesJobs.add(RadioModel(false, 'employee', e.id!, '',
              Icons.local_library_outlined, e.category!));
        }
        if (event.categories.data.isEmpty) {
          isLastPage = true;
        }
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
          'what want a job'.tr(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('choose jobs'.tr()),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, categoryState) {
                  if ((categoryState is CategoriesLoading ||
                          categoryState is CategoriesInitial) &&
                      !isLoadMore) {
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
                          BlocProvider.of<CategoriesCubit>(context)
                              .getcategories(page, 10, '');
                        });
                      },
                      noMoreWidget: Text(
                        'no more data'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      child: Center(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoriesJobs.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? 3
                                    : 2,
                            crossAxisSpacing: (2 / 1.5),
                            mainAxisSpacing: 6,
                            childAspectRatio: (2 / 1.6),
                          ),
                          itemBuilder: (context, index) {
                            return Center(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    var selectedCategory = categoriesJobs
                                        .where((e) => e.isSelected == true)
                                        .toList();
                                    if (selectedCategory.length > 4 &&
                                        categoriesJobs[index].isSelected ==
                                            false) {
                                      Fluttertoast.showToast(
                                          msg: 'choose confirm'.tr());
                                    } else {
                                      categoriesJobs[index].isSelected =
                                          !categoriesJobs[index].isSelected;
                                    }
                                  });
                                },
                                child: RadioItem(categoriesJobs[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(MediaQuery.of(context).size.width - 32, 42)),
          onPressed: () {
            var selestedCategory =
                categoriesJobs.where((e) => e.isSelected == true).toList();
            if (selestedCategory.isEmpty) {
              Fluttertoast.showToast(msg: 'choose jobs'.tr());
            } else {
              Navigator.pushNamed(context, '/category/employee',
                  arguments: selestedCategory);
            }
          },
          child: Text(
            'next'.tr(),
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
