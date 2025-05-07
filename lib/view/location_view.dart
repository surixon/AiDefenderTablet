import 'dart:ui';

import 'package:ai_defender_tablet/models/location.dart';
import 'package:ai_defender_tablet/provider/location_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors_constants.dart';
import '../dialog/common_dialog.dart';
import '../helpers/common_function.dart';
import '../helpers/decoration.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  LocationViewState createState() => LocationViewState();
}

class LocationViewState extends State<LocationView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<LocationProvider>(
        onModelReady: (provider) async {
          await provider.getLocationList();
        },
        builder: (context, provider, _) => Scaffold(
              backgroundColor: kBgColor,
              appBar: CommonFunction.appBar('Locations', context,
                  showBack: true, onBackPress: () {
                context.pop();
              }),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context.pushNamed(AppPaths.addLocationView).then((value) async {
                    await provider.getLocationList();
                  });
                },
                child: const Icon(Icons.add),
              ),
              body: provider.loader
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 24, top: 24),
                          itemBuilder: (context, index) => _itemBuilder(context,
                              index, provider.locationList[index], provider),
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemCount: provider.locationList.length),
                    ),
            ));
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Location location,
    LocationProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        context.pop(location.id);
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                location.locationName,
                style: ViewDecoration.textStyleSemiBold(kBlackColor, 18),
              ),
            ),
            InkWell(
                onTap: () {
                  context.pushNamed(AppPaths.addLocationView, extra: {
                    'id': location.id,
                    'locationName': location.locationName
                  }).then((value) async {
                    await provider.getLocationList();
                  });
                },
                child: const Icon(Icons.edit)),
            SizedBox(
              width: 24.w,
            ),
            InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const CommonDialog(
                              description: "Do you want to delete?",
                            ),
                          )).then((value) async {
                    if (value != null && value) {
                      provider.deleteLocation(location.id);
                    }
                  });
                },
                child: const Icon(Icons.delete)),
            SizedBox(
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}
