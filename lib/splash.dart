import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => const MyHomePage(
    //               title: "hello",
    //             )),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.white,
                )),
            Expanded(
                flex: 10,
                child: DefaultTextStyle(
                  style: GoogleFonts.getFont(
                    'ABeeZee',
                    color: const Color(0x7A000000),
                    fontSize: 40.sp,
                    height: 1.5,
                  ),
                  child: Container(
                    width: screenWidth,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CAMPRIDE",
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        CircularProgressIndicator(
                          color: Color(0xFF29435C),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("이용약관", style: TextStyle(fontSize: 12.sp)),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text("개인정보처리방침", style: TextStyle(fontSize: 12.sp))
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Copyright © 2024 Camp Ride. All rights reserved.",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
