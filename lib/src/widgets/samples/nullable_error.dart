import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'exception.dart';

class NullableError extends StatelessWidget {
  const NullableError({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExceptionWidget(
      title: 'No items found',
      message: 'The list is currently empty.',
    );
  }
}
