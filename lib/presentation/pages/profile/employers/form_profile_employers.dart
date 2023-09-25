import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/fieldformdata.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/popover.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/data/model/companysize.dart';
import 'package:jobless/data/model/imagesupload.dart';
import 'package:jobless/data/model/industries.dart';
import 'package:jobless/data/model/location.dart';
import 'package:jobless/data/model/user.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
import 'package:jobless/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:jobless/presentation/bloc/industries/industries_cubit.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';
import 'package:jobless/presentation/bloc/profile/profile_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/pages/gallery/gallery_page.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class FormProfileEmployers extends StatefulWidget {
  const FormProfileEmployers({super.key});

  @override
  State<FormProfileEmployers> createState() => _FormProfileEmployersState();
}

class _FormProfileEmployersState extends State<FormProfileEmployers>
    with SingleTickerProviderStateMixin {
  StreamSubscription<GalleryState>? streamGallery;

  late TabController _tabController;
  final selectedColor = Config().appThemeColor;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _textCompanyNameController =
      TextEditingController();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textIndustrialTypeController =
      TextEditingController();
  String? industryId = '';
  String? industrytypeId = '';
  final TextEditingController _textLocationController = TextEditingController();
  List<CompanySizeModel> companySizeList = [];
  final TextEditingController _textSizeCompanyController =
      TextEditingController();
  final TextEditingController _textWebsiteController = TextEditingController();
  final TextEditingController _textAddressController = TextEditingController();
  final TextEditingController _textDescController = TextEditingController();

  final TextEditingController _textSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnConfirmController =
      RoundedLoadingButtonController();

  int page = 1;
  int limit = 15;
  bool isLoadedIndustry = false;
  bool isLoadedLocation = false;
  Timer? _debounce;

  List<Object> gallery = [];
  bool openTab = true;

  final _tabs = [
    Tab(
      child: Text(
        'about us'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    Tab(
      child: Text(
        'gallery'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  ];

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<LocationCubit>(context).getLocation(
          page, limit, '&location[contains]=${_textSearchController.text}');
      isLoadedLocation = false;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    companySizeList.add(CompanySizeModel(false, '0 - 50'));
    companySizeList.add(CompanySizeModel(false, '51 - 200'));
    companySizeList.add(CompanySizeModel(false, '201 - 500'));
    companySizeList.add(CompanySizeModel(false, '501 - 1000'));
    companySizeList.add(CompanySizeModel(false, '> 1000'));
    getFieldEmployers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    gallery.clear();
    streamGallery?.cancel();
    _tabController.dispose();
  }

  void getFieldEmployers() {
    ResultUserModel user = context.read<UserCubit>().user!;
    _textCompanyNameController.text = user.employersProfile!.companyname!;
    _textEmailController.text = user.employersProfile!.email!;
    _textLocationController.text = user.employersProfile!.officelocation!;
    _textIndustrialTypeController.text =
        user.employersProfile!.industrialType!.industry!.industry!;
    industryId = user.employersProfile!.industrialType!.industry!.id!;
    industrytypeId = user.employersProfile!.industrialType!.id;
    for (var e in companySizeList) {
      if (e.text == user.employersProfile!.companysize!) {
        e.isSelected = true;
      }
    }
    if (companySizeList
        .where((element) => element.isSelected == true)
        .isNotEmpty) {
      _textSizeCompanyController.text =
          '${companySizeList.firstWhere((element) => element.isSelected == true).text} ${'employees'.tr()}';
    }

    _textAddressController.text = user.employersProfile!.address!;
    _textWebsiteController.text = user.employersProfile!.website!;
    _textDescController.text = user.employersProfile!.desc!;
  }

  Future<void> getFileImage(
      {required int index,
      required String file,
      required String imageUrl,
      required bool add,
      required bool reupload}) async {
    if (reupload && !add) {
      ImageUploadModel imageUpload = ImageUploadModel(
          isUploaded: false,
          uploading: true,
          imageUrl: imageUrl,
          imageFile: file);
      setState(() {
        gallery.replaceRange(index, index + 1, [imageUpload]);
      });
      context
          .read<EmployeeProfileCubit>()
          .patchGalleryEmployers(
              employersId: context.read<UserCubit>().user!.employersProfile!.id,
              file: File(file),
              oldFile: '')
          .then((value) {
        if (value != null) {
          if (value.error == null) {
            setState(() {
              imageUpload.id = value.data;
              imageUpload.uploading = false;
              imageUpload.isUploaded = true;
              if (add) gallery.add('add photo'.tr());
            });
          } else {
            setState(() {
              imageUpload.uploading = false;
            });
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            Fluttertoast.showToast(msg: value.message);
          });
        }
      });
    } else {
      ImageUploadModel imageUpload = ImageUploadModel(
          isUploaded: false,
          uploading: true,
          imageUrl: imageUrl,
          imageFile: file);
      setState(() {
        gallery.replaceRange(index, index + 1, [imageUpload]);
      });
      context
          .read<EmployeeProfileCubit>()
          .patchGalleryEmployers(
              employersId: context.read<UserCubit>().user!.employersProfile!.id,
              file: File(file),
              oldFile: '')
          .then((value) {
        if (value != null) {
          if (value.error == null) {
            setState(() {
              imageUpload.id = value.data;
              imageUpload.uploading = false;
              imageUpload.isUploaded = true;
              if (add) gallery.add('add photo'.tr());
            });
          } else {
            setState(() {
              imageUpload.uploading = false;
              if (add) gallery.add('add photo'.tr());
            });
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            Fluttertoast.showToast(msg: value.message);
          });
        }
      });
    }
  }

  void getGallery() {
    gallery.clear();
    if (!mounted) return;

    context
        .read<GalleryCubit>()
        .getGallery(context.read<UserCubit>().user!.employersProfile!.id!);
    streamGallery = context.read<GalleryCubit>().stream.listen((event) {
      if (openTab) gallery.clear();

      if (event is GalleryLoaded) {
        for (var e in event.gallery.data) {
          ImageUploadModel imageUpload = ImageUploadModel(
              id: e.id,
              isUploaded: true,
              uploading: false,
              imageUrl: e.image,
              imageFile: '');
          gallery.add(imageUpload);
        }
        setState(() {
          openTab = false;
          if (gallery.length < 5) gallery.add('add photo'.tr());
        });
      }
    });
  }

  void deleteGallery(int index) {
    Navigator.pop(context);
    try {
      if (gallery[index] is ImageUploadModel) {
        ImageUploadModel uploadModel = gallery[index] as ImageUploadModel;
        if (!uploadModel.isUploaded!) {
          if (gallery.length > 1) {
            setState(() {
              gallery.removeAt(index);
            });
            if (gallery.length < 6) {
              List<bool> addphoto = [];
              for (var e in gallery) {
                addphoto.add(e is ImageUploadModel);
              }
              if (addphoto.where((element) => element == false).isEmpty) {
                setState(() {
                  gallery.add('add photo'.tr());
                });
              }
            }
          } else {
            setState(() {
              gallery.replaceRange(index, index + 1, ['add photo'.tr()]);
            });
          }
        } else {
          context
              .read<GalleryCubit>()
              .deleteGallery(id: uploadModel.id)
              .then((value) {
            if (value) {
              if (gallery.length > 1) {
                setState(() {
                  gallery.removeAt(index);
                });
                if (gallery.length < 6) {
                  List<bool> addphoto = [];
                  for (var e in gallery) {
                    addphoto.add(e is ImageUploadModel);
                  }
                  if (addphoto.where((element) => element == false).isEmpty) {
                    setState(() {
                      gallery.add('add photo'.tr());
                    });
                  }
                }
              } else {
                setState(() {
                  gallery.replaceRange(index, index + 1, ['add photo'.tr()]);
                });
              }
            }
          });
        }
      }
    } catch (_) {}
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
              industrytypeId: industrytypeId,
              companySize: companySizeList
                  .firstWhere((element) => element.isSelected == true)
                  .text,
              website: _textWebsiteController.text,
              desc: _textDescController.text,
              officelocation: _textLocationController.text,
              oldFile: '')
          .then((value) {
        if (value) {
          Fluttertoast.showToast(
              msg: context.read<EmployeeProfileCubit>().result!.message);
          context.read<AuthCubit>().isSignIn();
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context, true);
          });
        }

        _btnConfirmController.reset();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
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
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: kToolbarHeight - 8.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    color: selectedColor),
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                onTap: (int value) {
                  if (value == 1) {
                    getGallery();
                  } else {
                    streamGallery?.cancel();
                  }
                },
                tabs: _tabs,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  tabAboutUs(),
                  tabGallery(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: openTab
          ? const Center(
              child: LoadingWidget(),
            )
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: (2 / 1.3),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: List.generate(
                  (gallery.length > 5) ? gallery.length - 1 : gallery.length,
                  (index) {
                if (gallery[index] is ImageUploadModel) {
                  ImageUploadModel uploadModel =
                      gallery[index] as ImageUploadModel;
                  return Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.05,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                              color: Colors.blue.shade100, width: .5),
                          color: Colors.white,
                          // image: DecorationImage(
                          //   fit: BoxFit.cover,
                          //   image: MemoryImage(uploadModel.imageUrl!),
                          // ),
                        ),
                        child: uploadModel.uploading!
                            ? const LoadingWidget(
                                fallingDot: true,
                              )
                            : SizedBox(
                                width: double.infinity / 3.2,
                                height: double.infinity / 3.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: uploadModel.imageFile == ''
                                      ? CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              '${Config.baseUrl}/${Config.imageGallery}/${uploadModel.imageUrl!}',
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              const Center(
                                            child:
                                                LoadingWidget(fallingDot: true),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(8)),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 8.0),
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              child: Icon(
                                                Icons.file_upload_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          File(uploadModel.imageFile!),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                      ),
                      Visibility(
                        visible:
                            !uploadModel.isUploaded! && !uploadModel.uploading!,
                        child: Positioned(
                          right: 0,
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: IconButton(
                            onPressed: () => getFileImage(
                                file: uploadModel.imageFile!,
                                imageUrl: uploadModel.imageUrl!,
                                index: index,
                                add: false,
                                reupload: true),
                            icon: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                color: Theme.of(context).disabledColor,
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 5,
                        bottom: 5,
                        child: Icon(Icons.image, color: Colors.white, size: 12),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          child: const Icon(
                            Icons.remove_circle,
                            size: 20,
                            color: Colors.red,
                          ),
                          onTap: () => showModalBottomSheet<int>(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return Popover(
                                child: Column(
                                  children: [
                                    Text(
                                      'deleted'.tr(),
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 18.0,
                                    ),
                                    Text('deleted desc'.tr()),
                                    const SizedBox(
                                      height: 24.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryIconTheme
                                                        .color!
                                                        .withOpacity(.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                elevation: 15.0,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'no'.tr(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12.0,
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  deleteGallery(index),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryIconTheme
                                                        .color,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                elevation: 15.0,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'yes'.tr(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  if (gallery.length > 5) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: MediaQuery.of(context).size.width / 2.05,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          color: Theme.of(context).primaryIconTheme.color!,
                          width: .5),
                    ),
                    child: InkWell(
                      onTap: () {
                        openMediaModal(index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          Text(gallery[index].toString())
                        ],
                      ),
                    ),
                  );
                }
              }),
            ),
    );
  }

  Widget tabAboutUs() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
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
                RequiredValidator(errorText: 'companyemail is required'.tr())
              ]),
            ),
            FieldFormData(
              label: 'industrialtype'.tr(),
              texteditor: _textIndustrialTypeController,
              readOnly: true,
              suffixIcon: const Icon(Icons.expand_more_rounded),
              placeholder: 'industrialtype'.tr(),
              validators: MultiValidator([
                RequiredValidator(errorText: 'industrialtype is required'.tr())
              ]),
              onTap: () {
                showButtomSheetIndustry();

                if (!isLoadedIndustry) {
                  BlocProvider.of<IndustriesCubit>(context)
                      .getIndustries(1, 100);
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
                RequiredValidator(errorText: 'officelocation is required'.tr())
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
                RequiredValidator(errorText: 'company size is required'.tr())
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
                RequiredValidator(errorText: 'companyaddress is required'.tr())
              ]),
            ),
            FieldFormData(
              label: 'desc'.tr(),
              texteditor: _textDescController,
              maxLines: 5,
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
                  if (formKey.currentState!.validate()) {
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
    );
  }

  Future<void> openMediaModal(int index) async {
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

                    Uint8List img = await file.readAsBytes();

                    if (!mounted) return;

                    final res = await Navigator.pushNamed(
                        context, '/crop-image',
                        arguments: {'isProfile': false, 'image': img});
                    if (res != null && res is String) {
                      getFileImage(
                          file: res,
                          imageUrl: '',
                          index: index,
                          add: true,
                          reupload: false);
                    }
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
                          isLoadedIndustry = true;
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
                          isLoadedLocation = true;
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
