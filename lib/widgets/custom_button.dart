import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressedCallBack;
  final String? title;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.onPressedCallBack,
    this.title,
    required this.isLoading,
    this.icon,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: icon != null && title != null
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        Text(
                          title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        icon != null
                            ? Icon(
                                icon,
                                size: 16,
                              )
                            : Container()
                      ],
                    ),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: textColor,
                ),
                foregroundColor: textColor,
                backgroundColor: color ?? Colors.black87,
                elevation: 2,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: onPressedCallBack,
            ),
          ),
        ],
      ),
    );
  }
}
