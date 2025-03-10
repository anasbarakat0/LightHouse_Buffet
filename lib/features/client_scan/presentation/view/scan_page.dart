import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/view/invoice_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              width: MediaQuery.of(context).size.width / 3,
              "assets/svg/en-logo.svg",
            ),
            const SizedBox(
              height: 30,
            ),
            Image.asset(
              "assets/gif/qr scanner.gif",
              width: MediaQuery.of(context).size.width / 5,
            ),
            Text(
              "Scan Your QR Code",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: lightGrey),
            ),
            const SizedBox(height: 16),
            Opacity(
              opacity: 0,
              child: TextField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.none,
                onSubmitted: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoicePage(
                        uuid: value,
                      ),
                    ),
                  );
                  _controller.clear();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Scanned QR Code',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
