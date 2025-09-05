import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingShared extends StatelessWidget {
  const LoadingShared({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SpinKitRing(
            color: Color(0xFF3F51B5),
            lineWidth: 5,
          ),
        ),
      ),
    );
  }
}
