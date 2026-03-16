import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/responsive/size_config.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_announcement_model.dart';

class OyunGrubuAnnouncementCard extends StatelessWidget {
  final OyunGrubuAnnouncementModel announcement;
  final String locale;
  final Future<bool> Function({required int announcementId, required String vote})
      onVote;

  const OyunGrubuAnnouncementCard({
    super.key,
    required this.announcement,
    required this.locale,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isPoll =
        announcement.isPoll == 1 &&
        (announcement.pollOptionAText != null ||
            announcement.pollOptionBText != null);

    return Container(
      width: 310 / 390 * 100.w,
      margin: EdgeInsets.only(right: SizeTokens.p16),
      padding: EdgeInsets.all(SizeTokens.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(SizeTokens.p8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.r8),
                ),
                child: Icon(
                  isPoll
                      ? Icons.how_to_vote_rounded
                      : Icons.campaign_rounded,
                  size: SizeTokens.i20,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeTokens.f16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (announcement.createdAt != null) ...[
                      SizedBox(height: SizeTokens.p2),
                      Text(
                        _formatDate(announcement.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeTokens.p12),

          // Content
          Expanded(
            child: Text(
              announcement.content ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
                fontSize: SizeTokens.f13,
              ),
              overflow: TextOverflow.fade,
            ),
          ),

          // Poll buttons (if this is a poll)
          if (isPoll) ...[
            SizedBox(height: SizeTokens.p12),
            _PollButtons(
              announcement: announcement,
              locale: locale,
              onVote: onVote,
              primaryColor: primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ──────────────────────────────────────────
// Poll Buttons
// ──────────────────────────────────────────
class _PollButtons extends StatefulWidget {
  final OyunGrubuAnnouncementModel announcement;
  final String locale;
  final Future<bool> Function({required int announcementId, required String vote})
      onVote;
  final Color primaryColor;

  const _PollButtons({
    required this.announcement,
    required this.locale,
    required this.onVote,
    required this.primaryColor,
  });

  @override
  State<_PollButtons> createState() => _PollButtonsState();
}

class _PollButtonsState extends State<_PollButtons> {
  bool _isVoting = false;
  String? _votedFor;

  Future<void> _handleVote(String vote) async {
    if (_isVoting || _votedFor != null) return;
    final id = widget.announcement.id;
    if (id == null) return;

    setState(() {
      _isVoting = true;
    });

    final success = await widget.onVote(announcementId: id, vote: vote);

    if (mounted) {
      setState(() {
        _isVoting = false;
        if (success) _votedFor = vote;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppTranslations.translate('vote_submitted', widget.locale),
            ),
            backgroundColor: widget.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final optA = widget.announcement.pollOptionAText ?? 'A';
    final optB = widget.announcement.pollOptionBText ?? 'B';

    if (_isVoting) {
      return SizedBox(
        height: SizeTokens.h32,
        child: Center(
          child: SizedBox(
            width: SizeTokens.i20,
            height: SizeTokens.i20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.primaryColor,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _VoteButton(
            label: optA,
            isSelected: _votedFor == 'A',
            isDisabled: _votedFor != null,
            primaryColor: widget.primaryColor,
            onTap: () => _handleVote('A'),
          ),
        ),
        SizedBox(width: SizeTokens.p8),
        Expanded(
          child: _VoteButton(
            label: optB,
            isSelected: _votedFor == 'B',
            isDisabled: _votedFor != null,
            primaryColor: widget.primaryColor,
            onTap: () => _handleVote('B'),
          ),
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final Color primaryColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: SizeTokens.p8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              // ignore: deprecated_member_use
              : primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(SizeTokens.r8),
          border: Border.all(
            color: isSelected
                ? primaryColor
                // ignore: deprecated_member_use
                : primaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeTokens.f12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
