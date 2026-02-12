import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/chat_detail_view_model.dart';
import '../../viewmodels/landing_view_model.dart';

class ChatDetailView extends StatelessWidget {
  final UserModel currentUser;
  final int chatRoomId;
  final String otherUserName;

  const ChatDetailView({
    super.key,
    required this.currentUser,
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return ChangeNotifierProvider(
      create: (_) => ChatDetailViewModel()
        ..init(
          currentUser.schoolId ?? 1,
          currentUser.userKey ?? '',
          chatRoomId,
        ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: BaseAppBar(
          title: Text(
            otherUserName,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeTokens.f16,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ChatDetailViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildStatusBanner(context, viewModel, locale),
                Expanded(
                  child: viewModel.isLoading && viewModel.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null &&
                            viewModel.messages.isEmpty
                      ? Center(child: Text(viewModel.errorMessage!))
                      : ListView.builder(
                          padding: EdgeInsets.all(SizeTokens.p16),
                          itemCount: viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final message = viewModel.messages[index];
                            final isMe = message.sendUser == currentUser.id;
                            return _buildMessageBubble(context, message, isMe);
                          },
                        ),
                ),
                _buildMessageInput(context, viewModel, locale),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(context, message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.p12),
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p16,
          vertical: SizeTokens.p10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeTokens.r20),
            topRight: Radius.circular(SizeTokens.r20),
            bottomLeft: Radius.circular(isMe ? SizeTokens.r20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : SizeTokens.r20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.description ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF2D2D2D),
                fontSize: SizeTokens.f14,
              ),
            ),
            SizedBox(height: SizeTokens.p4),
            Text(
              _formatTime(message.dateAdded),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[400],
                fontSize: SizeTokens.f10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ChatDetailViewModel viewModel,
    String locale,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: SizeTokens.p16,
        right: SizeTokens.p16,
        top: SizeTokens.p10,
        bottom: SizeTokens.p10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(SizeTokens.r24),
              ),
              child: TextField(
                controller: viewModel.messageController,
                decoration: InputDecoration(
                  hintText: AppTranslations.translate('write_message', locale),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: SizeTokens.f14,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeTokens.p12),
          GestureDetector(
            onTap: () => viewModel.sendMessage(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(SizeTokens.p12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    ChatDetailViewModel viewModel,
    String locale,
  ) {
    if (currentUser.role != 'superadmin') return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusButton(
            context,
            viewModel,
            0,
            AppTranslations.translate('waiting', locale),
            Theme.of(context).primaryColor,
          ),
          _buildStatusButton(
            context,
            viewModel,
            1,
            AppTranslations.translate('approved', locale),
            Colors.green,
          ),
          _buildStatusButton(
            context,
            viewModel,
            2,
            AppTranslations.translate('cancelled', locale),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    ChatDetailViewModel viewModel,
    int status,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final success = await viewModel.updateStatus(status);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.translate('success_message', 'tr')),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p12,
          vertical: SizeTokens.p6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeTokens.r20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: SizeTokens.f12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
