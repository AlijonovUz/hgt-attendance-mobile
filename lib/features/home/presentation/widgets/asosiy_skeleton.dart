import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_shimmer.dart';

/// «Asosiy» tab yuklanayotgandagi skelet — haqiqiy tartibni (halqa kartasi +
/// surish tugmasi + bugungi tartib kartasi + statistika qatori) takrorlaydi.
///
/// Scrollable ([ListView]) — RefreshIndicator’ning «pull» imkoni yuklanish
/// paytida ham ishlashi uchun.
class AsosiySkeleton extends StatelessWidget {
  const AsosiySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Halqa kartasi — markazda doira + ostida qisqa chiziq.
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                ShimmerBox(width: 160.r, height: 160.r, shape: BoxShape.circle),
                SizedBox(height: 16.h),
                ShimmerBox(width: 180.w, height: 16.h, radius: 6),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // Surish tugmasi + maslahat chizig‘i.
          ShimmerBox(width: double.infinity, height: 56.h, radius: 10),
          SizedBox(height: 12.h),
          Center(child: ShimmerBox(width: 200.w, height: 14.h, radius: 6)),
          SizedBox(height: 20.h),
          // Bugungi tartib kartasi.
          ShimmerBox(width: double.infinity, height: 220.h, radius: 22),
          SizedBox(height: 16.h),
          // Statistika qatori — ikki karta.
          Row(
            children: [
              Expanded(
                child: ShimmerBox(height: 92.h, radius: 14),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ShimmerBox(height: 92.h, radius: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
