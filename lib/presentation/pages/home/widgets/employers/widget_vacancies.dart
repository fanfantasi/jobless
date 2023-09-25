import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/shimmerwidget.dart';
import 'package:jobless/core/widgets/vacancy.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/bloc/vacancies/vacancies_cubit.dart';
import 'package:lottie/lottie.dart';

class WidgetVacancies extends StatefulWidget {
  const WidgetVacancies({super.key});

  @override
  State<WidgetVacancies> createState() => _WidgetVacanciesState();
}

class _WidgetVacanciesState extends State<WidgetVacancies> {
  int _currentCarousel = 0;
  final CarouselController _controllerCarousel = CarouselController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacanciesCubit, VacanciesState>(
      builder: (context, state) {
        if ((state is VacanciesInitial) || (state is VacanciesInitial)) {
          return ShimmerWidget(
            height: 110,
            width: MediaQuery.of(context).size.width,
          );
        } else if (state is VacanciesFailure) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Center(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/not-found.json',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width / 5,
                  ),
                  Text(
                    'page error'.tr(),
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  )
                ],
              ),
            ),
          );
        } else if (state is VacanciesLoaded) {
          if (state.vacancies.data.isEmpty) {
            return Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(1, 1), // changes position of shadow
                    ),
                  ]),
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/not-found.json',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.width / 5,
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 123,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                    child: CarouselSlider(
                      options: CarouselOptions(
                          height: 123,
                          autoPlay: true,
                          aspectRatio: 9 / 6,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarousel = index;
                            });
                          }),
                      items: state.vacancies.data.map((dataVacancies) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: InkWell(
                                onTap: () async {
                                  final res = await Navigator.pushNamed(
                                      context, '/vacancy', arguments: {
                                    'vacancy': dataVacancies,
                                    'employee': false
                                  });
                                  if (res != null && res is bool) {
                                    if (!mounted) return;
                                    context.read<VacanciesCubit>().getvacancies(
                                        1,
                                        '&userId[equals]=${context.read<UserCubit>().user!.id}');
                                  }
                                },
                                child: WidgetVacancyContainer(
                                  data: dataVacancies,
                                  employee: false,
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
                    children: state.vacancies.data.asMap().entries.map((entry) {
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
          return ShimmerWidget(
            height: 110,
            width: MediaQuery.of(context).size.width,
          );
        }
      },
    );
  }
}
