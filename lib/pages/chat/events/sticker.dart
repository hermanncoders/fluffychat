import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'image_bubble.dart';

class Sticker extends StatelessWidget {
  final Event event;
  final Color watermarkColor;

  const Sticker(this.event, {Key? key, required this.watermarkColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImageBubble(
      event,
      width: 400,
      height: 400,
      fit: BoxFit.contain,
      onTap: () {
        showOkAlertDialog(
          context: context,
          message: event.body,
          okLabel: L10n.of(context)!.ok,
        );
      },
      watermarkColor: watermarkColor,
    );
  }
}
