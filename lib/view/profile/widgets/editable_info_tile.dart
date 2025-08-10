import 'package:flutter/material.dart';
import '../../../common/colo_extension.dart';
import '../../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditableInfoTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String fieldKey; // 'gender', 'dateOfBirth', 'phone'
  final TextInputType? keyboardType;

  const EditableInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldKey,
    this.keyboardType,
  });

  @override
  State<EditableInfoTile> createState() => _EditableInfoTileState();
}

class _EditableInfoTileState extends State<EditableInfoTile> {
  final _controller = TextEditingController();
  bool _editing = false;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value == '--' ? '' : widget.value;
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Chỉ cho phép chỉnh sửa giới tính, ngày sinh, số điện thoại
    final allowed = ['gender', 'dateOfBirth', 'phone'];
    if (!allowed.contains(widget.fieldKey)) return;

    await _firestore.updateUserProfile(
      userId: user.uid,
      gender: widget.fieldKey == 'gender' ? _controller.text.trim() : null,
      dateOfBirth:
          widget.fieldKey == 'dateOfBirth' ? _controller.text.trim() : null,
      phone: widget.fieldKey == 'phone' ? _controller.text.trim() : null,
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
              child: TextField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  hintText: '--',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  border: const UnderlineInputBorder(),
                ),
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
            )
          else
            Text(widget.value, style: TextStyle(color: TColor.gray, fontSize: 12)),
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

