import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bloc/session_bloc.dart';

/// Davomat ekrani (demo). Guard zanjirida emas — mosligi uchun saqlanadi.
///
/// TODO: demo tugmani haqiqiy davomat/check-in oqimiga almashtirish.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Attendance'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  context.read<SessionBloc>().add(const SessionLogoutRequested()),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
