import 'package:flutter/material.dart';

import 'footer_tile.dart';

class OngoingError extends StatelessWidget {
  const OngoingError({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const FooterTile(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Something went wrong. Tap to try again.',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 4,
            ),
            Icon(
              Icons.refresh,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
