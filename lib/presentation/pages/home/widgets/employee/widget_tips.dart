import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/injection_container.dart' as di;
import 'package:jobless/presentation/bloc/tips/tips_cubit.dart';
import 'package:jobless/presentation/pages/tips/tips_detail_page.dart';
import 'package:lottie/lottie.dart';

class WidgetTips extends StatefulWidget {
  const WidgetTips({super.key});

  @override
  State<WidgetTips> createState() => _WidgetTipsState();
}

class _WidgetTipsState extends State<WidgetTips> {
  int _currentCarousel = 0;
  final CarouselController _controllerCarousel = CarouselController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<TipsCubit>()..gettips(1, ''),
      child: BlocBuilder<TipsCubit, TipsState>(
        builder: (context, tipsState) {
          if ((tipsState is TipsInitial) || (tipsState is TipsLoading)) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ShimmerWidget(
                width: MediaQuery.of(context).size.width,
                height: 160,
              ),
            );
          } else if (tipsState is TipsLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 192,
                child: Column(
                  children: [
                    Expanded(
                      child: CarouselSlider(
                        options: CarouselOptions(
                            height: 192.0,
                            autoPlay: true,
                            aspectRatio: 9 / 6,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarousel = index;
                              });
                            }),
                        items: tipsState.tips.data.map((dataTips) {
                          return Builder(
                            builder: (BuildContext context) {
                              return InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) =>
                                            TipsDetailpage(tips: dataTips))),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          '${Config.baseUrl}/${Config.imageTips}/${dataTips.image ?? ''}',
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: LoadingWidget(
                                          fallingDot: true,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          SvgPicture.asset(
                                        'assets/icons/Illustrasi.svg',
                                        height: 160,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          tipsState.tips.data.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              _controllerCarousel.animateToPage(entry.key),
                          child: Container(
                            width: _currentCarousel == entry.key ? 18.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                                shape: _currentCarousel == entry.key
                                    ? BoxShape.rectangle
                                    : BoxShape.circle,
                                borderRadius: _currentCarousel == entry.key
                                    ? BorderRadius.circular(8.0)
                                    : null,
                                color: Theme.of(context)
                                    .primaryIconTheme
                                    .color!
                                    .withOpacity(_currentCarousel == entry.key
                                        ? 0.9
                                        : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/lottie/not-found.json',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.width / 3,
                    ),
                    Text(
                      'page error'.tr(),
                      style: TextStyle(color: Theme.of(context).disabledColor),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
