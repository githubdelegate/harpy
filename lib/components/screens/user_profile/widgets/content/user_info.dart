import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/harpy_navigator.dart';
import 'package:harpy/misc/misc.dart';
import 'package:provider/provider.dart';

/// Builds the info for a user in the [UserProfileHeader].
///
/// Contains the user avatar, name and a follow / unfollow button.
class UserProfileInfo extends StatelessWidget {
  const UserProfileInfo(this.bloc);

  final UserProfileBloc bloc;

  /// Builds the button to follow / unfollow the user.
  Widget _buildFollowButton(ThemeData theme) {
    return CustomAnimatedCrossFade(
      duration: kShortAnimationDuration,
      firstChild: HarpyButton.raised(
        text: const Text('following'),
        onTap: () => bloc.add(const UnfollowUserEvent()),
        dense: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      secondChild: HarpyButton.raised(
        text: const Text('follow'),
        onTap: () => bloc.add(const FollowUserEvent()),
        dense: true,
      ),
      crossFadeState: bloc.user!.following
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  /// Builds the user's avatar that opens it in fullscreen on tap.
  ///
  /// We use the original sized user avatar for both the circle avatar and
  /// fullscreen image to allow for a smooth hero animation (That is not
  /// possible if the full screen image has to be loaded first).
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () => app<HarpyNavigator>().push(
        HeroDialogRoute<void>(
          onBackgroundTap: app<HarpyNavigator>().maybePop,
          builder: (_) => CustomDismissible(
            onDismissed: app<HarpyNavigator>().maybePop,
            child: HarpyMediaGallery.builder(
              itemCount: 1,
              heroTagBuilder: (_) => bloc.user,
              beginBorderRadiusBuilder: (_) => BorderRadius.circular(48),
              builder: (_, __) => HarpyImage(
                imageUrl: bloc.user!.originalUserImageUrl,
              ),
            ),
          ),
        ),
      ),
      child: HarpyCircleAvatar(
        imageUrl: bloc.user!.originalUserImageUrl,
        radius: 36,
        heroTag: bloc.user,
      ),
    );
  }

  /// Builds the `@handle` for the user.
  Widget _buildHandle(ThemeData theme) {
    final handle = '@${bloc.user!.handle}';

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: handle));
        app<MessageService>().show('copied $handle');
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(handle, style: theme.textTheme.subtitle1),
      ),
    );
  }

  /// Builds the user's real name with the verified icon if the user is
  /// verified.
  Widget _buildUserName(ThemeData theme) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: bloc.user!.name),
          if (bloc.user!.verified) ...[
            const TextSpan(text: ' '),
            const WidgetSpan(
              child: Icon(CupertinoIcons.checkmark_seal_fill, size: 22),
              baseline: TextBaseline.alphabetic,
              alignment: PlaceholderAlignment.baseline,
            ),
          ],
        ],
        style: theme.textTheme.headline6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authCubit = context.watch<AuthenticationCubit>();

    // hide follow button when the profile of the authenticated user is showing
    // or when the connections have not been requested to determine whether the
    // authenticated user is following this user.
    final enableFollow =
        authCubit.state.user?.id != bloc.user!.id && bloc.user!.hasConnections;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        defaultHorizontalSpacer,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildHandle(theme)),
                  if (enableFollow) ...[
                    defaultHorizontalSpacer,
                    _buildFollowButton(theme),
                  ],
                ],
              ),
              defaultSmallVerticalSpacer,
              _buildUserName(theme),
            ],
          ),
        ),
      ],
    );
  }
}
