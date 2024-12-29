import 'package:flutter/widgets.dart';
import 'package:runner_extension/gen/assets.gen.dart';

class Logo extends StatelessWidget {
  const Logo({super.key,  this.radius=5, this.side});
  final double radius;
  final double? side;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Assets.runnerExtension.image(
          height: side,
          width: side,
        ));
  }
}
