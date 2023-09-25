import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/domain/entities/tips_entity.dart';

class TipsDetailpage extends StatelessWidget {
  final ResultTipsEntity tips;
  const TipsDetailpage({super.key, required this.tips});

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
          'tips for you'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Scrollbar(
        radius: const Radius.circular(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${Config.baseUrl}/${Config.imageTips}/${tips.image ?? ''}",
                      placeholder: (context, url) => const Center(
                          child: LoadingWidget(
                        fallingDot: true,
                      )),
                      errorWidget: (context, url, error) => SvgPicture.asset(
                        'assets/icons/Illustrasi.svg',
                        height: 160,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 12.0),
                  width: MediaQuery.of(context).size.width - 32,
                  child: Text(
                    tips.title!,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                    indent: 6,
                    color: Theme.of(context).primaryColor.withOpacity(.2)),
                Html(
                  data: tips.desc!,
                  style: {
                    'p': Style(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.7),
                    ),
                    'ul': Style(padding: HtmlPaddings.only(left: 8.0))
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
