import 'package:flutter/material.dart';

/// Builds a widget similar to a [SnackBar] that is intended to be shown at the
/// bottom of the screen with the [HarpyMessageHandler].
class HarpyMessage extends StatefulWidget {
  const HarpyMessage.info(this.text)
      : iconColor = Colors.blue,
        icon = Icons.info_outline;

  const HarpyMessage.warning(this.text)
      : iconColor = Colors.orange,
        icon = Icons.error_outline;

  const HarpyMessage.error(this.text)
      : iconColor = Colors.red,
        icon = Icons.error_outline;

  /// The text for this message.
  final String text;

  /// The color for the icon.
  final Color iconColor;

  /// The icon built to the left of the text.
  final IconData icon;

  @override
  _HarpyMessageState createState() => _HarpyMessageState();
}

class _HarpyMessageState extends State<HarpyMessage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      left: false,
      right: false,
      top: false,
      bottom: true,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(16),
          color: theme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.text,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
