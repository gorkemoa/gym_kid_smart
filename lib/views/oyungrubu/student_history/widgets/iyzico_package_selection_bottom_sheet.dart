import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../viewmodels/oyungrubu_student_history_view_model.dart';
import 'buy_package_webview_view.dart';

class IyzicoPackageSelectionBottomSheet extends StatefulWidget {
  final String userKey;
  final int packageId;
  final String packageTitle;
  final String locale;

  const IyzicoPackageSelectionBottomSheet({
    super.key,
    required this.userKey,
    required this.packageId,
    required this.packageTitle,
    required this.locale,
  });

  @override
  State<IyzicoPackageSelectionBottomSheet> createState() =>
      _IyzicoPackageSelectionBottomSheetState();
}

class _IyzicoPackageSelectionBottomSheetState
    extends State<IyzicoPackageSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuStudentHistoryViewModel>().fetchIyzicoPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeTokens.r24),
          topRight: Radius.circular(SizeTokens.r24),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p24,
        vertical: SizeTokens.p20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: SizeTokens.p40,
              height: SizeTokens.p4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(SizeTokens.r4),
              ),
            ),
          ),
          SizedBox(height: SizeTokens.p20),

          Text(
            AppTranslations.translate('choose_package_variant', widget.locale),
            style: TextStyle(
              fontSize: SizeTokens.f20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: SizeTokens.p8),
          Text(
            AppTranslations.translate('select_variant_desc', widget.locale),
            style: TextStyle(
              fontSize: SizeTokens.f14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: SizeTokens.p24),

          Consumer<OyunGrubuStudentHistoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoadingPackages) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (viewModel.iyzicoPackages == null ||
                  viewModel.iyzicoPackages!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      AppTranslations.translate('no_data_found', widget.locale),
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.iyzicoPackages!.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: SizeTokens.p12),
                itemBuilder: (context, index) {
                  final pkg = viewModel.iyzicoPackages![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BuyPackageWebViewView(
                            userKey: widget.userKey,
                            packageId: widget.packageId,
                            iyzicoPackageId: pkg.id ?? 0,
                            packageTitle:
                                '${widget.packageTitle} - ${pkg.name}',
                            locale: widget.locale,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SizeTokens.r16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(SizeTokens.p10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: primaryColor,
                              size: SizeTokens.i20,
                            ),
                          ),
                          SizedBox(width: SizeTokens.p16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.name ?? '-',
                                  style: TextStyle(
                                    fontSize: SizeTokens.f16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: SizeTokens.p4),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${pkg.days}${AppTranslations.translate('variant_days', widget.locale)}',
                                      ),
                                      TextSpan(
                                        text: ' • ',
                                        style: TextStyle(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${pkg.lessonCount}${AppTranslations.translate('variant_lessons', widget.locale)}',
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: SizeTokens.f12,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${pkg.price}${AppTranslations.translate('variant_price', widget.locale)}',
                            style: TextStyle(
                              fontSize: SizeTokens.f16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: SizeTokens.p4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: SizeTokens.i14,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + SizeTokens.p10,
          ),
        ],
      ),
    );
  }
}
