// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:lighthouse_buffet/core/resources/colors.dart';

// ignore: must_be_immutable
class MainButton extends StatelessWidget {
  final String title;
  void Function() onTap;
   final Widget icon;
  MainButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 69,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: yellow,
          ),
          child: FittedBox(
            child: Row(
              children: [
                icon,
                const SizedBox(width: 15),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
