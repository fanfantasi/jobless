import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/bookmarks/bookmarks_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class WidgetVacancyContainer extends StatelessWidget {
  final ResultVacanciesEntity data;
  final bool employee;
  const WidgetVacancyContainer(
      {super.key, required this.data, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 82,
            width: MediaQuery.of(context).size.width / 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            '${Config.baseUrl}/${Config.imageEmployers}/${data.image ?? data.userCompany!.photo}',
                        placeholder: (context, url) => const Center(
                            child: LoadingWidget(
                          fallingDot: true,
                        )),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/icons/logo-empty.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: data.verify ?? false,
                  child: Positioned(
                    top: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/icons/verified.png',
                      height: 16,
                      width: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.7,
                          height: 38,
                          child: AutoSizeText(
                            data.title!,
                            maxLines: 2,
                            minFontSize: 14.0,
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(.6),
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.7,
                          child: Text(
                            data.userCompany!.companyname!,
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(.6),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          employee
                              ? BlocBuilder<BookmarksCubit, BookmarksState>(
                                  builder: (context, state) =>
                                      state.bookmarks != null
                                          ? state.bookmarks!
                                                  .where((element) =>
                                                      element == data.id)
                                                  .isNotEmpty
                                              ? Icon(
                                                  Icons.bookmark,
                                                  color: Theme.of(context)
                                                      .primaryIconTheme
                                                      .color,
                                                )
                                              : Icon(
                                                  Icons.bookmark_border,
                                                  color: Theme.of(context)
                                                      .primaryIconTheme
                                                      .color,
                                                )
                                          : Icon(
                                              Icons.bookmark_border,
                                              color: Theme.of(context)
                                                  .primaryIconTheme
                                                  .color,
                                            ),
                                )
                              : status(status: data.status),
                          AutoSizeText(
                            data.salary! == '0'
                                ? 'not mentioned'.tr()
                                : Config()
                                    .number
                                    .format(int.tryParse(data.salary!)),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: data.salary! == '0' ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.fill
                                ..color = Theme.of(context).disabledColor
                                ..maskFilter = MaskFilter.blur(BlurStyle.normal,
                                    data.salary! == '0' ? 4 : 0),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context)
                          .primaryIconTheme
                          .color!
                          .withOpacity(.6),
                      size: 16.0,
                    ),
                    Text(
                      data.location!,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Icon(
                      Icons.watch_later_outlined,
                      color: Theme.of(context)
                          .primaryIconTheme
                          .color!
                          .withOpacity(.6),
                      size: 16.0,
                    ),
                    const SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      timeago.format(DateTime.parse(data.createdAt!),
                          locale: 'locale'.tr()),
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget status({String? status}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: status == 'active'
              ? Colors.green.shade500.withOpacity(.2)
              : Colors.red.shade500.withOpacity(.2)),
      child: AutoSizeText(
        status!.tr(),
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color:
              status == 'active' ? Colors.green.shade500 : Colors.red.shade500,
        ),
      ),
    );
  }
}
