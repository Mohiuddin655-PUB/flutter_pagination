import 'package:flutter/material.dart';

class InitialIndicator extends StatelessWidget {
  const InitialIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
