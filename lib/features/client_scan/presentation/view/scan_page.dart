import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/di/injection.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/data/repository/qr_code_verification_repo.dart';
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
    _qrCodeVerificationRepo = getIt<QrCodeVerificationRepo>();
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
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
        });
        String errorMessage = _getErrorMessage(failure);
        _controller.clear();
        if (!mounted) return;
        _showErrorMessage(errorMessage);
        Future.delayed(const Duration(milliseconds: 100), () {
          _requestFocus();
        });
      },
      (response) {
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
        });

        if (response.message == "QR Code verified successfully" &&
            response.status == "OK") {
          final uuid = response.body?.uuid ?? qrCode;
          _controller.clear();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePage(
                uuid: uuid,
              ),
            ),
          );
        } else {
          _controller.clear();
          if (!mounted) return;
          _showErrorMessage(response.message);
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
