import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:honu_app/components/components.dart';
import 'package:honu_app/data/picture_data.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<PictureData> _pictureData = [PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true)];

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  @override
  void initState() {
    super.initState();
    _pictureData = context.read<PictureDataProvider>().pictureData;
    loadAssets();
  }

  Future<void> _requestPermissionLibrary() async {
    var status = await Permission.mediaLibrary.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    // switch(_permissionStatus){
    //   case PermissionStatus.undetermined:
    //   //権限が未選択
    //     await _requestPermissionLibrary();
    //     break;
    //   case PermissionStatus.granted:
    //   //許可済み
    //     break;
    //   default:
    //     //return _showPermissionDialog("カメラ");
    //     return null;
    // }

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    //     Expanded(
    //       child: _buildGridView(),
    //     ),
    //     SizedBox(
    //       height: MediaQuery.of(context).size.height / 10,
    //       width: MediaQuery.of(context).size.width,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           for(int i=0; i<5; i++)
    //             _buildThumbnailWidget(i, context)
    //         ],
    //       ),
    //     )
    //   ],
    // );
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 10,
          width: MediaQuery.of(context).size.width,
          child: _buildGridView(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 10,
          child: Container(
            color: Color(0xffF1F2F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for(int i=0; i<5; i++)
                  _buildThumbnailWidget(i, context)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Widget _buildThumbnailWidget(int index, context){
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      height: 50.0,
      width: 50.0,
      decoration: previewBoxDecoration,
      child: _pictureData[index].picturePath != null &&_pictureData[index].takeFlag == true?
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(_pictureData[index].picturePath,height: 50.0,width: 50.0, fit: BoxFit.fill,),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.black.withOpacity(0.3)
              ),
            )
          ],
        ):
        Container(),
    );
  }
}

