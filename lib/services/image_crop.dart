import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yourfitnessguide/utils/globals.dart';

Future<CroppedFile?> myImageCropper(String filePath) async {
  return await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio16x9
        //CropAspectRatioPreset.ratio3x2,
        //CropAspectRatioPreset.original,
        //CropAspectRatioPreset.ratio4x3,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: appTheme,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          activeControlsWidgetColor: appTheme,
        )
      ]
  );
}