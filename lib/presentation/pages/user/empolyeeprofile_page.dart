import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/core/widgets/radiobutton.dart';
import 'package:jobless/presentation/bloc/profile/profile_cubit.dart';
import 'package:jobless/presentation/pages/gallery/gallery_page.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:transparent_image/transparent_image.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  GlobalKey<FormState> formProfileKey = GlobalKey<FormState>();
  List<RadioModel> selectedCategory = [];

  File? photoProfile;
  // Medium? mediumSelected;
  final TextEditingController _textFullNameController = TextEditingController();
  final TextEditingController _textDateController = TextEditingController();
  String dateSend = '';
  final TextEditingController _textAddressController = TextEditingController();
  final TextEditingController _textSkillController = TextEditingController();
  final RoundedLoadingButtonController _btnConfirmController =
      RoundedLoadingButtonController();

  @override
  void didChangeDependencies() {
    selectedCategory =
        ModalRoute.of(context)!.settings.arguments as List<RadioModel>;
    super.didChangeDependencies();
  }

  Future<void> selectDate() async {
    var date = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateSend != '' ? DateTime.parse(dateSend) : DateTime.now(),
        firstDate: DateTime(date.year - 45, date.month, date.day),
        lastDate: DateTime(date.year, date.month, date.day),
        builder: (context, child) {
          return Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.background),
            ),
            child: child!,
          );
        });
    if (picked != null) {
      dateSend = DateFormat('yyyy-MM-dd').format(picked);
      _textDateController.text = DateFormat('dd MMMM yyyy').format(picked);
    }
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
                    Uint8List img = await file.readAsBytes();

                    if (!mounted) return;

                    final res = await Navigator.pushNamed(
                        context, '/crop-image',
                        arguments: {'isProfile': true, 'image': img});
                    if (res != null && res is String) {
                      setState(() {
                        photoProfile = File(res);
                        // mediumSelected = medium;
                      });
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

  Future<void> submitData() async {
    if (!mounted) return;

    BlocProvider.of<EmployeeProfileCubit>(context)
        .patchEmployeeProfile(
            jobcategories: jsonEncode(selectedCategory),
            fullname: _textFullNameController.text,
            dateofbirth: dateSend,
            address: _textAddressController.text,
            skill: _textSkillController.text,
            oldPhoto: '',
            photo: photoProfile)
        .then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, '/');
      }

      _btnConfirmController.reset();
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
                )),
          ),
        ),
        title: Text(
          'profile'.tr(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formProfileKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                photoProfile == null
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
                                'upload photo profile'.tr(),
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
                        height: MediaQuery.of(context).size.width / 5,
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                          // add border
                          border: Border.all(
                            width: 5,
                            color:
                                Theme.of(context).primaryColor.withOpacity(.4),
                          ),
                          // set border radius
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: FadeInImage(
                                    fit: BoxFit.cover,
                                    placeholder: MemoryImage(kTransparentImage),
                                    image: FileImage(photoProfile!),
                                    // image: ThumbnailProvider(
                                    //   mediumId: mediumSelected!.id,
                                    //   mediumType: mediumSelected!.mediumType,
                                    //   highQuality: true,
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              top: 0,
                              child: IconButton(
                                onPressed: () => openMediaModal(),
                                icon: ClipOval(
                                  child: Container(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.8),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                fieldFormData(
                  label: 'fullname'.tr(),
                  texteditor: _textFullNameController,
                  placeholder: 'fullname'.tr(),
                  validator: 'fullname is required'.tr(),
                ),
                fieldFormData(
                  label: 'dateofbirth'.tr(),
                  readOnly: true,
                  texteditor: _textDateController,
                  placeholder: 'dateofbirth'.tr(),
                  validator: 'dateofbirth is required'.tr(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  onTap: () => selectDate(),
                ),
                fieldFormData(
                  label: 'address'.tr(),
                  maxLines: 3,
                  texteditor: _textAddressController,
                  placeholder: 'address'.tr(),
                  validator: 'address is required'.tr(),
                ),
                fieldFormData(
                  label: 'skill'.tr(),
                  texteditor: _textSkillController,
                  placeholder: 'skill'.tr(),
                  validator: 'skill is required'.tr(),
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
                        DateTime yearOld = DateTime.parse(dateSend);
                        DateTime yearCurrent = DateTime.now();
                        if (yearCurrent.year - yearOld.year > 14) {
                          submitData();
                        } else {
                          Fluttertoast.showToast(
                              msg: 'minimum age 15 years'.tr());
                          _btnConfirmController.reset();
                        }
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

  Widget fieldFormData(
      {String? label,
      TextEditingController? texteditor,
      String? validator,
      int? maxLines,
      bool readOnly = false,
      Function()? onTap,
      String? placeholder,
      Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(label!),
          ),
          TextFieldCustom(
            controller: texteditor!,
            maxLines: maxLines,
            readOnly: readOnly,
            validator: MultiValidator([
              RequiredValidator(errorText: validator!),
            ]),
            placeholder: placeholder!,
            suffixIcon: suffixIcon,
            onSubmitted: onTap,
          ),
        ],
      ),
    );
  }
}
