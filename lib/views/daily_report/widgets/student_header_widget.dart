import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/student_model.dart';

class StudentHeaderWidget extends StatelessWidget {
  final StudentModel student;

  const StudentHeaderWidget({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: SizeTokens.r24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage:
                  student.image != null && student.image!.isNotEmpty
                  ? NetworkImage(student.image!)
                  : null,
              child: student.image == null || student.image!.isEmpty
                  ? Icon(Icons.person, color: Theme.of(context).primaryColor)
                  : null,
            ),
          ),
          SizedBox(width: SizeTokens.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student.name} ${student.surname}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: SizeTokens.f18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
