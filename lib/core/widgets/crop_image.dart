import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/presentation/bloc/profile/profile_cubit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:path_provider/path_provider.dart';

class CropImage extends StatefulWidget {
  const CropImage({super.key});

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final RoundedLoadingButtonController _btnCropController =
      RoundedLoadingButtonController();
  final _cropController = CropController();
  Uint8List? image;
  File? fileSaved;
  bool isProfile = false;

  Uint8List? croppedImage;
  var isCropping = false;
  var isCircleUi = false;
  var statusText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    var arg = ModalRoute.of(context)!.settings.arguments as Map;
    isProfile = arg['isProfile'] ?? false;
    image = arg['image'];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updatePhotoProfile() async {
    await context
        .read<EmployeeProfileCubit>()
        .patchPhotoProfileEmployers(
            file: fileSaved,
            oldFile: context.read<UserCubit>().user!.employersProfile!.photo)
        .then((value) async {
      if (value.error == null) {
        Fluttertoast.showToast(msg: value.message);
        await context.read<AuthCubit>().isSignIn();
        _btnCropController.reset();
        if (!mounted) return;

        context.read<UserCubit>().initialUser();

        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(msg: value.message);
        _btnCropController.reset();

        Navigator.pop(context, false);
      }
    });
  }

  Rect allowedCropArea = Rect.fromLTWH(0, 0, 0, 0);

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
        title: Text(
          statusText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Crop(
          progressIndicator: const LoadingWidget(fallingDot: true),
          controller: _cropController,
          image: image!,
          onCropped: (croppedData) async {
            setState(() {
              croppedImage = croppedData;
              isCropping = false;
            });

            _btnCropController.reset();

            final tempDir = await getTemporaryDirectory();
            File file = await File(
                    '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg')
                .create();
            file.writeAsBytesSync(croppedImage!);
            fileSaved = file;
            if (!mounted) return;
            Navigator.pop(context, file.path);
            // if (isProfile) {
            //   // updatePhotoProfile();
            //   if (!mounted) return;
            //   Navigator.pop(context, file.path);
            // } else {
            //   if (!mounted) return;
            //   Navigator.pop(context, file.path);
            // }
          },
          withCircleUi: isCircleUi,
          onStatusChanged: (status) => setState(() {
                statusText = <CropStatus, String>{
                      CropStatus.nothing: 'Crop has no image data',
                      CropStatus.loading: 'Crop is now loading given image',
                      CropStatus.ready: 'Crop is now ready',
                      CropStatus.cropping: 'Crop is now cropping image',
                    }[status] ??
                    '';
              }),
          aspectRatio: isProfile ? 4 / 3 : 16 / 9,
          interactive: true,
          fixArea: true,
          radius: isProfile ? 22 : 8),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Align(
        alignment: const Alignment(1, .95),
        child: RoundedLoadingButton(
          animateOnTap: true,
          errorColor: Colors.red.shade200,
          controller: _btnCropController,
          onPressed: () async {
            setState(() {
              isCropping = true;
            });
            isCircleUi ? _cropController.cropCircle() : _cropController.crop();
          },
          borderRadius: 22,
          elevation: 0,
          color: Theme.of(context).primaryColor,
          height: kToolbarHeight - 12,
          width: MediaQuery.of(context).size.width / 3,
          child: const Text(
            'Crop Image',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
