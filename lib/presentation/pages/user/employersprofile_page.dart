import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/widgets/fieldformdata.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/data/model/companysize.dart';
import 'package:jobless/data/model/industries.dart';
import 'package:jobless/data/model/location.dart';
import 'package:jobless/presentation/bloc/industries/industries_cubit.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';
import 'package:jobless/presentation/bloc/profile/profile_cubit.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:transparent_image/transparent_image.dart';

import '../gallery/gallery_page.dart';

class EmployersProfilePage extends StatefulWidget {
  const EmployersProfilePage({super.key});

  @override
  State<EmployersProfilePage> createState() => _EmployersProfilePageState();
}

class _EmployersProfilePageState extends State<EmployersProfilePage> {
  GlobalKey<FormState> formProfileKey = GlobalKey<FormState>();

  int page = 1;
  int limit = 15;
  bool isLoadedIndustry = false;
  bool isLoadedLocation = false;
  Timer? _debounce;

  File? photoCompany;
  Medium? mediumSelected;

  final TextEditingController _textCompanyNameController =
      TextEditingController();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textIndustrialTypeController =
      TextEditingController();
  String? industryId = '';
  final TextEditingController _textLocationController = TextEditingController();
  final TextEditingController _textSizeCompanyController =
      TextEditingController();
  List<CompanySizeModel> companySizeList = [];
  final TextEditingController _textWebsiteController = TextEditingController();
  final TextEditingController _textAddressController = TextEditingController();
  final TextEditingController _textDescController = TextEditingController();
  final TextEditingController _textSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnConfirmController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    companySizeList.add(CompanySizeModel(false, '0 - 50'));
    companySizeList.add(CompanySizeModel(false, '51 - 200'));
    companySizeList.add(CompanySizeModel(false, '201 - 500'));
    companySizeList.add(CompanySizeModel(false, '501 - 1000'));
    companySizeList.add(CompanySizeModel(false, '> 1000'));
    super.initState();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<LocationCubit>(context).getLocation(
          page, limit, '&location[contains]=${_textSearchController.text}');
      isLoadedLocation = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> submitData() async {
    try {
      if (!mounted) return;

      BlocProvider.of<EmployeeProfileCubit>(context)
          .patchEmployersProfile(
              email: _textEmailController.text,
              companyname: _textCompanyNameController.text,
              address: _textAddressController.text,
              industryId: industryId,
              industrytypeId: '',
              officelocation: _textLocationController.text,
              companySize: companySizeList
                  .firstWhere((element) => element.isSelected == true)
                  .text,
              website: _textWebsiteController.text,
              desc: _textDescController.text,
              oldFile: '',
              file: photoCompany)
          .then((value) {
        if (value) {
          Navigator.pushReplacementNamed(context, '/');
        }

        _btnConfirmController.reset();
        Fluttertoast.showToast(
            msg: context.read<EmployeeProfileCubit>().result!.message);
      });
    } catch (_) {}
  }

  Future<void> openMediaModal() async {
    final action = CupertinoActionSheet(
      actions: [
        Material(
          child: Column(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_camera,
                          color: Colors.blue[400]),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "camera".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  Medium? medium = await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const GalleryPage(),
                    ),
                  );
                  if (medium != null) {
                    final File file = await medium.getFile();
                    setState(() {
                      photoCompany = file;
                      mediumSelected = medium;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_fill_on_rectangle_fill,
                          color: Colors.blue[400]),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "gallery".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "cancel".tr(),
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
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
                )),
          ),
        ),
        title: Text(
          'organization profile'.tr(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formProfileKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                photoCompany == null
                    ? Container(
                        margin: const EdgeInsets.all(16.0),
                        height: MediaQuery.of(context).size.height / 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.1)),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, .5),
                              blurRadius: 4,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => openMediaModal(),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.1),
                                  radius: 30,
                                  child: Icon(Icons.cloud_upload_rounded,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'upload company logo'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.4)),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.width / 4,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          // add border
                          border: Border.all(
                            width: 5,
                            color:
                                Theme.of(context).primaryColor.withOpacity(.8),
                          ),
                          // set border radius
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: FadeInImage(
                                  fit: BoxFit.cover,
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: ThumbnailProvider(
                                    mediumId: mediumSelected!.id,
                                    mediumType: mediumSelected!.mediumType,
                                    highQuality: true,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () => openMediaModal(),
                                icon: ClipOval(
                                  child: Container(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.2),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary
                                          .withOpacity(.5),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                FieldFormData(
                  label: 'companyname'.tr(),
                  texteditor: _textCompanyNameController,
                  placeholder: 'companyname'.tr(),
                  validators: MultiValidator([
                    RequiredValidator(errorText: 'companyname is required'.tr())
                  ]),
                ),
                FieldFormData(
                  label: 'companyemail'.tr(),
                  texteditor: _textEmailController,
                  placeholder: 'companyemail'.tr(),
                  suffixIcon: const Icon(Icons.mail),
                  validators: MultiValidator([
                    RequiredValidator(
                        errorText: 'companyemail is required'.tr())
                  ]),
                ),
                FieldFormData(
                  label: 'industrialtype'.tr(),
                  texteditor: _textIndustrialTypeController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.expand_more_rounded),
                  placeholder: 'industrialtype'.tr(),
                  validators: MultiValidator([
                    RequiredValidator(
                        errorText: 'industrialtype is required'.tr())
                  ]),
                  onTap: () {
                    showButtomSheetIndustry();

                    if (!isLoadedIndustry) {
                      BlocProvider.of<IndustriesCubit>(context)
                          .getIndustries(page, 100);
                    }
                  },
                ),
                FieldFormData(
                  label: 'officelocation'.tr(),
                  texteditor: _textLocationController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.expand_more_rounded),
                  placeholder: 'officelocation'.tr(),
                  validators: MultiValidator([
                    RequiredValidator(
                        errorText: 'officelocation is required'.tr())
                  ]),
                  onTap: () {
                    showButtomSheetLocation();

                    if (!isLoadedLocation) {
                      BlocProvider.of<LocationCubit>(context)
                          .getLocation(page, limit, '');
                    }
                  },
                ),
                FieldFormData(
                  label: 'company size'.tr(),
                  texteditor: _textSizeCompanyController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.expand_more_rounded),
                  placeholder: 'company size'.tr(),
                  validators: MultiValidator([
                    RequiredValidator(
                        errorText: 'company size is required'.tr())
                  ]),
                  onTap: () {
                    showButtomSheetCompanySize();
                  },
                ),
                FieldFormData(
                  label: 'companyaddress'.tr(),
                  texteditor: _textAddressController,
                  maxLines: 3,
                  placeholder: 'companyaddress'.tr(),
                  validators: MultiValidator([
                    RequiredValidator(
                        errorText: 'companyaddress is required'.tr())
                  ]),
                ),
                FieldFormData(
                  label: 'desc'.tr(),
                  texteditor: _textDescController,
                  maxLines: 3,
                  placeholder: 'desc'.tr(),
                ),
                FieldFormData(
                  label: 'website'.tr(),
                  texteditor: _textWebsiteController,
                  placeholder: 'website'.tr(),
                  suffixIcon: const Icon(Icons.public),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RoundedLoadingButton(
                    animateOnTap: true,
                    errorColor: Colors.red.shade200,
                    controller: _btnConfirmController,
                    onPressed: () async {
                      if (!context.mounted) return;

                      FocusScope.of(context).unfocus();
                      if (formProfileKey.currentState!.validate()) {
                        submitData();
                      } else {
                        _btnConfirmController.error();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _btnConfirmController.reset();
                        });
                      }
                    },
                    borderRadius: 16,
                    elevation: 0,
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'confirm'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showButtomSheetCompanySize() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 1,
            minChildSize: 0.25,
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
                      'company size'.tr(),
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Expanded(
                      child: ListView.separated(
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
                        itemCount: companySizeList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              trailing: companySizeList[index].isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.green,
                                    )
                                  : SizedBox.fromSize(),
                              title: Text(
                                '${companySizeList[index].text} ${'employees'.tr()}',
                                style: TextStyle(
                                    fontWeight:
                                        companySizeList[index].isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: companySizeList[index].isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(.5)),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _textSizeCompanyController.text =
                                    '${companySizeList[index].text} ${'employees'.tr()}';
                                for (var i = 0;
                                    i < companySizeList.length;
                                    i++) {
                                  companySizeList[i].isSelected = false;
                                }
                                companySizeList[index].isSelected = true;
                              });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showButtomSheetIndustry() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 1,
            minChildSize: 0.25,
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
                      'industrialtype'.tr(),
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Expanded(
                        child: BlocBuilder<IndustriesCubit, IndustriesState>(
                      builder: (context, state) {
                        if (state is IndustriesLoading) {
                          return const Center(
                            child: LoadingWidget(),
                          );
                        } else if (state is IndustriesLoaded) {
                          if (state.industries.data.isNotEmpty) {
                            isLoadedIndustry = true;
                          } else {
                            isLoadedIndustry = false;
                          }

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
                            itemCount: state.industries.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  trailing:
                                      state.industries.data[index].checked!
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.green,
                                            )
                                          : SizedBox.fromSize(),
                                  title: Text(
                                    state.industries.data[index].industry!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: state
                                                .industries.data[index].checked!
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
                                    _textIndustrialTypeController.text =
                                        state.industries.data[index].industry!;
                                    industryId =
                                        state.industries.data[index].id;
                                    for (var i = 0;
                                        i < state.industries.data.length;
                                        i++) {
                                      state.industries.data[i] =
                                          ResultIndustriesModel.fromJSON({
                                        'id': state.industries.data[i].id,
                                        'industry':
                                            state.industries.data[i].industry,
                                        'checked': false
                                      });
                                    }
                                    state.industries.data[index] =
                                        ResultIndustriesModel.fromJSON({
                                      'id': state.industries.data[index].id,
                                      'industry':
                                          state.industries.data[index].industry,
                                      'checked': true
                                    });
                                  });
                            },
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child:
                                    SvgPicture.asset('assets/icons/empty.svg'),
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
    );
  }

  void showButtomSheetLocation() {
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
                      'officelocation'.tr(),
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    TextFieldCustom(
                      controller: _textSearchController,
                      placeholder: 'officelocation'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _textSearchController.clear();
                            BlocProvider.of<LocationCubit>(context)
                                .getLocation(page, limit, '');
                          },
                          icon: const Icon(Icons.clear)),
                      onChange: _onSearchChanged,
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Expanded(child: BlocBuilder<LocationCubit, LocationState>(
                      builder: (context, state) {
                        if (state is LocationLoading) {
                          return const Center(
                            child: LoadingWidget(),
                          );
                        } else if (state is LocationLoaded) {
                          if (state.location.data.isNotEmpty) {
                            isLoadedLocation = true;
                          } else {
                            isLoadedLocation = false;
                          }

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
                            itemCount: state.location.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  trailing: state.location.data[index].checked!
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.green,
                                        )
                                      : SizedBox.fromSize(),
                                  title: Text(
                                    state.location.data[index].location!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            state.location.data[index].checked!
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
                                    _textLocationController.text =
                                        state.location.data[index].location!;
                                    for (var i = 0;
                                        i < state.location.data.length;
                                        i++) {
                                      state.location.data[i] =
                                          ResultLocationModel.fromJSON({
                                        'id': state.location.data[i].id,
                                        'location':
                                            state.location.data[i].location,
                                        'checked': false
                                      });
                                    }
                                    state.location.data[index] =
                                        ResultLocationModel.fromJSON({
                                      'id': state.location.data[index].id,
                                      'location':
                                          state.location.data[index].location,
                                      'checked': true
                                    });
                                  });
                            },
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child:
                                    SvgPicture.asset('assets/icons/empty.svg'),
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
    );
  }
}
