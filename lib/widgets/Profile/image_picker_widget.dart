import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePickerWidget extends StatefulWidget {
  final ValueChanged<XFile?> onImageSelected;
  final double radius;
  final double cameraIconSize;
  final Color backgroundColor;
  final Color iconColor;
  final String? initialImagePath;
  final bool readOnly;

  ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.radius = 80.0,
    this.cameraIconSize = 24.0,
    this.backgroundColor = const Color(0xFFFEE2E2),
    this.iconColor = const Color(0xFFDC2626),
    this.initialImagePath,
    this.readOnly = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      _imageFile = XFile(widget.initialImagePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: widget.backgroundColor,
            backgroundImage: _getBackgroundImage(),
            child: _getImageChild(),
          ),
          if (!widget.readOnly)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: ((builder) => _buildBottomSheet()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.iconColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: widget.cameraIconSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (_imageFile != null) {
      return FileImage(File(_imageFile!.path));
    } else if (widget.initialImagePath != null &&
        widget.initialImagePath!.startsWith('http')) {
      return null;
    } else if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      return FileImage(File(widget.initialImagePath!));
    }
    return null;
  }

  Widget? _getImageChild() {
    if (widget.initialImagePath != null &&
        widget.initialImagePath!.startsWith('http') &&
        _imageFile == null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.initialImagePath!,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: widget.iconColor,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.person, size: widget.radius, color: widget.iconColor),
        ),
      );
    }

    if (_imageFile == null &&
        (widget.initialImagePath == null || widget.initialImagePath!.isEmpty)) {
      return Icon(Icons.person, size: widget.radius, color: widget.iconColor);
    }

    return null;
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Text("Choose profile photo", style: TextStyle(fontSize: 20.0)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera, color: widget.iconColor),
                onPressed: () {
                  _takePhoto(ImageSource.camera);
                },
                label: Text(
                  'Camera',
                  style: TextStyle(color: widget.iconColor),
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.image, color: widget.iconColor),
                onPressed: () {
                  _takePhoto(ImageSource.gallery);
                },
                label: Text(
                  'Gallery',
                  style: TextStyle(color: widget.iconColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      widget.onImageSelected(pickedFile);
    }
    Navigator.pop(context);
  }

  void clearImage() {
    setState(() {
      _imageFile = null;
    });
    widget.onImageSelected(null);
  }

  String? get currentImagePath => _imageFile?.path;
}
