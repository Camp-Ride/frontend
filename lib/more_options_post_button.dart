import 'package:campride/community_type.dart';
import 'package:campride/post.dart';
import 'package:campride/post_modify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreOptionsPostButton extends StatefulWidget {
  final Post post;

  const MoreOptionsPostButton({Key? key, required this.post}) : super(key: key);

  @override
  _MoreOptionsPostButtonState createState() => _MoreOptionsPostButtonState();
}

class _MoreOptionsPostButtonState extends State<MoreOptionsPostButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Icon(Icons.more_vert, size: 15.r),
      onSelected: (value) {
        switch (value) {
          case 0:
            print("Edit selected");

            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostModifyPage(
                            id: widget.post.id,
                            title: widget.post.title,
                            contents: widget.post.contents,
                            imageNames: widget.post.images)))
                .then((value) => setState(() {}));

            break;
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
          PopupMenuItem<int>(
            value: 1,
            child: Text('삭제'),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Text('신고'),
          ),
          PopupMenuItem<int>(
            value: 0,
            child: Text('수정'),
          ),
        ];

        return menuItems;
      },
    );
  }
}
