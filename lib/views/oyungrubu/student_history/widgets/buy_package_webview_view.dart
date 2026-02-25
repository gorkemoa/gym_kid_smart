import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../app/api_constants.dart';

class BuyPackageWebViewView extends StatefulWidget {
  final String userKey;
  final int packageId;
  final int iyzicoPackageId;
  final String packageTitle;
  final String locale;

  const BuyPackageWebViewView({
    super.key,
    required this.userKey,
    required this.packageId,
    required this.iyzicoPackageId,
    required this.packageTitle,
    required this.locale,
  });

  @override
  State<BuyPackageWebViewView> createState() => _BuyPackageWebViewViewState();
}

class _BuyPackageWebViewViewState extends State<BuyPackageWebViewView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final url = ApiConstants.mobileBuyPackageUrl(
      userKey: widget.userKey,
      packageId: widget.packageId,
      iyzicoPackageId: widget.iyzicoPackageId,
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: SizeTokens.i20,
            color: Colors.grey.shade800,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.translate('buy_package', widget.locale),
              style: TextStyle(
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            Text(
              widget.packageTitle,
              style: TextStyle(
                fontSize: SizeTokens.f10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                size: SizeTokens.i20,
                color: primaryColor,
              ),
              onPressed: () {
                final url = ApiConstants.mobileBuyPackageUrl(
                  userKey: widget.userKey,
                  packageId: widget.packageId,
                  iyzicoPackageId: widget.iyzicoPackageId,
                );
                _controller.loadRequest(Uri.parse(url));
              },
            ),
          SizedBox(width: SizeTokens.p4),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            _buildErrorState(primaryColor),
          if (_isLoading) _buildLoadingOverlay(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(Color primaryColor) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: SizeTokens.i48,
              height: SizeTokens.i48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryColor,
              ),
            ),
            SizedBox(height: SizeTokens.p20),
            Text(
              AppTranslations.translate('buy_package_loading', widget.locale),
              style: TextStyle(
                fontSize: SizeTokens.f14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: SizeTokens.i48,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: SizeTokens.p20),
            Text(
              AppTranslations.translate('buy_package_error', widget.locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: SizeTokens.p8),
            Text(
              AppTranslations.translate(
                'buy_package_error_desc',
                widget.locale,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f13,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: SizeTokens.p32),
            ElevatedButton.icon(
              onPressed: () {
                final url = ApiConstants.mobileBuyPackageUrl(
                  userKey: widget.userKey,
                  packageId: widget.packageId,
                  iyzicoPackageId: widget.iyzicoPackageId,
                );
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.loadRequest(Uri.parse(url));
              },
              icon: Icon(Icons.refresh_rounded, size: SizeTokens.i18),
              label: Text(AppTranslations.translate('retry', widget.locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p24,
                  vertical: SizeTokens.p14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
