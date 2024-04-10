import 'package:flutter/material.dart';

import 'footer_tile.dart';

class OngoingIndicator extends StatelessWidget {
  const OngoingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FooterTile(
      child: CircularProgressIndicator(),
    );
  }
}
