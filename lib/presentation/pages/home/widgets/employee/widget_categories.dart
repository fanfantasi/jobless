import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/data/model/categories.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';
import 'package:jobless/presentation/bloc/hidenavbar/hidenavbar_cubit.dart';
import 'package:jobless/presentation/bloc/recommendations/recommendation_cubit.dart';

class WidgetCategories extends StatefulWidget {
  const WidgetCategories({super.key});

  @override
  State<WidgetCategories> createState() => _WidgetCategoriesState();
}

class _WidgetCategoriesState extends State<WidgetCategories> {
  List<ResultCategoriesModel> resultCategori = [];
  late StreamSubscription<CategoriesState> stream;

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void getCategories() async {
    resultCategori.clear();

    if (!mounted) return;
    context.read<CategoriesCubit>().getcategories(1, 20, '');

    stream = context.read<CategoriesCubit>().stream.listen((event) {
      if (event is CategoriesLoaded) {
        for (var e in event.categories.data) {
          if (resultCategori.where((x) => x.id == e.id).isEmpty) {
            resultCategori.add(ResultCategoriesModel.fromJSON(
                {'id': e.id, 'category': e.category, 'checked': e.checked}));
          }
        }
        if (resultCategori.where((e) => e.id == '0').isEmpty) {
          resultCategori.add(ResultCategoriesModel.fromJSON(
              {'id': '0', 'category': 'All Jobs', 'checked': true}));
        }
        resultCategori.sort((a, b) => a.id!.compareTo(b.id!));

        if (event.categories.data.isEmpty) {
          // isLastPage = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, catState) {
      if ((catState is CategoriesInitial) || (catState is CategoriesLoading)) {
        return ListView.builder(
          itemCount: 4,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShimmerWidget(
              height: 4,
              width: MediaQuery.of(context).size.width / 4,
            ),
          ),
        );
      } else {
        return ListView.builder(
          itemCount: resultCategori.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(
                resultCategori[i].category!,
                style: TextStyle(
                    color: resultCategori[i].checked!
                        ? Colors.white
                        : Theme.of(context).primaryIconTheme.color),
              ),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: resultCategori[i].checked!
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                    color: Theme.of(context).primaryIconTheme.color!),
              ),
              onSelected: (bool value) async {
                setState(() {
                  Config.isChangeTab = true;
                  int idx = resultCategori.indexWhere((e) => e.id == '0');
                  if (resultCategori[idx].checked! &&
                      resultCategori[idx] != resultCategori[i]) {
                    resultCategori[idx] = ResultCategoriesModel.fromJSON({
                      'id': resultCategori[idx].id,
                      'category': resultCategori[idx].category,
                      'checked': !resultCategori[idx].checked!
                    });
                    resultCategori[i] = ResultCategoriesModel.fromJSON({
                      'id': resultCategori[i].id,
                      'category': resultCategori[i].category,
                      'checked': !resultCategori[i].checked!
                    });
                  } else if (resultCategori[i].id == '0') {
                    for (var j = 0; j < resultCategori.length; j++) {
                      resultCategori[j] = ResultCategoriesModel.fromJSON({
                        'id': resultCategori[j].id,
                        'category': resultCategori[j].category,
                        'checked': false
                      });
                    }
                    resultCategori[i] = ResultCategoriesModel.fromJSON({
                      'id': resultCategori[i].id,
                      'category': resultCategori[i].category,
                      'checked': !resultCategori[i].checked!
                    });
                  } else {
                    resultCategori[i] = ResultCategoriesModel.fromJSON({
                      'id': resultCategori[i].id,
                      'category': resultCategori[i].category,
                      'checked': !resultCategori[i].checked!
                    });
                  }
                });
                var params = [];
                for (var e in resultCategori
                    .where((e) => e.checked == true)
                    .toList()) {
                  if (e.id == '0') {
                    params.clear();
                  } else {
                    params.add('categoryId[in]=${e.id!.toLowerCase()}');
                  }
                }
                await Future.delayed(const Duration(milliseconds: 300));

                if (!mounted) return;

                Config.params = params.isEmpty ? '' : '&${params.join('&')}';
                context.read<HideNavBarCubit>().updateNavBar(false);
                context.read<RecommendationCubit>().recommendations(1,
                    '&status[equals]=active&${Config.recommended}${Config.params}');
              },
            ),
          ),
        );
      }
    });
  }
}
