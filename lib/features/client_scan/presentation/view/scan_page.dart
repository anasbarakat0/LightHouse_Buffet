import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/di/injection.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/data/models/qr_code_verification_response_model.dart';
import 'package:lighthouse_buffet/features/client_scan/data/repository/qr_code_verification_repo.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/constants/scan_page_constants.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/model/verification_step_data.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/widget/scan_panel_widget.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/view/invoice_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final QrCodeVerificationRepo _qrCodeVerificationRepo;
  late final AnimationController _verificationProgressController;
  late final AnimationController _pulseController;

  bool _isVerifying = false;
  bool _showInstructions = true;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  String get _logoAsset => _isArabic
      ? ScanPageConstants.arabicLogoAsset
      : ScanPageConstants.englishLogoAsset;

  String get _verificationSubtitle => _isArabic
      ? 'يتم تجهيز وصولك إلى تجربة لايت هاوس بأمان.'
      : 'Securely preparing your Lighthouse access experience.';

  String get _secureCheckLabel => _isArabic ? 'تحميل ...' : 'Loading ...';

  @override
  void initState() {
    super.initState();
    _qrCodeVerificationRepo = getIt<QrCodeVerificationRepo>();
    _verificationProgressController = AnimationController(
      vsync: this,
      duration: ScanPageConstants.verificationDuration,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: ScanPageConstants.pulseDuration,
    );
    _scheduleFocusRequest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleFocusIfCurrentRoute();
  }

  void _scheduleFocusIfCurrentRoute() {
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _scheduleFocusRequest();
    }
  }

  void _scheduleFocusRequest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocus();
    });
  }

  void _requestFocus() {
    if (mounted && !_isVerifying) {
      _focusNode.requestFocus();
    }
  }

  void _onScreenTap() {
    if (_isVerifying) return;

    setState(() {
      _showInstructions = !_showInstructions;
    });
    _requestFocus();
  }

  void _startVerificationAnimations() {
    _verificationProgressController.forward(from: 0);
    _pulseController
      ..stop()
      ..repeat(reverse: true);
  }

  void _stopVerificationAnimations() {
    _verificationProgressController
      ..stop()
      ..reset();
    _pulseController
      ..stop()
      ..reset();
  }

  Future<void> _ensureMinimumVerificationDuration(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = ScanPageConstants.verificationDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  void _finishVerification() {
    _stopVerificationAnimations();

    if (!mounted) return;
    setState(() {
      _isVerifying = false;
    });
  }

  void _resetScannerWithMessage(String message) {
    _controller.clear();
    _showErrorMessage(message);
    Future.delayed(
      ScanPageConstants.focusRestoreDelay,
      _requestFocus,
    );
  }

  Future<void> _verifyQrCode(String qrCode) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    _startVerificationAnimations();
    final startedAt = DateTime.now();

    try {
      final result = await _qrCodeVerificationRepo.verifyQrCode(qrCode);
      await _ensureMinimumVerificationDuration(startedAt);

      if (!mounted) return;
      _finishVerification();

      result.fold(
        _handleVerificationFailure,
        (response) => _handleVerificationResponse(response, qrCode),
      );
    } catch (_) {
      await _ensureMinimumVerificationDuration(startedAt);

      if (!mounted) return;
      _finishVerification();
      _resetScannerWithMessage(ScanPageConstants.genericErrorMessage);
    }
  }

  void _handleVerificationFailure(Failures failure) {
    _resetScannerWithMessage(_getErrorMessage(failure));
  }

  void _handleVerificationResponse(
    QrCodeVerificationResponseModel response,
    String qrCode,
  ) async {
    if (response.message == ScanPageConstants.verificationSuccessMessage &&
        response.status == 'OK') {
      final uuid = response.body?.uuid ?? qrCode;
      _controller.clear();

      await Navigator.of(context).push(_buildInvoicePageRoute(uuid));
      if (!mounted) return;
      _requestFocus();
      return;
    }

    _resetScannerWithMessage(response.message);
  }

  Route<void> _buildInvoicePageRoute(String uuid) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) {
        return InvoicePage(uuid: uuid);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.045),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.985,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }

  String _getErrorMessage(Failures failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    if (failure is ForbiddenFailure) {
      return failure.message;
    }
    if (failure is OfflineFailure) {
      return connectionMessage;
    }
    if (failure is NoDataFailure) {
      return failure.message;
    }
    return ScanPageConstants.genericErrorMessage;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error, Try again"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<VerificationStepData> _verificationSteps() {
    if (_isArabic) {
      return const [
        VerificationStepData(
          icon: Icons.qr_code_2_rounded,
          label: 'قراءة الرمز',
        ),
        // VerificationStepData(
        //   icon: Icons.shield_outlined,
        //   label: 'تحقق آمن',
        // ),
        VerificationStepData(
          icon: Icons.restaurant_menu_rounded,
          label: 'تجهيز الطلب',
        ),
      ];
    }

    return const [
      VerificationStepData(
        icon: Icons.qr_code_2_rounded,
        label: 'Reading Code',
      ),
      // VerificationStepData(
      //   icon: Icons.shield_outlined,
      //   label: 'Secure Check',
      // ),
      VerificationStepData(
        icon: Icons.restaurant_menu_rounded,
        label: 'Preparing',
      ),
    ];
  }

  Widget _buildPageBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: SvgPicture.asset(
          ScanPageConstants.backgroundPatternAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHiddenScannerInput() {
    return Opacity(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    _scheduleFocusIfCurrentRoute();

    return Scaffold(
      backgroundColor: darkNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF011A2E),
              darkNavy,
              Color(0xFF0B3254),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _buildPageBackground(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onScreenTap,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const Spacer(),
                        ScanPanelWidget(
                          isVerifying: _isVerifying,
                          showInstructions: _showInstructions,
                          logoAsset: _logoAsset,
                          verificationSubtitle: _verificationSubtitle,
                          secureCheckLabel: _secureCheckLabel,
                          progressAnimation: _verificationProgressController,
                          pulseAnimation: _pulseController,
                          verificationSteps: _verificationSteps(),
                        ),
                        // const Spacer(),
                        // AnimatedSwitcher(
                        //   duration: const Duration(milliseconds: 220),
                        //   child: _isVerifying || !_showInstructions
                        //       ? const SizedBox.shrink()
                        //       : _buildScannerHint(context),
                        // ),
                        
                        _buildHiddenScannerInput(),
                      ],
                    ),
                  ),
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
    _verificationProgressController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
