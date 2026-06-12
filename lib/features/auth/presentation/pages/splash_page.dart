import 'package:flutter/material.dart';

/// Shown while [SessionBloc] resolves the initial session status.
/// The router guard moves off this screen as soon as the status is known.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
