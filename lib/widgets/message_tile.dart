import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final int? index;
  final String? message;
  final int? time;
  final String? sender;
  final bool? sentByMe;

  const MessageTile(
      {Key? key,
      this.message,
      this.sender,
      this.sentByMe,
      this.time,
      this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: sentByMe! ? 0 : 24,
          right: sentByMe! ? 24 : 0),
      alignment: sentByMe! ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          margin: sentByMe!
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            borderRadius: sentByMe!
                ? BorderRadius.circular(10)
                : BorderRadius.circular(10),
            color: sentByMe!
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).secondaryHeaderColor,
          ),
          child: sentByMe!
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Stack(
                      children: [
                        Text(
                          message!,
                          textAlign: TextAlign.start,
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(time.toString()),
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(sender!.toUpperCase(),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 7.0),
                    Text(
                      message!,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            fontSize: 15,
                            color: Theme.of(context).textTheme.bodyText1!.color,
                          ),
                    ),
                    Text(
                      DateFormat('kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(time.toString()),
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                )),
    );
  }
}
