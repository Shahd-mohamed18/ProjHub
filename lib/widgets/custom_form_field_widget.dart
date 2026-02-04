import 'package:flutter/material.dart';

class CustomFormFieldWidget extends StatelessWidget {
  CustomFormFieldWidget({
    super.key,
    required this.text,
    required this.icon,
    this.isObs = false,
    this.valuValidation,
    this.textController,
    this.isfill = true,
  });
  String? Function(String?)? valuValidation;
  final String text;
  final Widget icon;
  final bool isObs;
  final bool isfill;
  final TextEditingController? textController;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: TextFormField(
        controller: textController,
        validator: valuValidation,
        obscureText: isObs,

        decoration: InputDecoration(
          filled: isfill,
          fillColor: isfill ? Colors.white : null,
          prefixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.white,
              style: BorderStyle.none,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF1E3A8A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Color(0xFF1E3A8A),
              style: BorderStyle.none,
            ),
          ),
          hintText: text,
        ),
      ),
    );
  }
}
// class CustomFormFieldWidget extends StatelessWidget {
//   const CustomFormFieldWidget({
//     super.key,
//     required this.text,
//     required this.icon,
//     this.isObs = false,
//     this.valuValidation,
//     this.textController,
//     this.isfill = true,
//   });

//   final String? Function(String?)? valuValidation;
//   final String text;
//   final Widget icon;
//   final bool isObs;
//   final bool isfill;
//   final TextEditingController? textController;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: textController,
//       validator: valuValidation,
//       obscureText: isObs,
//       decoration: InputDecoration(
//         filled: isfill,
//         fillColor: isfill ? Colors.white : null,
//         prefixIcon: icon,
//         hintText: text,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }
