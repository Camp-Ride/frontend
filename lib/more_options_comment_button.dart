import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreOptionsCommentButton extends StatelessWidget {
  const MoreOptionsCommentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Icon(Icons.more_vert, size: 15.r),
      onSelected: (value) {
        switch (value) {
          case 1:
            print("Delete selected");
            // Handle delete action
            break;
          case 2:

            print("Report selected");
            // Handle report action
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<int>> menuItems = [
          const PopupMenuItem<int>(
            value: 1,
            child: Text('삭제'),
          ),
          const PopupMenuItem<int>(
            value: 2,
            child: Text('신고'),
          ),
        ];

        return menuItems;
      },
    );
  }
}
