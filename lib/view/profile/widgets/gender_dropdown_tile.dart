import 'package:flutter/material.dart';
import '../../../common/colo_extension.dart';
import '../../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenderDropdownTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String fieldKey;

  const GenderDropdownTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldKey,
  });

  @override
  State<GenderDropdownTile> createState() => _GenderDropdownTileState();
}

class _GenderDropdownTileState extends State<GenderDropdownTile> {
  String? _selectedGender;
  bool _editing = false;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.value == '--' ? null : widget.value;
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedGender == null) return;

    await _firestore.updateUserProfile(
      userId: user.uid,
      gender: _selectedGender,
    );
    setState(() => _editing = false);
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  items: [
                    DropdownMenuItem(
                        value: Localizations.localeOf(context).languageCode == 'en' ? 'Male' : 'Nam',
                        child: Text(Localizations.localeOf(context).languageCode == 'en' ? 'Male' : 'Nam')),
                    DropdownMenuItem(
                        value: Localizations.localeOf(context).languageCode == 'en' ? 'Female' : 'Nữ',
                        child: Text(Localizations.localeOf(context).languageCode == 'en' ? 'Female' : 'Nữ')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  hint: Text(
                    Localizations.localeOf(context).languageCode == 'en' ? 'Select gender' : 'Chọn giới tính',
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                  isExpanded: true,
                ),
              ),
            )
          else
            Text(
              widget.value == '--' ? '--' : widget.value,
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
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
