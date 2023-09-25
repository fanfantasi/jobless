import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

import 'video_viewer_page.dart';

class ViewerPage extends StatelessWidget {
  final Medium medium;

  const ViewerPage(this.medium, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: medium.title != null ? Text(medium.title!) : null,
      ),
      body: Container(
        alignment: Alignment.center,
        child: medium.mediumType == MediumType.image
            ? GestureDetector(
                onTap: () async {
                  PhotoGallery.deleteMedium(mediumId: medium.id);
                },
                child: FadeInImage(
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(kTransparentImage),
                  image: PhotoProvider(mediumId: medium.id),
                ),
              )
            : VideoProvider(
                mediumId: medium.id,
              ),
      ),
    );
  }
}
