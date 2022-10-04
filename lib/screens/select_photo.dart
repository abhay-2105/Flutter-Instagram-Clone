import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/create_post.dart';
import 'package:instagram/widgets/bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectPhoto extends StatefulWidget {
  const SelectPhoto({super.key});

  @override
  State<SelectPhoto> createState() => _SelectPhotoState();
}

class _SelectPhotoState extends State<SelectPhoto> {
  List<Medium>? _media;
  late String category;
  late List<Album>? _albums;
  int albumIndex = 0;
  bool isLoading = false;
  List<String> nameSelected = [];
  List<File> uploadFiles = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> album =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      MediaPage mediaPage = await album[0].listMedia();
      _media = mediaPage.items;
      setState(() {
        _albums = album;
        isLoading = false;
        category = _albums![0].name!;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void callBottomSheet() {
    ShowBottonSheet.showFolderFromGallery(
      context,
      _albums!,
      updateCategory,
    );
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> loadMedia(Album album) async {
    MediaPage mediaPage = await album.listMedia();
    _media = mediaPage.items;
  }

  void updateCategory(String newCategory) {
    setState(() {
      category = newCategory;
      albumIndex =
          _albums!.indexWhere((element) => element.name == newCategory);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'New Post',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreatePost(uploadFiles))),
              icon: const Icon(
                CupertinoIcons.arrow_right,
                color: Colors.blue,
                size: 33,
              ),
            )
          ],
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 33,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: callBottomSheet,
                        child: Text(
                          category,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.select_all,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              CupertinoIcons.camera,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: loadMedia(_albums![albumIndex]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return GridView.builder(
                              key: const ValueKey('grid'),
                              itemCount: _media!.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (nameSelected
                                          .contains(_media![index].title)) {
                                        nameSelected
                                            .remove(_media![index].title);
                                        File file =
                                            await _media![index].getFile();
                                        uploadFiles.removeWhere((element) =>
                                            element.path == file.path);
                                      } else {
                                        nameSelected.add(_media![index].title!);
                                        uploadFiles.add(
                                            await _media![index].getFile());
                                      }
                                      setState(() {});
                                    },
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        FadeInImage(
                                          height: 200,
                                          width: 200,
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          fit: BoxFit.cover,
                                          image: ThumbnailProvider(
                                              mediumId: _media![index].id,
                                              mediumType:
                                                  _media![index].mediumType,
                                              highQuality: true),
                                        ),
                                        if (nameSelected
                                            .contains(_media![index].title))
                                          const Positioned(
                                            right: 10,
                                            top: 10,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 12,
                                              child: Icon(
                                                size: 20,
                                                Icons.check,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        }),
                  )
                ],
              ),
      ),
    );
  }
}
