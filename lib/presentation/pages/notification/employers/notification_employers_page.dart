import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/loadmore.dart';
import 'package:jobless/core/widgets/not_found.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/domain/entities/notification_entity.dart';
import 'package:jobless/presentation/bloc/notifications/notification_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationEmployersPage extends StatefulWidget {
  const NotificationEmployersPage({super.key});

  @override
  State<NotificationEmployersPage> createState() =>
      _NotificationEmployersPageState();
}

class _NotificationEmployersPageState extends State<NotificationEmployersPage> {
  late StreamSubscription<NotificationState> stream;
  final TextEditingController _textSearchController = TextEditingController();
  Timer? _debounce;
  List<ResultNotificationEntity> notifications = [];

  bool isLastPage = false;
  bool isLoadMore = false;
  int page = 1;
  String params = '';

  @override
  void initState() {
    params = '&receiverId[equals]=${context.read<UserCubit>().user!.id}';
    getNotification();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void getNotification() async {
    notifications.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    if (!mounted) return;
    context.read<NotificationCubit>().notification(page, params);
    stream = context.read<NotificationCubit>().stream.listen((event) {
      if (event is NotificationLoaded) {
        for (var e in event.notification.data) {
          notifications.add(ResultNotificationEntity(
              id: e.id,
              title: e.title,
              body: e.body,
              link: e.link,
              status: e.status,
              sender: e.sender,
              read: e.read,
              createdAt: e.createdAt,
              receiver: e.receiver));
        }
        if (event.notification.data.isEmpty) {
          isLastPage = true;
        }
      }
    });
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      notifications.clear();
      setState(() {
        isLastPage = false;
        page = 1;
      });

      context
          .read<NotificationCubit>()
          .notification(page, '$params&title[contains]=$query');
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
              ),
            ),
          ),
        ),
        title: Text(
          'notification'.tr(),
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
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading && !isLoadMore) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight * 2.8,
                      child: const LoadingWidget());
                } else if (state is NotificationFailure) {
                  return const NotFound();
                } else {
                  if (notifications.isEmpty && !isLoadMore) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Lottie.asset('assets/lottie/notifempty.json',
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height / 3),
                      ),
                    );
                  }
                  return RefreshLoadmore(
                    isLastPage: isLastPage,
                    onLoadmore: () async {
                      setState(() {
                        isLoadMore = true;
                        page += 1;
                      });
                      await Future.delayed(const Duration(seconds: 1), () {
                        context
                            .read<NotificationCubit>()
                            .notificationUseCase(page, params);
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
                        notifications.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: InkWell(
                            onTap: () async {
                              var link = notifications[i].link!.split('/');
                              if (link.length > 1) {
                                Navigator.pushNamed(context, '/${link[0]}',
                                    arguments: link[1]);
                              } else {
                                Navigator.pushNamed(
                                    context, link[0].toString());
                              }

                              context
                                  .read<NotificationCubit>()
                                  .updateReadNotification(notifications[i].id!)
                                  .then((value) => print(value));
                            },
                            child: Container(
                              height: 82,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 38,
                                    width: 38,
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                          color: notifications[i].read!
                                              ? Theme.of(context)
                                                  .primaryIconTheme
                                                  .color!
                                                  .withOpacity(.1)
                                              : Theme.of(context)
                                                  .primaryIconTheme
                                                  .color!
                                                  .withOpacity(.5),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "${Config.baseUrl}/${Config.imageEmployers}/${notifications[i].sender!.employers!.photo ?? ''}",
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child: LoadingWidget(
                                            fallingDot: true,
                                          )),
                                          errorWidget: (context, url, error) =>
                                              SvgPicture.asset(
                                            'assets/icons/user.svg',
                                            height: 82,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8.0,
                                  ),
                                  Expanded(
                                      child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.height - 60,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: RichText(
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${notifications[i].title!}, ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)),
                                                TextSpan(
                                                    text:
                                                        notifications[i].body!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          timeago.format(
                                              DateTime.parse(
                                                  notifications[i].createdAt!),
                                              locale: 'locale'.tr()),
                                          style: TextStyle(
                                              color: notifications[i].read!
                                                  ? Theme.of(context)
                                                      .primaryIconTheme
                                                      .color!
                                                      .withOpacity(.6)
                                                  : Theme.of(context)
                                                      .primaryIconTheme
                                                      .color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
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
