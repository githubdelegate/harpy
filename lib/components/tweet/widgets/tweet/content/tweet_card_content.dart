import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/components/common/animations/animation_constants.dart';
import 'package:harpy/components/common/misc/twitter_text.dart';
import 'package:harpy/components/settings/layout/widgets/layout_padding.dart';
import 'package:harpy/components/tweet/bloc/tweet_bloc.dart';
import 'package:harpy/components/tweet/widgets/media/tweet_media.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/action_row.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/actions_button.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/author_row.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/retweeted_row.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/top_row.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/translation.dart';
import 'package:harpy/components/tweet/widgets/tweet/content/tweet_card_quote_content.dart';
import 'package:harpy/core/api/twitter/tweet_data.dart';

/// Builds the content for a tweet.
class TweetCardContent extends StatelessWidget {
  const TweetCardContent(this.tweet);

  final TweetData tweet;

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[
      TweetTopRow(
        beginPadding: DefaultEdgeInsets.only(left: true, top: true),
        begin: <Widget>[
          if (tweet.isRetweet) ...<Widget>[
            TweetRetweetedRow(tweet),
            AnimatedContainer(
              duration: kLongAnimationDuration,
              height: defaultSmallPaddingValue,
            ),
          ],
          TweetAuthorRow(tweet.userData, createdAt: tweet.createdAt),
        ],
        end: TweetActionsButton(tweet, padding: DefaultEdgeInsets.all()),
      ),
      if (tweet.hasText)
        TwitterText(
          tweet.fullText,
          entities: tweet.entities,
          urlToIgnore: tweet.quotedStatusUrl,
        ),
      if (tweet.translatable) TweetTranslation(tweet),
      if (tweet.hasMedia) TweetMedia(tweet),
      if (tweet.hasQuote) TweetQuoteContent(tweet.quote),
      TweetActionRow(tweet),
    ];

    return BlocProvider<TweetBloc>(
      create: (BuildContext content) => TweetBloc(tweet),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (Widget child in content) ...<Widget>[
            if (child == content.first || child == content.last)
              child
            else
              AnimatedPadding(
                duration: kShortAnimationDuration,
                padding: DefaultEdgeInsets.only(left: true, right: true),
                child: child,
              ),
            if (child is! TweetTranslation &&
                child != content.last &&
                child != content[content.length - 2])
              AnimatedContainer(
                duration: kLongAnimationDuration,
                height: defaultSmallPaddingValue,
              ),
          ],
        ],
      ),
    );
  }
}
