import 'package:easy_localization/easy_localization.dart';
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
  bool _showInstructions = true;
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
      backgroundColor: darkNavy,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _showInstructions = !_showInstructions;
          });
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    width: MediaQuery.of(context).size.width / 3,
                    "assets/svg/en-logo.svg",
                  ),
                  const SizedBox(height: 40),
                  // Instruction card + scanner
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/gif/qr scanner.gif",
                        width: MediaQuery.of(context).size.width / 4,
                      ),
                      if (_showInstructions)
                        Container(
                          width: 2* MediaQuery.of(context).size.width / 3,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: navy.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: orange.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: orange.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 72,
                                color: orange,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "scan_qr_title".tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "scan_qr_subtitle".tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: lightGrey,
                                      height: 1.5,
                                      fontSize: 16,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isVerifying) ...[
                    const CircularProgressIndicator(color: orange),
                    const SizedBox(height: 16),
                    Text(
                      "verifying_qr".tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: lightGrey),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_sharp,
                          color: orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "use_scanner_hint".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: lightGrey),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
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
          ),
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
