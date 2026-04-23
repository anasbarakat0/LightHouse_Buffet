import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/constants/scan_page_constants.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/model/verification_step_data.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/widget/verification_ring_painter.dart';

class ScanPanelWidget extends StatelessWidget {
  final bool isVerifying;
  final bool showInstructions;
  final String logoAsset;
  final String verificationSubtitle;
  final String secureCheckLabel;
  final Animation<double> progressAnimation;
  final Animation<double> pulseAnimation;
  final List<VerificationStepData> verificationSteps;

  const ScanPanelWidget({
    super.key,
    required this.isVerifying,
    required this.showInstructions,
    required this.logoAsset,
    required this.verificationSubtitle,
    required this.secureCheckLabel,
    required this.progressAnimation,
    required this.pulseAnimation,
    required this.verificationSteps,
  });

  double _responsiveWidth(
    BuildContext context, {
    required double factor,
    required double min,
    required double max,
  }) {
    return (MediaQuery.sizeOf(context).width * factor)
        .clamp(min, max)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = _responsiveWidth(
      context,
      factor: 0.42,
      min: 320,
      max: 540,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: panelWidth),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3254), darkNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: orange.withValues(alpha: 0.3),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: orange.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: SvgPicture.asset(
                ScanPageConstants.backgroundPatternAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isVerifying
                ? _VerificationLoadingCard(
                    progressAnimation: progressAnimation,
                    pulseAnimation: pulseAnimation,
                    verificationSubtitle: verificationSubtitle,
                    secureCheckLabel: secureCheckLabel,
                    verificationSteps: verificationSteps,
                  )
                : _IdleScanContent(
                    logoAsset: logoAsset,
                    showInstructions: showInstructions,
                    logoWidth: _responsiveWidth(
                      context,
                      factor: 0.28,
                      min: 220,
                      max: 340,
                    ),
                    scannerWidth: _responsiveWidth(
                      context,
                      factor: 0.23,
                      min: 170,
                      max: 270,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IdleScanContent extends StatelessWidget {
  final String logoAsset;
  final bool showInstructions;
  final double logoWidth;
  final double scannerWidth;

  const _IdleScanContent({
    required this.logoAsset,
    required this.showInstructions,
    required this.logoWidth,
    required this.scannerWidth,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('scanner-idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          logoAsset,
          width: logoWidth,
        ),
        const SizedBox(height: 28,width: 600),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: orange.withValues(alpha: 0.55),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: darkNavy.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            ScanPageConstants.scannerGifAsset,
            width: scannerWidth,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: orange.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            'scan_qr_title'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: orange,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // if (showInstructions) ...[
        //   const SizedBox(height: 16),
        //   Text(
        //     'scan_qr_subtitle'.tr(),
        //     textAlign: TextAlign.center,
        //     style: textTheme.bodyMedium?.copyWith(
        //       color: Colors.white.withValues(alpha: 0.86),
        //       height: 1.6,
        //     ),
        //   ),
        // ],
      ],
    );
  }
}

class _VerificationLoadingCard extends StatelessWidget {
  final Animation<double> progressAnimation;
  final Animation<double> pulseAnimation;
  final String verificationSubtitle;
  final String secureCheckLabel;
  final List<VerificationStepData> verificationSteps;

  const _VerificationLoadingCard({
    required this.progressAnimation,
    required this.pulseAnimation,
    required this.verificationSubtitle,
    required this.secureCheckLabel,
    required this.verificationSteps,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      key: const ValueKey('scanner-verifying'),
      animation: Listenable.merge([
        progressAnimation,
        pulseAnimation,
      ]),
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(progressAnimation.value);
        final percent = (progress * 100).clamp(0, 100).round();
        final pulseScale = 0.98 + (pulseAnimation.value * 0.04);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timelapse_sharp,
                    color: orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    secureCheckLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Transform.scale(
              scale: pulseScale,
              child: SizedBox(
                width: 210,
                height: 210,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(210),
                      painter: VerificationRingPainter(progress: progress),
                    ),
                    Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF163F63), darkNavy],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: orange.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                                "assets/svg/lighthouse_ch.svg",
                                height: 100,
                                // fit: BoxFit.contain,
                              ),
                          // Text(
                          //   '$percent',
                          //   style: textTheme.titleLarge?.copyWith(
                          //     color: Colors.white,
                          //     fontWeight: FontWeight.w900,
                          //     fontSize: 46,
                          //     height: 1,
                          //   ),
                          // ),
                          // Text(
                          //   '%',
                          //   style: textTheme.labelLarge?.copyWith(
                          //     color: orange,
                          //     fontWeight: FontWeight.w800,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'verifying_qr'.tr(),
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              verificationSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < verificationSteps.length; i++) ...[
                    Expanded(
                      child: _VerificationInfoChip(step: verificationSteps[i]),
                    ),
                    if (i < verificationSteps.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VerificationInfoChip extends StatelessWidget {
  final VerificationStepData step;

  const _VerificationInfoChip({
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            step.icon,
            color: orange,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
