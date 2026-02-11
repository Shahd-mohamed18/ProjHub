import 'package:flutter/material.dart';

// class ProjectInHomeWidget extends StatelessWidget {
//   const ProjectInHomeWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       color: Colors.white,
//       // padding: const EdgeInsets.all(10.0),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.asset(
//                 'assets/images/test.jpg',
//                 // fit: BoxFit.cover,
//                 // height: 250,
//               ),
//             ),
//             SizedBox(height: 15),
//             Text(
//               'ProjHub',
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Build a full-featured e-commerce  websitewith product listings,a shopping cart, and a payment gateway',
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ProjectInHomeWidget extends StatelessWidget {
  const ProjectInHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              'assets/images/test.jpg',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'E-commerce Platform',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Build a full-featured e-commerce website with product listings, shopping cart and payment gateway',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
