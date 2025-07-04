import 'package:flutter/material.dart';
class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String property,value;
  const AdditionalInfo({super.key,
  required this.icon,
  required this.property,
  required this.value,
  }
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
                padding: const EdgeInsets.fromLTRB(20,8,10,20),
                child: Column(children: [
                    Icon(icon,
                    size: 32,
                    ),
                    SizedBox(height: 6,),
                    Text(property),
                    SizedBox(height: 6,),
                    Text(value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                  ],
                ),
              );
  }
}
