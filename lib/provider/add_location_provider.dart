import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/toast_helper.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import '../globals.dart';

class AddLocationProvider extends BaseProvider {
  Future<void> saveLocation(String location) async {
    setState(ViewState.busy);

    await Globals.locationReference
        .where('locationName', isEqualTo: location)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await Globals.locationReference.doc().set({
          'userId': Globals.firebaseUser?.uid,
          'locationName': location,
        });
        ToastHelper.showMessage('Location added successfully!');
        setState(ViewState.idle);
      } else {
        ToastHelper.showErrorMessage('Location already added!');
        setState(ViewState.idle);
      }
    });
  }

  Future<void> updateLocation(String? id, String location) async {
    setState(ViewState.busy);

    await Globals.locationReference
        .doc(id)
        .update({'locationName': location}).then((snapshot) async {
      ToastHelper.showMessage('Location updated successfully!');
      setState(ViewState.idle);
    });
  }
}
