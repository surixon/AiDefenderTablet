import 'dart:ui';

import 'package:ai_defender_tablet/globals.dart';
import 'package:ai_defender_tablet/helpers/keyboard_helper.dart';
import 'package:ai_defender_tablet/provider/add_location_provider.dart';
import 'package:ai_defender_tablet/provider/location_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:ai_defender_tablet/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors_constants.dart';
import '../dialog/common_dialog.dart';
import '../enums/viewstate.dart';
import '../helpers/common_function.dart';
import '../helpers/decoration.dart';
import '../helpers/shared_pref.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  LocationViewState createState() => LocationViewState();
}

class LocationViewState extends State<LocationView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<LocationProvider>(builder: (context, provider, _) =>
        Scaffold(
          backgroundColor: kBgColor,
          appBar: CommonFunction.appBar('Locations', context, showBack: true,
              onBackPress: () {
                context.pop();
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.pushNamed(AppPaths.addLocationView);
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: StreamBuilder(
                stream: Globals.locationReference
                    .where('userId',
                    isEqualTo: SharedPref.prefs?.getString(SharedPref.userId))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No Data Yet!"));
                  }
                  else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.docs.isNotEmpty) {
                    return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 24, top: 24),
                        itemBuilder: (context, index) =>
                            _itemBuilder(
                                context,
                                index,
                                snapshot.data!.docs[index].data(),
                                snapshot.data!.docs[index].id, provider),
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: snapshot.data!.docs.length);
                  } else {
                    return const SizedBox();
                  }
                }),
          ),
        ));
  }

  Widget _itemBuilder(BuildContext context, int index,
      Map<String, dynamic> data, String id, LocationProvider provider) {
    return GestureDetector(
      onTap: () {
        context.pop(id);
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
                "${data['locationName']}",
                style: ViewDecoration.textStyleSemiBold(kBlackColor, 18),
              ),
            ),
            InkWell(
                onTap: () {
                  context.pushNamed(AppPaths.addLocationView, extra: {
                    'id': id,
                    'locationName': '${data['locationName']}'
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
                      builder: (_) =>
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const CommonDialog(
                              description: "Do you want to delete?",
                            ),
                          )).then((value) async {
                    if (value != null && value) {
                      provider.deleteLocation(id);

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
