import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/bookmarks/bookmarks_cubit.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class WidgetVacancy extends StatefulWidget {
  const WidgetVacancy({super.key});

  @override
  State<WidgetVacancy> createState() => _WidgetVacancyState();
}

class _WidgetVacancyState extends State<WidgetVacancy> {
  ResultVacanciesEntity? vacancy;
  bool? employee;

  final RoundedLoadingButtonController _btnSubmitController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnInAcviteController =
      RoundedLoadingButtonController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var map = ModalRoute.of(context)!.settings.arguments as Map;
    vacancy = map['vacancy'];
    employee = map['employee'];

    super.didChangeDependencies();
  }

  void postbookmarks(String id) async {
    context.read<BookmarksCubit>().postbookmarks(id);
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
          'Jobs Details',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () async {
                final result = await Share.shareWithResult(
                    'check out my website https://example.com');

                if (result.status == ShareResultStatus.success) {
                  // print('Thank you for sharing my website!');
                }
              },
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                  child: Icon(
                    Icons.share,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 92,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ]),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 82,
                        width: MediaQuery.of(context).size.width / 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${Config.baseUrl}/${Config.imageEmployers}/${vacancy!.image ?? vacancy!.userCompany!.photo}',
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
                      const SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: AutoSizeText(
                                vacancy!.title!,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.6),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Text(
                              vacancy!.userCompany!.companyname!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.6),
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.watch_later_outlined,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.6),
                                  size: 16.0,
                                ),
                                const SizedBox(
                                  width: 2.0,
                                ),
                                Text(
                                  timeago.format(
                                      DateTime.parse(vacancy!.createdAt!),
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
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const Divider(
                  height: 1,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                infowidget(
                  context,
                  attr: 'salary'.tr(),
                  value: vacancy!.salary == '0'
                      ? vacancy!.salary
                      : Config().number.format(int.tryParse(vacancy!.salary!)),
                ),
                infowidget(context,
                    attr: 'type job'.tr(), value: vacancy!.typevacancy),
                infowidget(context,
                    attr: 'location'.tr(), value: vacancy!.location),
                const SizedBox(
                  height: 12.0,
                ),
                const Divider(
                  height: 1,
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Text(
                  'desc'.tr(),
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Html(
                    data: vacancy!.desc!,
                    style: {
                      'p': Style(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.8),
                      ),
                      'ul': Style(
                          padding: HtmlPaddings.only(left: 8.0),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.8)),
                      'ol': Style(
                          padding: HtmlPaddings.only(left: 16.0),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.8))
                    },
                  ),
                ),
                Text(
                  'requirements'.tr(),
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                requirements(context, requirement: vacancy!.requirement)
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: employee!
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: kToolbarHeight,
                    child: IconButton(
                      onPressed: () => postbookmarks(vacancy!.id!),
                      icon: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            color:
                                Theme.of(context).primaryColor.withOpacity(.1),
                            child: BlocBuilder<BookmarksCubit, BookmarksState>(
                              builder: (context, state) => state.bookmarks!
                                      .where(
                                          (element) => element == vacancy!.id)
                                      .isNotEmpty
                                  ? Icon(
                                      Icons.bookmark,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : Icon(
                                      Icons.bookmark_border,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                    ),
                            )),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 110,
                    child: RoundedLoadingButton(
                      animateOnTap: false,
                      errorColor: Colors.red.shade200,
                      controller: _btnSubmitController,
                      onPressed: () async {
                        if (!context.mounted) return;
                        if (vacancy!.status == 'inactive') {
                          Fluttertoast.showToast(msg: 'vacancy inactive'.tr());
                        } else {
                          Navigator.pushNamed(context, '/apply-vacancy',
                              arguments: vacancy!);
                        }
                      },
                      borderRadius: 22,
                      elevation: 0,
                      color: Theme.of(context).primaryColor,
                      height: kToolbarHeight - 12,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Text(
                        'apply now'.tr(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundedLoadingButton(
                animateOnTap: true,
                errorColor: Colors.red.shade200,
                controller: _btnInAcviteController,
                onPressed: vacancy!.status == 'inactive'
                    ? null
                    : () async {
                        if (!context.mounted) return;

                        context
                            .read<PostDataCubit>()
                            .inactivevacancy(id: vacancy!.id);
                        Navigator.pop(context, true);
                      },
                borderRadius: 22,
                elevation: 0,
                color: Theme.of(context).primaryColor,
                height: kToolbarHeight - 12,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'inactive'.tr(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }

  Widget infowidget(context, {String? attr, String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            attr!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          Text(
            '${value == '0' ? 'not mentioned'.tr() : value}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              foreground: Paint()
                ..style = PaintingStyle.fill
                ..color = Theme.of(context).disabledColor
                ..maskFilter =
                    MaskFilter.blur(BlurStyle.normal, value == '0' ? 4 : 0),
            ),
          )
        ],
      ),
    );
  }

  Widget requirements(context, {List<ResultRequirementsEntity>? requirement}) {
    return Column(
      children: List.generate(
        requirement!.length,
        (index) => Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.05),
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).primaryColor.withOpacity(.8),
              ),
              const SizedBox(
                width: 12.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Text(
                  requirement[index].requirement!,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.8)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
