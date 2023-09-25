import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class WidgetApplicantContainer extends StatelessWidget {
  final ResultApplicantsEntity data;
  final bool employee;
  final Function()? onPressedDetail;
  final Function()? onPressedResume;
  const WidgetApplicantContainer(
      {super.key,
      required this.data,
      required this.employee,
      this.onPressedResume,
      this.onPressedDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: employee
                            ? '${Config.baseUrl}/${Config.imageEmployers}/${data.vacancy?.image ?? "${data.vacancy!.photoCompany}"}'
                            : '${Config.baseUrl}/${Config.imageEmployee}/${data.applicant!.photo ?? ''}',
                        placeholder: (context, url) => const Center(
                          child: LoadingWidget(fallingDot: true),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/icons/logo-empty.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: employee
                              ? MediaQuery.of(context).size.width / 1.6
                              : MediaQuery.of(context).size.width / 2.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                employee
                                    ? data.vacancy!.title!
                                    : data.applicant!.fullname!,
                                maxLines: 2,
                                minFontSize: 12.0,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.6),
                                    fontWeight: FontWeight.w800),
                              ),
                              AutoSizeText(
                                employee
                                    ? data.vacancy!.companyName!
                                    : data.applicant!.skill!,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: employee ? 14.0 : 13.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.6),
                                    fontWeight: FontWeight.w600),
                              ),
                              Visibility(
                                visible: !employee,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "applying for".tr(),
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    TextSpan(
                                      text: '${data.vacancy!.title}',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ]),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: employee,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Theme.of(context)
                                              .primaryIconTheme
                                              .color!
                                              .withOpacity(.6),
                                          size: 14.0,
                                        ),
                                        Text(
                                          data.vacancy!.location!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(.6),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color!
                                        .withOpacity(.6),
                                    size: 14.0,
                                  ),
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  Text(
                                    timeago.format(
                                        DateTime.parse(data.createdAt!),
                                        locale: 'locale'.tr()),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: !employee,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                status(
                                    status: data.status,
                                    joinInterview: data.joininterview),
                                SizedBox(
                                  width: 70,
                                  height: kToolbarHeight,
                                  child: IconButton(
                                    onPressed: data.status == 'rejected' ||
                                            data.status == 'accepted'
                                        ? null
                                        : () {
                                            debugPrint('chats');
                                          },
                                    icon: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 6.0),
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1),
                                        child: Icon(
                                          Icons.chat,
                                          size: 28,
                                          color: data.status == 'rejected' ||
                                                  data.status == 'accepted'
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(.2)
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4.0,
          ),
          const Divider(
            height: 1,
          ),
          employee
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  width: MediaQuery.of(context).size.width,
                  child: status(
                      status: data.status, joinInterview: data.joininterview))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryIconTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            elevation: 0),
                        onPressed: onPressedResume,
                        child: Text(
                          'see resume'.tr(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).primaryIconTheme.color!,
                            width: 1.0,
                          ),
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        onPressed: onPressedDetail,
                        child: Text(
                          'see details'.tr(),
                          style: TextStyle(
                              color: Theme.of(context).primaryIconTheme.color,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }

  Widget status({String? status, bool? joinInterview}) {
    return Container(
      width: 190,
      height: employee ? 32 : 28,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(employee ? 8 : 16.0),
          color: joinInterview != null && joinInterview
              ? Colors.green.shade500.withOpacity(.2)
              : getcolor(status).withOpacity(.2)),
      child: AutoSizeText(
        (joinInterview != null && joinInterview)
            ? 'Join Interview'
            : status! == 'interview'
                ? employee
                    ? 'scheduled to interview'.tr()
                    : 'Interview'
                : status.tr(),
        textAlign: TextAlign.center,
        maxLines: 1,
        minFontSize: employee ? 10 : 8,
        style: TextStyle(
          fontSize: employee ? 14 : 10.0,
          fontWeight: FontWeight.bold,
          color: (joinInterview != null && joinInterview)
              ? Colors.green.shade500
              : getcolor(status),
        ),
      ),
    );
  }

  Color getcolor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.blue.shade500;
      case 'accepted':
        return Colors.green.shade500;
      case 'interview':
        return Colors.green.shade500;
      default:
        return Colors.red.shade500;
    }
  }
}
