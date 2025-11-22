import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/data/repository/qr_code_verification_repo.dart';
import 'package:lighthouse_buffet/features/client_scan/data/source/remote/qr_code_verification_service.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/view/invoice_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isVerifying = false;
  late QrCodeVerificationRepo _qrCodeVerificationRepo;

  @override
  void initState() {
    super.initState();
    // Initialize service and repository
    final dio = Dio();
    final service = QrCodeVerificationService(dio: dio);
    final networkConnection = NetworkConnection(
      internetConnectionChecker: InternetConnectionChecker.createInstance(
        addresses: [
          AddressCheckOption(
            uri: Uri.parse("https://www.google.com"),
            timeout: const Duration(seconds: 3),
          ),
          AddressCheckOption(
            uri: Uri.parse("https://1.1.1.1"),
            timeout: const Duration(seconds: 3),
          ),
        ],
      ),
    );
    _qrCodeVerificationRepo = QrCodeVerificationRepo(
      qrCodeVerificationService: service,
      networkConnection: networkConnection,
    );

    // Request focus after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocus();
    });
  }

  void _requestFocus() {
    if (mounted && !_isVerifying) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-request focus when page becomes visible again (e.g., after returning from another page)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestFocus();
      });
    }
  }

  Future<void> _verifyQrCode(String qrCode) async {
    if (_isVerifying) return; // Prevent multiple simultaneous verifications

    setState(() {
      _isVerifying = true;
    });

    final result = await _qrCodeVerificationRepo.verifyQrCode(qrCode);

    result.fold(
      (failure) {
        // Handle error
        setState(() {
          _isVerifying = false;
        });
        String errorMessage = _getErrorMessage(failure);
        _controller.clear();
        _showErrorMessage(errorMessage);
        // Re-request focus after showing error to continue scanning
        Future.delayed(const Duration(milliseconds: 100), () {
          _requestFocus();
        });
      },
      (response) {
        // Handle success
        setState(() {
          _isVerifying = false;
        });

        if (response.message == "QR Code verified successfully" &&
            response.status == "OK") {
          // Navigate to invoice page
          final uuid = response.body?.uuid ?? qrCode;
          _controller.clear();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePage(
                uuid: uuid,
              ),
            ),
          );
        } else {
          // Invalid QR code
          _controller.clear();
          _showErrorMessage(response.message);
          // Re-request focus after showing error to continue scanning
          Future.delayed(const Duration(milliseconds: 100), () {
            _requestFocus();
          });
        }
      },
    );
  }

  String _getErrorMessage(Failures failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is ForbiddenFailure) {
      return failure.message;
    } else if (failure is OfflineFailure) {
      return connectionMessage;
    } else if (failure is NoDataFailure) {
      return failure.message;
    } else {
      return "An error occurred. Please try again.";
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-request focus when page is built (e.g., after returning from another page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent && !_isVerifying) {
        _requestFocus();
      }
    });

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
            if (_isVerifying) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                "Verifying QR Code...",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: lightGrey),
              ),
            ],
            const SizedBox(height: 16),
            Opacity(
              opacity: 0,
              child: TextField(
                focusNode: _focusNode,
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.none,
                enabled: !_isVerifying,
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_isVerifying) {
                    _verifyQrCode(value);
                  }
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
