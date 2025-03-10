import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_buffet/core/utils/responsive.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (Responsive.isMobile(context))
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.grey,
              size: 25,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        if (Responsive.isMobile(context))
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/svg/summary_chart.svg",
                  width: 23,
                  height: 23,
                  color: Colors.grey,
                ),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
      ],
    );
  }
}
