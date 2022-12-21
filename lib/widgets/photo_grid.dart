import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotoGrid extends StatefulWidget {
  final int maxImages;
  final List<dynamic> imageUrls;
  final Function(int) onImageClicked;
  final Function onExpandClicked;

  PhotoGrid(
      {required this.imageUrls,
      required this.onImageClicked,
      required this.onExpandClicked,
      this.maxImages = 4,
      Key? key})
      : super(key: key);

  @override
  createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  @override
  Widget build(BuildContext context) {
    var images = buildImages();
    int numImages = widget.imageUrls.length;
    if (numImages == 3) {
      return StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        staggeredTileBuilder: (index) => StaggeredTile.count(
          (index % 3 == 0) ? 1 : 1,
          (index % 2 == 0) ? 1 : 2,
        ),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        itemCount: numImages,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, int index) {
          return CachedNetworkImage(
            imageUrl: widget.imageUrls[index],
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Padding(
                child: CupertinoActivityIndicator(),
                padding: EdgeInsets.all(20.0)),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      );
    } else if (numImages >= 4) {
      return GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 2,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: images,
      );
    } else if (numImages <= 1) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrls[0],
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Padding(
            child: CupertinoActivityIndicator(), padding: EdgeInsets.all(20.0)),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      staggeredTileBuilder: (index) => StaggeredTile.count(
          (index % 2 == 0) ? 1 : 1, (index % 2 == 0) ? 2 : 2),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      itemCount: numImages,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, int index) {
        return CachedNetworkImage(
          imageUrl: widget.imageUrls[index],
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Padding(
              child: CupertinoActivityIndicator(),
              padding: EdgeInsets.all(20.0)),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      },
    );
  }

  List<Widget> buildImages() {
    int numImages = widget.imageUrls.length;
    return List<Widget>.generate(min(numImages, widget.maxImages), (index) {
      String imageUrl = widget.imageUrls[index];

      if (index == widget.maxImages - 1) {
        int remaining = numImages - widget.maxImages;

        if (remaining == 0) {
          return GestureDetector(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
            onTap: () => widget.onImageClicked(index),
          );
        } else {
          return GestureDetector(
            onTap: () => widget.onExpandClicked(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black54,
                    child: Text(
                      '+' + remaining.toString(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return GestureDetector(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () => widget.onImageClicked(index),
        );
      }
    });
  }
}
