import 'package:flutter/material.dart';
import '../../../common/colo_extension.dart';
import '../../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatePickerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String fieldKey;

  const DatePickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldKey,
  });

  @override
  State<DatePickerTile> createState() => _DatePickerTileState();
}

class _DatePickerTileState extends State<DatePickerTile> {
  DateTime? _selectedDate;
  bool _editing = false;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.value != '--' && widget.value.isNotEmpty) {
      try {
        // Try to parse existing date
        _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.value);
      } catch (e) {
        // If parsing fails, try other formats or set to null
        _selectedDate = null;
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context).languageCode == 'en'
          ? const Locale('en', 'US')
          : const Locale('vi', 'VN'),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDate == null) return;

    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    await _firestore.updateUserProfile(
      userId: user.uid,
      dateOfBirth: formattedDate,
    );
    setState(() => _editing = false);
  }

  String get _displayValue {
    if (_selectedDate != null) {
      return DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
    return widget.value == '--' ? '--' : widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Icon(widget.icon, color: TColor.primaryColor1, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.label,
                style: TextStyle(color: TColor.black, fontSize: 12)),
          ),
          if (_editing)
            SizedBox(
              width: 170,
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _displayValue,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                      Icon(Icons.calendar_today, 
                           size: 16, color: TColor.primaryColor1),
                    ],
                  ),
                ),
              ),
            )
          else
            Text(_displayValue, 
                 style: TextStyle(color: TColor.gray, fontSize: 12)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _editing ? _save() : setState(() => _editing = true),
            child: Icon(_editing ? Icons.check : Icons.edit,
                size: 18, color: TColor.primaryColor1),
          )
        ],
      ),
    );
  }
}
