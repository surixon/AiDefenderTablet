import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageView extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final File? file;
  final bool? circleCrop;
  final BoxFit? fit;
  final Color? color;
  final double radius;

  const ImageView(
      {Key? key,
      this.path = "",
      this.width,
      this.height,
      this.file,
      this.circleCrop = false,
      this.fit,
      this.radius = 20.0,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (path.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        fit: fit,
        height: height,
        width: width,
        imageUrl: path,
        placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          )),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (path.startsWith('assets/')) {
      imageWidget = path.contains(".svg")
          ? SvgPicture.asset(
              path,
              width: width,
              height: height,
              color: color,
            )
          : Image.asset(
              path,
              width: width,
              height: height,
              fit: fit,
              color: color,
            );
    } else if (file != null) {
      imageWidget = Image.file(
        file!,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      imageWidget = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
      );
    }
    return circleCrop!
        ? CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(path),
            child: path.startsWith('http')
                ? const SizedBox()
                : ClipOval(child: imageWidget))
        : imageWidget;
  }
}
