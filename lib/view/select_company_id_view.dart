import 'package:ai_defender_tablet/provider/select_company_id_provider.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:flutter/material.dart';

class SelectCompanyIdView extends StatelessWidget {
  const SelectCompanyIdView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SelectCompanyIdProvider>(
        builder: (context, provider, _) => const Scaffold());
  }
}
