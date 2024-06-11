// ignore: file_names
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maasapp/core/utils/image_constants.dart';
import 'package:maasapp/core/utils/string_constants.dart';


AppBar ArabniAppBar(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return AppBar(
    backgroundColor: Colors.transparent,
    automaticallyImplyLeading: false,
    actions: [
      Container(
        color: Colors.transparent,
        width: width,
        child: Padding(
          padding: EdgeInsets.only(left: 11.w, right: 21.w),
          child: Row(
            children: [
              const Icon(Icons.menu_rounded),
              SizedBox(
                width: 111.w,
              ),
              Text(
                StringConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff000000),
                ),
              ),
              const Spacer(),
              Image.asset(ImageConstants.profileImage)
            ],
          ),
        ),
      )
    ],
  );
}
