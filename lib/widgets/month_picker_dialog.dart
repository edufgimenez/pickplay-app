import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onMonthSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (index) => DateTime(_selectedYear, index + 1));

    return AlertDialog(
      backgroundColor: AppTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.primaryPurple, width: 1.5),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.primaryPink, size: 18),
            onPressed: () => setState(() => _selectedYear--),
          ),
          Text(
            '$_selectedYear',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryPink, size: 18),
            onPressed: () => setState(() => _selectedYear++),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        height: 240,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final monthDate = months[index];
            final isCurrentSelection = monthDate.year == widget.initialDate.year &&
                monthDate.month == widget.initialDate.month;
            final monthName = DateFormat('MMM', 'pt_BR').format(monthDate).toUpperCase();

            return InkWell(
              onTap: () {
                widget.onMonthSelected(monthDate);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isCurrentSelection ? AppTheme.primaryGradient : null,
                  color: isCurrentSelection ? null : AppTheme.backgroundDeep,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCurrentSelection ? Colors.transparent : AppTheme.textMuted.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentSelection ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
