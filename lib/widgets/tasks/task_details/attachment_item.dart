// lib/widgets/task_details/attachment_item.dart
import 'package:flutter/material.dart';

class AttachmentItem extends StatelessWidget {
  final String fileName;
  final String fileType;
  final Color iconBackgroundColor;
  final VoidCallback? onDownload;
  final bool showDownloadButton; // ✅ جديد: للتحكم في ظهور زر التحميل

  const AttachmentItem({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.iconBackgroundColor,
    this.onDownload,
    this.showDownloadButton = true, // ✅ افتراضياً يظهر (للمرفقات)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 43,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/Frame (4).png', 
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileType,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Download Button (optional)
          if (showDownloadButton) // ✅ يظهر فقط لو احتجناه
            IconButton(
              onPressed: onDownload ?? () {
                print('Download $fileName');
              },
              icon: Image.asset(
                'assets/images/Vector.png',
                width: 20,
                height: 20,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}