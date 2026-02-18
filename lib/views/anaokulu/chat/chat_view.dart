import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/chat_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import 'chat_detail_view.dart';

class ChatView extends StatelessWidget {
  final UserModel user;
  final int id;

  const ChatView({super.key, required this.user, required this.id});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return ChangeNotifierProvider(
      create: (_) =>
          ChatViewModel()..init(user.schoolId ?? 1, user.userKey ?? '', id),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: _buildBody(context, viewModel, locale),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p16),
              margin: EdgeInsets.all(SizeTokens.p24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeTokens.r12),
              ),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: SizeTokens.f14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: viewModel.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r24),
                ),
              ),
              child: Text(
                AppTranslations.translate('retry', locale),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: SizeTokens.i64,
              color: Colors.grey[300],
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              AppTranslations.translate('no_messages', locale),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(SizeTokens.p16),
        itemCount: viewModel.chatRooms.length,
        itemBuilder: (context, index) {
          final room = viewModel.chatRooms[index];
          // Determine participant to display (the one that is NOT the current user)
          final displayParticipant =
              (room.sender?.data?.id != null &&
                  room.sender?.data?.id != user.id)
              ? room.sender
              : (room.recipient?.data?.id != null &&
                    room.recipient?.data?.id != user.id)
              ? room.recipient
              : (room.recipient?.data != null ? room.recipient : room.sender);
          final data = displayParticipant?.data;

          return Container(
            margin: EdgeInsets.only(bottom: SizeTokens.p12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeTokens.r20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailView(
                        currentUser: user,
                        chatRoomId: room.id ?? 0,
                        otherUserName: data?.fullName ?? 'No Name',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(SizeTokens.r20),
                child: Padding(
                  padding: EdgeInsets.all(SizeTokens.p12),
                  child: Row(
                    children: [
                      _buildAvatar(displayParticipant),
                      SizedBox(width: SizeTokens.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data?.fullName ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeTokens.f16,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                            SizedBox(height: SizeTokens.p4),
                            Row(
                              children: [
                                Text(
                                  AppTranslations.translate(
                                    data?.role ?? '',
                                    locale,
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: SizeTokens.f10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: SizeTokens.p8),
                                _buildStatusIndicator(
                                  context,
                                  room.status ?? 0,
                                  locale,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(room.dateAdded),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: SizeTokens.f10,
                            ),
                          ),
                          SizedBox(height: SizeTokens.p8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: SizeTokens.i12,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    int status,
    String locale,
  ) {
    Color color;
    String label;

    switch (status) {
      case 1:
        color = Colors.green;
        label = AppTranslations.translate('approved', locale);
        break;
      case 2:
        color = Colors.red;
        label = AppTranslations.translate('cancelled', locale);
        break;
      default:
        color = Theme.of(context).primaryColor;
        label = AppTranslations.translate('waiting', locale);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p8,
        vertical: SizeTokens.p2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: SizeTokens.f10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAvatar(participant) {
    final imageUrl = participant?.fullImageUrl ?? '';
    return Container(
      width: SizeTokens.w50,
      height: SizeTokens.w50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeTokens.r24),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.grey),
              )
            : const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      // Simple formatting for now
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
