import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_notification_model.dart';
import '../../../../viewmodels/oyungrubu_notifications_view_model.dart';

class OyunGrubuNotificationsView extends StatefulWidget {
  final bool isTab;
  const OyunGrubuNotificationsView({super.key, this.isTab = false});

  @override
  State<OyunGrubuNotificationsView> createState() =>
      _OyunGrubuNotificationsViewState();
}

class _OyunGrubuNotificationsViewState
    extends State<OyunGrubuNotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuNotificationsViewModel>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppTranslations.translate('notifications', locale),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: SizeTokens.f18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: SizeTokens.i20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Consumer<OyunGrubuNotificationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(viewModel.errorMessage!, locale);
          }

          if (viewModel.notifications == null ||
              viewModel.notifications!.isEmpty) {
            return _buildEmptyState(locale);
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchNotifications,
            child: ListView.separated(
              padding: EdgeInsets.all(SizeTokens.p20),
              itemCount: viewModel.notifications!.length,
              separatorBuilder: (_, __) => SizedBox(height: SizeTokens.p12),
              itemBuilder: (context, index) {
                final notification = viewModel.notifications![index];
                return _buildNotificationCard(notification, primaryColor);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    OyunGrubuNotificationModel notification,
    Color primaryColor,
  ) {
    final isRead = notification.isRead == 1;

    return GestureDetector(
      onTap: () {
        if (!isRead && notification.id != null) {
          context.read<OyunGrubuNotificationsViewModel>().markNotificationRead(
            notification.id!,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isRead ? Colors.transparent : primaryColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p10),
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.shade50
                    : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                size: SizeTokens.i20,
                color: isRead ? Colors.grey.shade400 : primaryColor,
              ),
            ),
            SizedBox(width: SizeTokens.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? '-',
                          style: TextStyle(
                            fontSize: SizeTokens.f14,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: isRead
                                ? Colors.blueGrey.shade700
                                : Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: SizeTokens.p6),
                  Text(
                    notification.message ?? '-',
                    style: TextStyle(
                      fontSize: SizeTokens.f13,
                      color: Colors.blueGrey.shade600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p10),
                  Text(
                    notification.createdAt ?? '-',
                    style: TextStyle(
                      fontSize: SizeTokens.f10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: SizeTokens.i64,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: SizeTokens.p16),
          Text(
            AppTranslations.translate('no_notifications_yet', locale),
            style: TextStyle(
              fontSize: SizeTokens.f16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, String locale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade300,
              size: SizeTokens.i48,
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: SizeTokens.p24),
            ElevatedButton(
              onPressed: () => context
                  .read<OyunGrubuNotificationsViewModel>()
                  .fetchNotifications(),
              child: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'general':
        return Icons.info_outline_rounded;
      case 'lesson':
        return Icons.school_outlined;
      case 'payment':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
