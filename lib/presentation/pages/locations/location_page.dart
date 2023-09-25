import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/loadmore.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/domain/entities/location_entity.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late StreamSubscription<LocationState> streamLocation;
  final TextEditingController _textSearchController = TextEditingController();
  Timer? _debounce;
  List<ResultLocationEntity> locations = [];

  bool isLastPage = false;
  bool isLoadMore = false;
  int page = 1;

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  void dispose() {
    streamLocation.cancel();
    super.dispose();
  }

  void getLocation() async {
    locations.clear();
    setState(() {
      isLastPage = false;
      page = 1;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<LocationCubit>().getLocation(page, 20, '');
    streamLocation = context.read<LocationCubit>().stream.listen((event) {
      if (event is LocationLoaded) {
        for (var e in event.location.data) {
          locations.add(ResultLocationEntity(
              id: e.id, location: e.location, checked: e.checked));
        }
        if (event.location.data.isEmpty) {
          isLastPage = true;
        }
      }
    });
  }

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      locations.clear();
      setState(() {
        isLastPage = false;
        page = 1;
      });
      context
          .read<LocationCubit>()
          .getLocation(page, 20, '&location[contains]=$query');
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                  )),
            )),
        title: Text(
          'location'.tr(),
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
            child: BlocBuilder<LocationCubit, LocationState>(
              builder: (context, state) {
                if (state is LocationLoading && !isLoadMore) {
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
                        context.read<LocationCubit>().getLocation(page, 10, '');
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
                        locations.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 2.0),
                          child: ListTile(
                            style: ListTileStyle.drawer,
                            onTap: () => Navigator.pop(context, locations[i]),
                            title: Text(locations[i].location!),
                            trailing:
                                const Icon(Icons.arrow_forward_ios_rounded),
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
