import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/data/model/categories.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';

void showModalCategories(context,
    {TextEditingController? search,
    required TextEditingController category,
    required TextEditingController categoryId,
    void Function(String)? onChange}) async {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: DraggableScrollableSheet(
          initialChildSize: 1,
          maxChildSize: 1,
          minChildSize: 0.5,
          builder: (context, ScrollController scrollController) {
            return Container(
              margin: const EdgeInsets.all(12.0),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'categories'.tr(),
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  TextFieldCustom(
                    controller: search!,
                    placeholder: 'categories'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                        onPressed: () {
                          search.clear();
                          BlocProvider.of<CategoriesCubit>(context)
                              .getcategories(1, 15, '');
                        },
                        icon: const Icon(Icons.clear)),
                    onChange: onChange,
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Expanded(child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      if (state is CategoriesLoading) {
                        return const Center(
                          child: LoadingWidget(),
                        );
                      } else if (state is CategoriesLoaded) {
                        return ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              indent: 12.0,
                              endIndent: 12.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.1)),
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.categories.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                trailing: categoryId.text ==
                                        state.categories.data[index].id!
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.green,
                                      )
                                    : SizedBox.fromSize(),
                                title: Text(
                                  state.categories.data[index].category!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: categoryId.text ==
                                              state.categories.data[index].id!
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(.5)),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  category.text =
                                      state.categories.data[index].category!;
                                  for (var i = 0;
                                      i < state.categories.data.length;
                                      i++) {
                                    state.categories.data[i] =
                                        ResultCategoriesModel.fromJSON({
                                      'id': state.categories.data[i].id,
                                      'category':
                                          state.categories.data[i].category,
                                      'checked': false
                                    });
                                  }

                                  state.categories.data[index] =
                                      ResultCategoriesModel.fromJSON({
                                    'id': state.categories.data[index].id,
                                    'category':
                                        state.categories.data[index].category,
                                    'checked': true
                                  });
                                  categoryId.text =
                                      state.categories.data[index].id!;
                                });
                          },
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: SvgPicture.asset('assets/icons/empty.svg'),
                            ),
                            Text('no results found'.tr())
                          ],
                        );
                      }
                    },
                  )),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() => Config.isLoadedCategories = true);
}
