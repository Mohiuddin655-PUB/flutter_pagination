import 'package:flutter/material.dart';

import 'exception.dart';

class InitialError extends StatelessWidget {
  const InitialError({
    this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    return ExceptionWidget(
      title: 'Something went wrong!',
      message: 'The application has encountered an unknown error.\n'
          'Please try again later.',
      onTryAgain: onTryAgain,
    );
  }
}
