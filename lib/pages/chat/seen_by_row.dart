import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/utils/room_status_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';

class SeenByRow extends StatelessWidget {
  final ChatController controller;
  const SeenByRow(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final seenByUsers = controller.room.getSeenByUsers(controller.timeline!);
    debugPrint('[DEBUG] ${seenByUsers.length}');
    const maxAvatars = 7;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: AnimatedContainer(
        constraints:
            const BoxConstraints(maxWidth: FluffyThemes.columnWidth * 2.5),
        height: seenByUsers.isEmpty ? 0 : 24,
        duration: seenByUsers.isEmpty
            ? Duration.zero
            : FluffyThemes.animationDuration,
        curve: FluffyThemes.animationCurve,
        alignment: controller.timeline!.events.isNotEmpty &&
                controller.timeline!.events.first.senderId ==
                    Matrix.of(context).client.userID
            ? Alignment.topRight
            : Alignment.topLeft,
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
        child: InkWell(
          onLongPress: () async => await _SeenByDialog(
            client: Matrix.of(context).client,
            seenByUsers: seenByUsers,
          ).show(context),
          child: Wrap(
            spacing: 4,
            children: [
              ...(seenByUsers.length > maxAvatars
                      ? seenByUsers.sublist(0, maxAvatars)
                      : seenByUsers)
                  .map(
                    (receipt) => Avatar(
                      mxContent: receipt.user.avatarUrl,
                      name: receipt.user.calcDisplayname(),
                      size: 16,
                      fontSize: 9,
                    ),
                  )
                  .toList(),
              if (seenByUsers.length > maxAvatars)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Material(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(32),
                    child: Center(
                      child: Text(
                        '+${seenByUsers.length - maxAvatars}',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeenByDialog extends StatelessWidget {
  final Client? client;
  final List<Receipt>? seenByUsers;

  const _SeenByDialog({
    Key? key,
    this.client,
    this.seenByUsers,
  }) : super(key: key);

  Future<bool?> show(BuildContext context) => PlatformInfos.isCupertinoStyle
      ? showCupertinoDialog(
          context: context,
          builder: (context) => this,
          barrierDismissible: true,
          useRootNavigator: false,
        )
      : showDialog(
          context: context,
          builder: (context) => this,
          barrierDismissible: true,
          useRootNavigator: false,
        );

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: <Widget>[
          for (var receipt in seenByUsers!)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Avatar(
                    mxContent: receipt.user.avatarUrl,
                    name: receipt.user.displayName,
                    client: client,
                    size: 24,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      receipt.user.displayName != null
                          ? Text(
                              '${receipt.user.displayName!} 🗓️ ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : Container(),
                      Text(
                        DateFormat('dd.MM.yyyy').format(receipt.time),
                      ),
                      Text(
                        ' 🕑️ ${DateFormat('kk:mm').format(receipt.time)}',
                      ),
                    ]),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    final title = Center(
      child: Row(
        children: [
          const Icon(
            Icons.remove_red_eye_outlined,
            size: 30,
          ),
          Text(
            '  Gesehen von...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium!.color,
            ),
          ),
        ],
      ),
    );

    return PlatformInfos.isCupertinoStyle
        ? CupertinoAlertDialog(
            title: title,
            content: body,
          )
        : AlertDialog(
            titleTextStyle: const TextStyle(
              fontSize: 50,
            ),
            title: title,
            content: body,
          );
  }
}
