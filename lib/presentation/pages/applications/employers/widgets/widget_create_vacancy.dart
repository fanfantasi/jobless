import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:delta_to_html/delta_to_html.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text, Style;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/buttomsheetcategories.dart';
import 'package:jobless/core/widgets/buttomsheetlocation.dart';
import 'package:jobless/core/widgets/buttomsheettypeVacancy.dart';
import 'package:jobless/core/widgets/fieldformdata.dart';
import 'package:jobless/core/widgets/showmodalbuttomsheet.dart';
import 'package:jobless/core/widgets/thousandseparator.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/presentation/bloc/categories/categories_cubit.dart';
import 'package:jobless/presentation/bloc/location/location_cubit.dart';
import 'package:jobless/presentation/bloc/postdata/postdata_cubit.dart';
import 'package:jobless/presentation/bloc/typevacancy/typevacancy_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:jobless/presentation/pages/gallery/gallery_page.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:transparent_image/transparent_image.dart';

import 'widget_requirements.dart';

class WidgetCreateVacancy extends StatefulWidget {
  const WidgetCreateVacancy({super.key});

  @override
  State<WidgetCreateVacancy> createState() => _WidgetCreateVacancyState();
}

class _WidgetCreateVacancyState extends State<WidgetCreateVacancy> {
  GlobalKey<FormState> formCreateKey = GlobalKey<FormState>();
  List<ResultRequirementsEntity> requirements = [];

  final TextEditingController _textTitleController = TextEditingController();
  final TextEditingController _textPositionController = TextEditingController();
  final TextEditingController _textPositionIdController =
      TextEditingController();
  final TextEditingController _textSearchPositionController =
      TextEditingController();
  final TextEditingController _textSalaryController = TextEditingController();
  final TextEditingController _textLocationController = TextEditingController();
  final TextEditingController _textLocationIdController =
      TextEditingController();
  final TextEditingController _textTypeController = TextEditingController();
  final TextEditingController _textTypeIdController = TextEditingController();
  final TextEditingController _textLinkExternalController =
      TextEditingController();
  final TextEditingController _textSearchTypeController =
      TextEditingController();

  final RoundedLoadingButtonController _btnNextController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnApplyController =
      RoundedLoadingButtonController();

  final QuillController quillController = QuillController.basic();
  final FocusNode editorFocusNode = FocusNode();

  final TextEditingController _textSearchLocationController =
      TextEditingController();
  File? photoCompany;
  Medium? mediumSelected;

  Timer? _debounce;
  int page = 1;
  int limit = 15;

  bool nextPage = false;

  @override
  void initState() {
    Config.isLoadedLocation = false;
    _textSalaryController.text = '0';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    quillController.dispose();
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

  _onSearchChangedLocation(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<LocationCubit>(context).getLocation(page, limit,
          '&location[contains]=${_textSearchLocationController.text}');
      Config.isLoadedLocation = false;
    });
  }

  _onSearchChangedCategories(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<CategoriesCubit>(context).getcategories(page, limit,
          '&category[contains]=${_textSearchPositionController.text}');
      Config.isLoadedLocation = false;
    });
  }

  _onSearchChangedType(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<TypeVacancyCubit>(context).gettypevacancy(
          page, limit, '&type[contains]=${_textSearchTypeController.text}');
      Config.isLoadedTypeVacancy = false;
    });
  }

  Future<void> submitData() async {
    try {
      if (!mounted) return;
      BlocProvider.of<PostDataCubit>(context)
          .patchVacancy(
              id: '',
              title: _textTitleController.text,
              categoriId: _textPositionIdController.text,
              salary: _textSalaryController.text.replaceAll(',', ''),
              locationId: _textLocationIdController.text,
              typevacancyId: _textTypeIdController.text,
              desc: DeltaToHTML.encodeJson(
                quillController.document.toDelta().toJson(),
              ),
              requirements: jsonEncode(requirements),
              linkexternal:
                  context.read<UserCubit>().user!.administrator! == true
                      ? _textLinkExternalController.text
                      : null,
              oldFile: '',
              file: photoCompany)
          .then((value) {
        if (value) {
          if (!mounted) return;

          showButtomSheetInfo(
              context: context, success: true, desc: 'job vacancy posted'.tr());
        } else {
          if (!mounted) return;
          showButtomSheetInfo(
              context: context,
              success: false,
              desc: 'job vacancy failed desc'.tr());
        }
      });
    } catch (_) {
      _btnApplyController.reset();
    }
  }

  Future<bool> _onWillPop() async {
    if (nextPage) {
      setState(() {
        nextPage = false;
      });
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                if (nextPage) {
                  setState(() {
                    nextPage = false;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
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
            'create vacancy'.tr(),
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: nextPage
                ? WidgetRequirements(
                    requirement: requirements,
                  )
                : Form(
                    key: formCreateKey,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          height: MediaQuery.of(context).size.width / 5,
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                            // add border
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.8),
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.2),
                            // set border radius
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: mediumSelected != null
                                      ? FadeInImage(
                                          fit: BoxFit.cover,
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          image: ThumbnailProvider(
                                            mediumId: mediumSelected!.id,
                                            mediumType:
                                                mediumSelected!.mediumType,
                                            highQuality: true,
                                          ),
                                        )
                                      : FadeInImage(
                                          fit: BoxFit.fill,
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          image: NetworkImage(
                                              '${Config.baseUrl}/${Config.imageEmployers}/${context.read<UserCubit>().user!.employersProfile!.photo ?? ''}'),
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/icons/logo-empty.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
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
                              ),
                              Visibility(
                                visible: mediumSelected != null,
                                child: Positioned(
                                  top: -15,
                                  right: -15,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        mediumSelected = null;
                                        photoCompany = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        FieldFormData(
                          label: 'title'.tr(),
                          texteditor: _textTitleController,
                          placeholder: 'title'.tr(),
                          validators: MultiValidator([
                            RequiredValidator(
                                errorText: 'title is required'.tr())
                          ]),
                        ),
                        FieldFormData(
                          label: 'open position'.tr(),
                          texteditor: _textPositionController,
                          suffixIcon: const Icon(Icons.expand_more_rounded),
                          readOnly: true,
                          placeholder: 'open position'.tr(),
                          validators: MultiValidator([
                            RequiredValidator(
                                errorText: 'open position is required'.tr())
                          ]),
                          onTap: () async {
                            showModalCategories(context,
                                categoryId: _textPositionIdController,
                                category: _textPositionController,
                                search: _textSearchPositionController,
                                onChange: _onSearchChangedCategories);
                            if (!Config.isLoadedCategories) {
                              BlocProvider.of<CategoriesCubit>(context)
                                  .getcategories(page, limit, '');
                            }
                          },
                        ),
                        FieldFormData(
                          label: 'salary'.tr(),
                          texteditor: _textSalaryController,
                          keyboardType: TextInputType.number,
                          placeholder: 'salary'.tr(),
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          validators: MultiValidator([
                            RequiredValidator(
                                errorText: 'salary is required'.tr()),
                            PatternValidator(r'^([0-9])',
                                errorText: 'salary only number')
                          ]),
                        ),
                        FieldFormData(
                          label: 'location'.tr(),
                          texteditor: _textLocationController,
                          suffixIcon: const Icon(Icons.expand_more_rounded),
                          readOnly: true,
                          placeholder: 'location'.tr(),
                          validators: MultiValidator([
                            RequiredValidator(
                                errorText: 'location is required'.tr())
                          ]),
                          onTap: () async {
                            showModalLocation(context,
                                locationId: _textLocationIdController,
                                location: _textLocationController,
                                search: _textSearchLocationController,
                                onChange: _onSearchChangedLocation);
                            if (!Config.isLoadedLocation) {
                              BlocProvider.of<LocationCubit>(context)
                                  .getLocation(page, limit, '');
                            }
                          },
                        ),
                        FieldFormData(
                          label: 'type job'.tr(),
                          texteditor: _textTypeController,
                          suffixIcon: const Icon(Icons.expand_more_rounded),
                          readOnly: true,
                          placeholder: 'type job'.tr(),
                          validators: MultiValidator([
                            RequiredValidator(
                                errorText: 'type job is required'.tr())
                          ]),
                          onTap: () async {
                            showModalTypeVacancy(context,
                                typeId: _textTypeIdController,
                                type: _textTypeController,
                                search: _textSearchTypeController,
                                onChange: _onSearchChangedType);
                            if (!Config.isLoadedTypeVacancy) {
                              BlocProvider.of<TypeVacancyCubit>(context)
                                  .gettypevacancy(page, limit, '');
                            }
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('desc'.tr()),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: .5,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.2),
                                  ),
                                  borderRadius: BorderRadius.circular(16.0)),
                              child: InkWell(
                                onTap: () async {
                                  final res = await Navigator.pushNamed(
                                      context, '/text-editor', arguments: {
                                    'title': 'message',
                                    'controller': quillController
                                  });
                                  if (res != null && res is bool) {
                                    setState(() {});
                                  }
                                },
                                child: Html(
                                  data: DeltaToHTML.encodeJson(
                                    quillController.document.toDelta().toJson(),
                                  ),
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
                                          .withOpacity(.8),
                                    ),
                                    'ol': Style(
                                      padding: HtmlPaddings.only(left: 18.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(.8),
                                    )
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                              context.read<UserCubit>().user!.administrator!,
                          child: FieldFormData(
                            label: 'Link',
                            texteditor: _textLinkExternalController,
                            placeholder: 'Link',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: nextPage
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: kToolbarHeight,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            nextPage = false;
                          });
                        },
                        icon: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 6.0),
                            color:
                                Theme.of(context).primaryColor.withOpacity(.1),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 28,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 110,
                      child: RoundedLoadingButton(
                        animateOnTap: true,
                        errorColor: Colors.red.shade200,
                        controller: _btnApplyController,
                        onPressed: () {
                          submitData();
                        },
                        borderRadius: 22,
                        elevation: 0,
                        color: Theme.of(context).primaryColor,
                        height: kToolbarHeight - 12,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Text(
                          'post job vacancy'.tr(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: RoundedLoadingButton(
                  animateOnTap: false,
                  errorColor: Colors.red.shade200,
                  controller: _btnNextController,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (formCreateKey.currentState!.validate()) {
                      // submitData();
                      setState(() {
                        nextPage = true;
                      });
                    } else {
                      _btnNextController.error();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _btnNextController.reset();
                      });
                    }
                  },
                  borderRadius: 22,
                  elevation: 0,
                  color: Theme.of(context).primaryColor,
                  height: kToolbarHeight - 12,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'next'.tr(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
      ),
    );
  }
}
