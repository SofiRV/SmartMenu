import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> takePhoto({int imageQuality = 85}) {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
  }
}