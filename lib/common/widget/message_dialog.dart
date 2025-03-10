import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';

void message(BuildContext context, String title, List<String> messages,
    void Function() onTap) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(color: darkNavy),
        ),
        backgroundColor: Colors.white,
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: List.generate(messages.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        messages[index],
                        style: const TextStyle(
                          color: darkNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 56,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        onTap();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 10,
                      ),
                      child: const Text("end"),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(width: 1.5, color: orange)),
                        elevation: 10,
                        backgroundColor: lightGrey,
                      ),
                      child: const Text("back"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
