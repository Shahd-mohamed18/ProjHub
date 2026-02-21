// lib/widgets/task_details/attachment_item.dart
import 'package:flutter/material.dart';

class AttachmentItem extends StatelessWidget {
  final String fileName;
  final String fileType;
  final Color iconBackgroundColor;
  final VoidCallback? onDownload;

  const AttachmentItem({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.iconBackgroundColor,
    this.onDownload,
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
            child: const Icon(Icons.insert_drive_file,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileType,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Download Button (dashed circle زي الـ design)
          GestureDetector(
            onTap: onDownload,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
                  // Flutter مش بيدعم dashed border مباشرة،
                  // لو عايز dashed استخدم package: dashed_circular_progress_bar
                ),
              ),
              child: const Icon(Icons.download_outlined,
                  size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}