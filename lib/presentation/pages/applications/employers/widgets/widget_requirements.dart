import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/data/model/vacancies.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';

class WidgetRequirements extends StatefulWidget {
  final List<ResultRequirementsEntity>? requirement;
  const WidgetRequirements({super.key, required this.requirement});

  @override
  State<WidgetRequirements> createState() => _WidgetRequirementsState();
}

class _WidgetRequirementsState extends State<WidgetRequirements> {
  GlobalKey<FormState> formRequirementKey = GlobalKey<FormState>();
  final TextEditingController textRequirementController =
      TextEditingController();
  bool textEdit = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'requirements'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: requirements(context),
          ),
          Visibility(
            visible: textEdit,
            child: Form(
              key: formRequirementKey,
              child: TextFieldCustom(
                controller: textRequirementController,
                maxLines: null,
                readOnly: false,
                keyboardType: TextInputType.text,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'requirement in required'.tr()),
                ]),
                placeholder: 'requirements'.tr(),
                prefixIcon: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).primaryColor.withOpacity(.8),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            width: double.infinity,
            height: kToolbarHeight - 10,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.0,
                ),
                // backgroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              icon: Icon(textEdit ? Icons.check_rounded : Icons.add_box,
                  color: Theme.of(context).primaryIconTheme.color),
              label: Text(
                textEdit ? 'save'.tr() : 'add new requirements'.tr(),
                style: TextStyle(
                    color: Theme.of(context).primaryIconTheme.color,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (textEdit) {
                  if (formRequirementKey.currentState!.validate()) {
                    setState(() {
                      widget.requirement!.add(
                        ResultRequirementsModel.fromJSON(
                            {'requirement': textRequirementController.text}),
                      );
                      textEdit = !textEdit;
                    });
                  }
                } else {
                  textRequirementController.clear();
                  setState(() {
                    textEdit = !textEdit;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget requirements(context) {
    return Column(
      children: List.generate(
        widget.requirement!.length,
        (index) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.05),
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor.withOpacity(.8),
                    ),
                    const SizedBox(
                      width: 12.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        widget.requirement![index].requirement!,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.8)),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.close,
                  color: Colors.red.withOpacity(.8),
                ),
                onTap: () => setState(() {
                  widget.requirement!.removeAt(index);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
