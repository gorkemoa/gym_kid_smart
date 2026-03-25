import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../core/ui_components/common_widgets.dart';
import '../../../models/oyungrubu_announcement_model.dart';

class OyunGrubuAnnouncementDetailView extends StatelessWidget {
  final OyunGrubuAnnouncementModel announcement;
  final String locale;
  final Future<bool> Function({
    required int announcementId,
    required String vote,
  })? onVote;

  const OyunGrubuAnnouncementDetailView({
    super.key,
    required this.announcement,
    required this.locale,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final isPoll =
        announcement.isPoll == 1 &&
        (announcement.pollOptionAText != null ||
            announcement.pollOptionBText != null);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BaseAppBar(
        title: Text(
          isPoll
              ? AppTranslations.translate('poll_detail', locale)
              : AppTranslations.translate('announcement_detail', locale),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderStrip(
              announcement: announcement,
              isPoll: isPoll,
              locale: locale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p20,
                vertical: SizeTokens.p24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (announcement.content != null &&
                      announcement.content!.trim().isNotEmpty) ...[
                    _SectionLabel(
                      label: AppTranslations.translate('description', locale),
                    ),
                    SizedBox(height: SizeTokens.p12),
                    _ContentBlock(text: announcement.content!),
                  ],
                  if (isPoll) ...[
                    SizedBox(height: SizeTokens.p24),
                    _SectionLabel(
                      label: AppTranslations.translate('poll_detail', locale),
                    ),
                    SizedBox(height: SizeTokens.p12),
                    _PollSection(
                      announcement: announcement,
                      locale: locale,
                      onVote: onVote,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Header Strip
// ────────────────────────────────────────────────────────────────
class _HeaderStrip extends StatelessWidget {
  final OyunGrubuAnnouncementModel announcement;
  final bool isPoll;
  final String locale;

  const _HeaderStrip({
    required this.announcement,
    required this.isPoll,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p20,
        SizeTokens.p24,
        SizeTokens.p20,
        SizeTokens.p20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.p10,
              vertical: SizeTokens.p4,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(SizeTokens.r4),
            ),
            child: Text(
              isPoll
                  ? AppTranslations.translate('poll_detail', locale).toUpperCase()
                  : AppTranslations.translate('announcement_detail', locale).toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: SizeTokens.f10,
                  ),
            ),
          ),
          SizedBox(height: SizeTokens.p12),
          Text(
            announcement.title ?? '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: SizeTokens.f20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                  height: 1.3,
                ),
          ),
          if (announcement.createdAt != null) ...[
            SizedBox(height: SizeTokens.p12),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: SizeTokens.p12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: SizeTokens.i14,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: SizeTokens.p6),
                Text(
                  _formatDate(announcement.createdAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
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

// ────────────────────────────────────────────────────────────────
// Section label
// ────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: SizeTokens.f10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Content block
// ────────────────────────────────────────────────────────────────
class _ContentBlock extends StatelessWidget {
  final String text;
  const _ContentBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3D3D3D),
              height: 1.65,
              fontSize: SizeTokens.f14,
            ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Poll section wrapper
// ────────────────────────────────────────────────────────────────
class _PollSection extends StatelessWidget {
  final OyunGrubuAnnouncementModel announcement;
  final String locale;
  final Future<bool> Function({
    required int announcementId,
    required String vote,
  })? onVote;

  const _PollSection({
    required this.announcement,
    required this.locale,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeTokens.r8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: onVote != null
            ? _DetailPollButtons(
                announcement: announcement,
                locale: locale,
                onVote: onVote!,
              )
            : _DetailPollDisplay(announcement: announcement),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Poll Buttons — interactive
// ────────────────────────────────────────────────────────────────
class _DetailPollButtons extends StatefulWidget {
  final OyunGrubuAnnouncementModel announcement;
  final String locale;
  final Future<bool> Function({
    required int announcementId,
    required String vote,
  }) onVote;

  const _DetailPollButtons({
    required this.announcement,
    required this.locale,
    required this.onVote,
  });

  @override
  State<_DetailPollButtons> createState() => _DetailPollButtonsState();
}

class _DetailPollButtonsState extends State<_DetailPollButtons> {
  bool _isVoting = false;
  late String? _votedFor;

  @override
  void initState() {
    super.initState();
    _votedFor = widget.announcement.hasVoted == true
        ? widget.announcement.userVote
        : null;
  }

  Future<void> _handleVote(String vote) async {
    if (_isVoting || _votedFor != null) return;
    final id = widget.announcement.id;
    if (id == null) return;

    setState(() => _isVoting = true);
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
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isVoting) {
      return SizedBox(
        height: SizeTokens.h80,
        child: Center(
          child: SizedBox(
            width: SizeTokens.i20,
            height: SizeTokens.i20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    final optA = widget.announcement.pollOptionAText ?? 'A';
    final optB = widget.announcement.pollOptionBText ?? 'B';

    return Column(
      children: [
        _VoteOptionRow(
          optionKey: 'A',
          label: optA,
          isSelected: _votedFor == 'A',
          isDisabled: _votedFor != null,
          onTap: () => _handleVote('A'),
          showDivider: true,
          locale: widget.locale,
        ),
        _VoteOptionRow(
          optionKey: 'B',
          label: optB,
          isSelected: _votedFor == 'B',
          isDisabled: _votedFor != null,
          onTap: () => _handleVote('B'),
          showDivider: false,
          locale: widget.locale,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Poll Display — read-only
// ────────────────────────────────────────────────────────────────
class _DetailPollDisplay extends StatelessWidget {
  final OyunGrubuAnnouncementModel announcement;

  const _DetailPollDisplay({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final votedFor =
        announcement.hasVoted == true ? announcement.userVote : null;
    final optA = announcement.pollOptionAText ?? 'A';
    final optB = announcement.pollOptionBText ?? 'B';

    return Column(
      children: [
        _VoteOptionRow(
          optionKey: 'A',
          label: optA,
          isSelected: votedFor == 'A',
          isDisabled: votedFor != null,
          onTap: null,
          showDivider: true,
          locale: '',
        ),
        _VoteOptionRow(
          optionKey: 'B',
          label: optB,
          isSelected: votedFor == 'B',
          isDisabled: votedFor != null,
          onTap: null,
          showDivider: false,
          locale: '',
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Vote Option Row — list-row style
// ────────────────────────────────────────────────────────────────
class _VoteOptionRow extends StatelessWidget {
  final String optionKey;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;
  final bool showDivider;
  final String locale;

  const _VoteOptionRow({
    required this.optionKey,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    required this.showDivider,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        Material(
          color: isSelected
              // ignore: deprecated_member_use
              ? primaryColor.withOpacity(0.04)
              : Colors.white,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p16,
                vertical: SizeTokens.p16,
              ),
              child: Row(
                children: [
                  Container(
                    width: SizeTokens.h32,
                    height: SizeTokens.h32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          // ignore: deprecated_member_use
                          : primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(SizeTokens.r4),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: SizeTokens.i14, color: Colors.white)
                        : Text(
                            optionKey,
                            style: TextStyle(
                              fontSize: SizeTokens.f12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                  ),
                  SizedBox(width: SizeTokens.p14),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: SizeTokens.f14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? primaryColor : const Color(0xFF3D3D3D),
                          ),
                    ),
                  ),
                  if (isSelected && locale.isNotEmpty)
                    Text(
                      AppTranslations.translate('your_vote', locale),
                      style: TextStyle(
                        fontSize: SizeTokens.f10,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
