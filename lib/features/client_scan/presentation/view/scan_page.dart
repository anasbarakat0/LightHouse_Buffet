import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _controller = TextEditingController();
   String _scannedData = "";
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            SizedBox(height: 16),
            Opacity(
              opacity: 0,
              child: TextField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.none,
                
                onChanged: (value) {
                  setState(() {
                    _scannedData = value;
                  });
                  _controller.clear();
                },
                decoration: InputDecoration(
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
