import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/ui_components/common_widgets.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../viewmodels/new_chat_view_model.dart';
import 'chat_detail_view.dart';

class NewChatView extends StatelessWidget {
  final UserModel currentUser;

  const NewChatView({super.key, required this.currentUser});

  List<String> _getTargetRoles(String? userRole) {
    if (userRole == 'parent') {
      return ['teacher', 'admin'];
    } else if (userRole == 'teacher') {
      return ['parent', 'admin'];
    } else {
      return ['parent', 'teacher'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final targetRoles = _getTargetRoles(currentUser.role);

    return ChangeNotifierProvider(
      create: (_) => NewChatViewModel()
        ..init(
          currentUser.schoolId ?? 1,
          currentUser.userKey ?? '',
          currentUser.role ?? '',
        ),
      child: DefaultTabController(
        length: targetRoles.length,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: BaseAppBar(
            title: Text(
              AppTranslations.translate('start_new_chat', locale),
              style: TextStyle(
                color: Colors.black,
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeTokens.f14,
              ),
              tabs: targetRoles
                  .map(
                    (role) =>
                        Tab(text: AppTranslations.translate(role, locale)),
                  )
                  .toList(),
            ),
          ),
          body: Consumer<NewChatViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.participants.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return Center(child: Text(viewModel.errorMessage!));
              }

              return TabBarView(
                children: targetRoles.map((role) {
                  final filteredParticipants = viewModel.participants
                      .where(
                        (u) => role == 'admin'
                            ? (u.role == 'admin' || u.role == 'superadmin')
                            : u.role == role,
                      )
                      .toList();

                  if (filteredParticipants.isEmpty) {
                    return Center(
                      child: Text(
                        AppTranslations.translate('no_data_found', locale),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeTokens.f14,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(SizeTokens.p16),
                    itemCount: filteredParticipants.length,
                    itemBuilder: (context, index) {
                      final user = filteredParticipants[index];
                      return _buildUserTile(context, viewModel, user, locale);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    NewChatViewModel viewModel,
    UserModel user,
    String locale,
  ) {
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
      child: ListTile(
        contentPadding: EdgeInsets.all(SizeTokens.p8),
        leading: CircleAvatar(
          radius: SizeTokens.r24,
          backgroundColor: Colors.grey[200],
          backgroundImage: user.image != null
              ? NetworkImage(user.image!)
              : null,
          child: user.image == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          '${user.name ?? ''} ${user.surname ?? ''}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeTokens.f14,
          ),
        ),
        subtitle: Text(
          AppTranslations.translate(user.role ?? '', locale),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: SizeTokens.f10,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          final chatId = await viewModel.startChat(user.id ?? 0);
          if (chatId != null && context.mounted) {
            // Success, open chat detail
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailView(
                  currentUser: currentUser,
                  chatRoomId: chatId,
                  otherUserName: '${user.name ?? ''} ${user.surname ?? ''}',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
