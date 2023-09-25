import 'package:flutter/material.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  const RadioItem(this._item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.width / 3,
            width: MediaQuery.of(context).size.width / 2.3,
            decoration: BoxDecoration(
              // color: _item.isSelected ? Colors.blueAccent : Colors.transparent,
              border: Border.all(
                  width: 1.0,
                  color: _item.isSelected
                      ? Theme.of(context).primaryColor.withOpacity(.8)
                      : Theme.of(context).colorScheme.primary.withOpacity(.1)),
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: _item.isSelected
                        ? Theme.of(context).primaryColor.withOpacity(.1)
                        : Theme.of(context).colorScheme.primary.withOpacity(.1),
                    radius: 30,
                    child: Icon(_item.buttonText,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                Center(
                  child: Text(
                    _item.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String options;
  final String categoryId;
  final String employeeprofileId;
  final IconData buttonText;
  final String text;

  RadioModel(this.isSelected, this.options, this.categoryId,
      this.employeeprofileId, this.buttonText, this.text);

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'employeeprofileId': employeeprofileId,
      };
}
