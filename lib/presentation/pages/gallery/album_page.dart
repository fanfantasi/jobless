import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

// import 'photo_viewer_page.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  const AlbumPage(this.album, {super.key});

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = mediaPage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name ?? "Unnamed Album"),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        children: <Widget>[
          ...?_media?.map(
            (medium) => GestureDetector(
              onTap: () {
                if (medium.mediumType != MediumType.image) {
                  Fluttertoast.showToast(msg: 'gallery required'.tr());
                } else {
                  Navigator.pop(
                    context,
                    medium,
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                    color: Colors.grey[300],
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            placeholder: MemoryImage(kTransparentImage),
                            image: ThumbnailProvider(
                              mediumId: medium.id,
                              mediumType: medium.mediumType,
                              highQuality: true,
                            ),
                          ),
                        ),
                        medium.mediumType == MediumType.video
                            ? Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Icon(
                                  Icons.play_circle_outline_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(.2),
                                  size: 32,
                                ),
                              )
                            : SizedBox.fromSize()
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
