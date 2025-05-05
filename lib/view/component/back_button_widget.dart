import 'package:flutter/cupertino.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Transform.translate(
        offset: const Offset(15, 0),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                'images/arrow.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
