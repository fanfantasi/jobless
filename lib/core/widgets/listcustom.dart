import 'package:flutter/material.dart';

class ListCustom extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String? title;
  final Widget? trailing;
  final Function()? onTap;
  const ListCustom(
      {super.key,
      required this.icon,
      required this.color,
      required this.title,
      this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: .1,
              offset: const Offset(0, .8),
            ),
          ]),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              color: color!.withOpacity(.1),
              width: 42,
              height: 42,
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                ),
              )),
        ),
        title: Text(title!),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_outlined),
        onTap: onTap,
      ),
    );
  }
}
