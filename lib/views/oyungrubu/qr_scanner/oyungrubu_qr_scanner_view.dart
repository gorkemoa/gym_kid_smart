import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/splash_view_model.dart';

class OyunGrubuQRScannerView extends StatelessWidget {
  const OyunGrubuQRScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SplashViewModel>().locale.languageCode;
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: SizeTokens.h200,
              height: SizeTokens.h200,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 4),
                borderRadius: BorderRadius.circular(SizeTokens.r24),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: SizeTokens.i64,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                  // Decorative corners
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: primaryColor, width: 4),
                          left: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: primaryColor, width: 4),
                          right: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: primaryColor, width: 4),
                          left: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: primaryColor, width: 4),
                          right: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeTokens.p32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p48),
              child: Text(
                AppTranslations.translate('qr_scan_desc', locale),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
