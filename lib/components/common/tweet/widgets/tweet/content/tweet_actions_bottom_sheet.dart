import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

/// Shows a harpy bottom sheet for the tweet actions.
///
/// A [TweetBloc] must be accessible through the [context].
void showTweetActionsBottomSheet(
  BuildContext context, {
  required TweetData tweet,
}) {
  final theme = Theme.of(context);
  final bloc = context.read<TweetBloc>();
  final authCubit = context.read<AuthenticationCubit>();
  final homeTimelineBloc = context.read<HomeTimelineBloc>();

  final isAuthenticatedUser = bloc.tweet.user.id == authCubit.state.userId;

  final showReply =
      ModalRoute.of(context)!.settings.name != ComposeScreen.route;

  final tweetTime =
      DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
          .add_Hm()
          .format(tweet.createdAt.toLocal())
          .toLowerCase();

  showHarpyBottomSheet<void>(
    context,
    hapticFeedback: true,
    children: [
      BottomSheetHeader(
        child: Column(
          children: [
            Text('tweet from ${tweet.user.name}'),
            defaultSmallVerticalSpacer,
            Text(tweetTime),
            // todo: add source here and make bottom sheet scrollable
          ],
        ),
      ),
      if (isAuthenticatedUser)
        HarpyListTile(
          leading: Icon(CupertinoIcons.delete, color: theme.errorColor),
          title: Text(
            'delete',
            style: TextStyle(
              color: theme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            bloc.add(DeleteTweet(onDeleted: () {
              homeTimelineBloc.add(RemoveFromHomeTimeline(tweet: bloc.tweet));
            }));
            app<HarpyNavigator>().maybePop();
          },
        ),
      if (showReply)
        HarpyListTile(
          leading: const Icon(CupertinoIcons.reply),
          title: const Text('reply'),
          onTap: () async {
            await app<HarpyNavigator>().maybePop();
            app<HarpyNavigator>().pushComposeScreen(
              inReplyToStatus: tweet,
            );
          },
        ),
      HarpyListTile(
        leading: const Icon(CupertinoIcons.square_arrow_left),
        title: const Text('open tweet externally'),
        onTap: () {
          launchUrl(tweet.tweetUrl);
          app<HarpyNavigator>().maybePop();
        },
      ),
      HarpyListTile(
        leading: const Icon(CupertinoIcons.square_on_square),
        title: const Text('copy tweet text'),
        enabled: bloc.tweet.hasText,
        onTap: () {
          Clipboard.setData(ClipboardData(text: tweet.visibleText));
          app<MessageService>().show('copied tweet text');
          app<HarpyNavigator>().maybePop();
        },
      ),
      HarpyListTile(
        leading: const Icon(CupertinoIcons.share),
        title: const Text('share tweet'),
        onTap: () {
          Share.share(tweet.tweetUrl);
          app<HarpyNavigator>().maybePop();
        },
      ),
    ],
  );
}
