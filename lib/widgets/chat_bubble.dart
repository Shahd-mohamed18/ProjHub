// import 'package:flutter/material.dart';
// import 'package:onboard/models/message_model.dart';

// class ChatBubble extends StatelessWidget {
//   const ChatBubble({super.key, required this.message});

//   final MessageModel message;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.7,
//       ),
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(right: 50, left: 10, bottom: 4),
//       decoration: const BoxDecoration(
//         color: Color(0xff314F6A),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Text(
//         message.message,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

// class ChatBubbleForFriend extends StatelessWidget {
//   const ChatBubbleForFriend({super.key, required this.message});

//   final MessageModel message;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.7,
//       ),
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(left: 50, right: 10, bottom: 4),
//       decoration: const BoxDecoration(
//         color: Color(0xff006D84),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//           bottomLeft: Radius.circular(16),
//         ),
//       ),
//       child: Text(
//         message.message,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:onboard/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xff2196F3) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe
              ? const Radius.circular(16)
              : const Radius.circular(4),
          bottomRight: isMe
              ? const Radius.circular(4)
              : const Radius.circular(16),
        ),
      ),
      child: Text(
        message.message,
        style: TextStyle(
          color: isMe ? const Color(0xffFFFFFF) : const Color(0xff000000),
          fontSize: 14,
        ),
      ),
    );
  }
}
