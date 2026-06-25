import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_shimmer.dart';

/// «Davomat tarixi» tab yuklanayotgandagi skelet — ixtiyoriy statistika
/// gridi (Kunlikdan boshqa rejimlarda) + bir nechta kun kartasi siluети.
///
/// Scrollable ([ListView]) — RefreshIndicator’ning «pull» imkoni yuklanish
/// paytida ham ishlashi uchun.
class AttendanceHistorySkeleton extends StatelessWidget {
  const AttendanceHistorySkeleton({super.key, this.showStats = false});

  /// Statistika kartalari gridi ko‘rsatilsinmi (faqat Haftalik/Oylik/Custom).
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (showStats) ...[
            _statRow(),
            SizedBox(height: 12.h),
            _statRow(),
            SizedBox(height: 16.h),
          ],
          for (var i = 0; i < 4; i++) ...[
            ShimmerBox(width: double.infinity, height: 168.h, radius: 22),
            if (i != 3) SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }

  Widget _statRow() => Row(
        children: [
          Expanded(child: ShimmerBox(height: 92.h, radius: 14)),
          SizedBox(width: 12.w),
          Expanded(child: ShimmerBox(height: 92.h, radius: 14)),
        ],
      );
}
