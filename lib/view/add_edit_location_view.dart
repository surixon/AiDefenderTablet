import 'package:ai_defender_tablet/globals.dart';
import 'package:ai_defender_tablet/helpers/keyboard_helper.dart';
import 'package:ai_defender_tablet/provider/add_location_provider.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:ai_defender_tablet/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors_constants.dart';
import '../enums/viewstate.dart';
import '../helpers/common_function.dart';
import '../helpers/decoration.dart';

class AddEditLocationView extends StatefulWidget {
  final String? id;
  final String? locationName;

  const AddEditLocationView({super.key, this.id, this.locationName});

  @override
  AddEditLocationViewState createState() => AddEditLocationViewState();
}

class AddEditLocationViewState extends State<AddEditLocationView> {
  final TextEditingController addLocationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.locationName != null) {
      addLocationController.text = widget.locationName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AddLocationProvider>(
        builder: (context, provider, _) => Scaffold(
              backgroundColor: kBgColor,
              appBar: CommonFunction.appBar(
                  widget.locationName != null
                      ? 'Edit Location'
                      : 'Add Location',
                  context,
                  showBack: true, onBackPress: () {
                context.pop();
              }),
              body: Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: ViewDecoration.textFiledDecoration(
                            hintText: "Location"),
                        onChanged: (value) {},
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Please enter location';
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        controller: addLocationController,
                        style: ViewDecoration.textStyleMedium(kBlackColor, 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: provider.state == ViewState.busy
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                                title: widget.locationName != null
                                    ? 'Update'
                                    : 'Save',
                                width: 120,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    KeyboardHelper.hideKeyboard(context);

                                    if (widget.locationName != null) {
                                      await provider
                                          .updateLocation(widget.id,
                                              addLocationController.text.trim())
                                          .then((value) {
                                        context.pop();
                                      });
                                    } else {
                                      await provider
                                          .saveLocation(
                                              addLocationController.text.trim())
                                          .then((value) {
                                        context.pop();
                                      });
                                    }
                                  }
                                },
                                radius: 8.r,
                                height: 50,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
