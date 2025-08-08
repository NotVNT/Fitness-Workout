import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({super.key});

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(
          AppLocalizations.of(context)?.personalData ?? 'Personal Data',
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _authService.getCurrentUserDataStream(),
        builder: (context, snapshot) {
          Map<String, dynamic>? userData = snapshot.data;
          UserModel? user;

          if (userData != null) {
            user = UserModel(
              id: userData['id'] ?? '',
              email: userData['email'] ?? '',
              firstName: userData['firstName'] ?? '',
              lastName: userData['lastName'] ?? '',
              dateOfBirth: userData['dateOfBirth'] ?? '',
              gender: userData['gender'] ?? '',
              weight: (userData['weight'] ?? 0.0).toDouble(),
              height: (userData['height'] ?? 0.0).toDouble(),
              targetWeight: (userData['targetWeight'] ?? 0.0).toDouble(),
              goal: userData['goal'] ?? '',
            );
          }

          String fullName = user?.fullName ?? 'User';
          String email = user?.email.isNotEmpty == true ? user!.email : '--';
          String dob =
              user?.dateOfBirth.isNotEmpty == true ? user!.dateOfBirth : '--';
          String gender = user?.gender.isNotEmpty == true ? user!.gender : '--';
          String goal = user?.goal.isNotEmpty == true ? user!.goal : '--';

          return Stack(
            children: [
              // Gradient header background
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile card with slight elevation, overlapping the header
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _InfoTile(
                              icon: Icons.person,
                              label: AppLocalizations.of(context)?.profile ??
                                  'Profile',
                              value: fullName,
                            ),
                            const Divider(height: 1),
                            _InfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: email,
                            ),
                            const Divider(height: 1),
                            _InfoTile(
                              icon: Icons.cake_outlined,
                              label: 'Date of birth',
                              value: dob,
                            ),
                            const Divider(height: 1),
                            _InfoTile(
                              icon: Icons.wc_outlined,
                              label: 'Gender',
                              value: gender,
                            ),
                            const Divider(height: 1),
                            _InfoTile(
                              icon: Icons.flag_outlined,
                              label: 'Goal',
                              value: goal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Small tip card to make it "cooler"
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.secondaryG),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)?.realTimeUpdates ??
                                    'Real time updates',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Icon(icon, color: TColor.primaryColor1, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: TColor.black, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: TColor.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
