import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../../../viewmodels/oyungrubu_home_view_model.dart';
import '../../../viewmodels/oyungrubu_qr_scanner_view_model.dart';

class OyunGrubuQRScannerView extends StatefulWidget {
  const OyunGrubuQRScannerView({super.key});

  @override
  State<OyunGrubuQRScannerView> createState() => _OyunGrubuQRScannerViewState();
}

class _OyunGrubuQRScannerViewState extends State<OyunGrubuQRScannerView> {
  int? _selectedStudentId;
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<OyunGrubuHomeViewModel>();
      if (homeVM.students != null && homeVM.students!.isNotEmpty) {
        setState(() {
          _selectedStudentId = homeVM.students!.first.id;
        });
      }
      context.read<OyunGrubuQRScannerViewModel>().resetState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || !mounted) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    if (_selectedStudentId == null) return;

    final scannerVM = context.read<OyunGrubuQRScannerViewModel>();
    if (scannerVM.isLoading || scannerVM.isSuccess) return;

    setState(() => _isProcessing = true);

    try {
      await _controller.stop();
    } catch (e) {
      // Ignore
    }

    if (!mounted) return;

    final success = await scannerVM.scanQR(
      studentId: _selectedStudentId!,
      qrToken: code,
    );

    if (success && mounted) {
      context.read<OyunGrubuHomeViewModel>().refresh();
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      if (!success && !scannerVM.isSuccess) {
        _safeStartController();
      }
    }
  }

  Future<void> _safeStartController() async {
    try {
      // Small delay to ensure controller is ready
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_controller.value.isRunning && mounted) {
        await _controller.start();
      }
    } catch (e) {
      // Handle the "already initializing" or other start errors gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      OyunGrubuQRScannerViewModel,
      OyunGrubuHomeViewModel,
      SplashViewModel
    >(
      builder: (context, scannerVM, homeVM, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: Text(
              AppTranslations.translate('qr_scan', locale),
              style: TextStyle(
                fontSize: SizeTokens.f18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Student Selection Section
              _buildStudentSelector(homeVM, locale, primaryColor),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScannerDisplay(scannerVM, locale, primaryColor),
                        SizedBox(height: SizeTokens.p32),
                        _buildDescription(scannerVM, locale),
                        if (scannerVM.errorMessage != null) ...[
                          SizedBox(height: SizeTokens.p16),
                          _buildErrorAction(scannerVM, locale, primaryColor),
                        ],
                        if (scannerVM.isSuccess) ...[
                          SizedBox(height: SizeTokens.p16),
                          _buildSuccessAction(scannerVM, locale, primaryColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentSelector(
    OyunGrubuHomeViewModel homeVM,
    String locale,
    Color primaryColor,
  ) {
    if (homeVM.students == null || homeVM.students!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Text(
              AppTranslations.translate('select_student_to_scan', locale),
              style: TextStyle(
                fontSize: SizeTokens.f14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: SizeTokens.p8),
          SizedBox(
            height: SizeTokens.h60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              itemCount: homeVM.students!.length,
              itemBuilder: (context, index) {
                final student = homeVM.students![index];
                final isSelected = _selectedStudentId == student.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStudentId = student.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p6,
                      vertical: SizeTokens.p4,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: SizeTokens.p12),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(SizeTokens.r100),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        width: 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        CircleAvatar(
                          radius: SizeTokens.r16,
                          backgroundColor: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : primaryColor.withOpacity(0.2),
                          backgroundImage: student.photo != null
                              ? NetworkImage(student.photo!)
                              : null,
                          child: student.photo == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: SizeTokens.i16,
                                  color: isSelected
                                      ? Colors.white
                                      : primaryColor,
                                )
                              : null,
                        ),
                        SizedBox(width: SizeTokens.p8),
                        Text(
                          student.name ?? '',
                          style: TextStyle(
                            fontSize: SizeTokens.f12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerDisplay(
    OyunGrubuQRScannerViewModel scannerVM,
    String locale,
    Color primaryColor,
  ) {
    return Container(
      width: SizeTokens.h280,
      height: SizeTokens.h280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: scannerVM.isSuccess ? Colors.green : primaryColor,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(SizeTokens.r32),
        boxShadow: [
          BoxShadow(
            color: scannerVM.isSuccess
                ? Colors.green.withOpacity(0.2)
                : primaryColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.r28),
        child: Stack(
          children: [
            if (!scannerVM.isSuccess && !scannerVM.isLoading)
              MobileScanner(controller: _controller, onDetect: _onDetect),
            if (scannerVM.isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            if (scannerVM.isSuccess)
              Container(
                color: Colors.white,
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: SizeTokens.i80,
                    color: Colors.green,
                  ),
                ),
              ),
            if (!scannerVM.isLoading && !scannerVM.isSuccess)
              _buildDecorativeCorners(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCorners(Color color) {
    return Stack(
      children: [
        Positioned(
          top: 20,
          left: 20,
          child: _buildCorner(color, top: true, left: true),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: _buildCorner(color, top: true, right: true),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: _buildCorner(color, bottom: true, left: true),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildCorner(color, bottom: true, right: true),
        ),
      ],
    );
  }

  Widget _buildCorner(
    Color color, {
    bool top = false,
    bool bottom = false,
    bool left = false,
    bool right = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 4) : BorderSide.none,
          bottom: bottom ? BorderSide(color: color, width: 4) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 4) : BorderSide.none,
          right: right ? BorderSide(color: color, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDescription(
    OyunGrubuQRScannerViewModel scannerVM,
    String locale,
  ) {
    String text = AppTranslations.translate('qr_scan_desc', locale);
    Color textColor = Colors.grey.shade600;

    if (scannerVM.isLoading) {
      text = AppTranslations.translate('waiting', locale) + '...';
    } else if (scannerVM.isSuccess) {
      if (scannerVM.successMessage != null &&
          scannerVM.successMessage != 'true') {
        text = scannerVM.successMessage!;
      } else {
        text = AppTranslations.translate('qr_scan_success', locale);
      }
      textColor = Colors.green;
    } else if (scannerVM.errorMessage != null) {
      text = AppTranslations.translate(scannerVM.errorMessage!, locale);
      textColor = Colors.red;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p48),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: SizeTokens.f16,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorAction(
    OyunGrubuQRScannerViewModel scannerVM,
    String locale,
    Color primaryColor,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        scannerVM.resetState();
        _safeStartController();
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p24,
          vertical: SizeTokens.p12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
        ),
      ),
      icon: const Icon(Icons.refresh_rounded),
      label: Text(AppTranslations.translate('scan_again', locale)),
    );
  }

  Widget _buildSuccessAction(
    OyunGrubuQRScannerViewModel scannerVM,
    String locale,
    Color primaryColor,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        scannerVM.resetState();
        _safeStartController();
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p24,
          vertical: SizeTokens.p12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
        ),
      ),
      icon: const Icon(Icons.qr_code_scanner_rounded),
      label: Text(AppTranslations.translate('scan_again', locale)),
    );
  }
}
