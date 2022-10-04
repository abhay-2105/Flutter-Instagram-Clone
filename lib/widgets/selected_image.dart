import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectedImage extends StatefulWidget {
  final Medium selectedMedia;
  const SelectedImage(this.selectedMedia, {super.key});

  @override
  State<SelectedImage> createState() => _SelectedImageState();
}

class _SelectedImageState extends State<SelectedImage> {
  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      height: 350,
      width: MediaQuery.of(context).size.width,
      placeholder: MemoryImage(kTransparentImage),
      fit: BoxFit.cover,
      image: ThumbnailProvider(
        mediumId: widget.selectedMedia.id,
        mediumType: widget.selectedMedia.mediumType,
        highQuality: true,
      ),
    );
  }
}
