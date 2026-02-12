import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/new_chat_view_model.dart';

class NewChatView extends StatelessWidget {
  final UserModel currentUser;

  const NewChatView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return ChangeNotifierProvider(
      create: (_) => NewChatViewModel()
        ..init(
          currentUser.schoolId ?? 1,
          currentUser.userKey ?? '',
          currentUser.role ?? '',
        ),
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
        ),
        body: Consumer<NewChatViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.participants.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            return ListView.builder(
              padding: EdgeInsets.all(SizeTokens.p16),
              itemCount: viewModel.participants.length,
              itemBuilder: (context, index) {
                final user = viewModel.participants[index];
                return _buildUserTile(context, viewModel, user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    NewChatViewModel viewModel,
    UserModel user,
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
          user.role?.toUpperCase() ?? '',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: SizeTokens.f10,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          final success = await viewModel.startChat(user.id ?? 0);
          if (success && context.mounted) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
