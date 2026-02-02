import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_edit_dialog.dart';
import '../../../domain/entities/profile.dart';
import '../../core/utils/time_formatter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure profiles are loaded when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadProfiles());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfiles());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          // convert it to switch case
          
          if (state is ProfilesLoaded || state is ProfileUpdated) {
            final profiles = state is ProfilesLoaded
                ? state.profiles
                : (state as ProfileUpdated).profiles;
            final activeProfile = state is ProfilesLoaded
                ? state.activeProfile
                : (state as ProfileUpdated).activeProfile;

            return ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                final isActive = profile.id == activeProfile?.id;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
               
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.white.withValues(alpha: 0.6),
                    border: Border.all(
                      color: isActive ? AppTheme.limeGreen.withValues(alpha: 0.3) : AppTheme.white.withValues(alpha: 0.7),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      profile.name,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trigger: ${TimeFormatter.formatDuration(profile.triggerTime)}',
                        ),
                        Text(
                          'Sound: ${profile.soundIndex}',
                        ),
                        if (profile.playUntilStopped)
                          const Text('Duration: Play Until Stopped')
                        else
                          Text(
                            'Duration: ${profile.cycleMultiplier ?? 1} cycles (${((profile.cycleMultiplier ?? 1) * 30)}s)',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.limeGreen.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppTheme.limeGreen,
                              size: 24,
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.radio_button_unchecked),
                            onPressed: () {
                              context.read<ProfileBloc>().add(
                                    SetActiveProfile(profile.id),
                                  );
                            },
                            tooltip: 'Set as active',
                          ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.skyBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppTheme.skyBlue,
                            ),
                            onPressed: () async {
                            final updatedProfile = await showDialog<Profile>(
                              context: context,
                              builder: (context) => ProfileEditDialog(
                                profile: profile,
                              ),
                            );

                            if (updatedProfile != null) {
                              context.read<ProfileBloc>().add(
                                    UpdateProfile(updatedProfile),
                                  );
                            }
                            },
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final updatedProfile = await showDialog<Profile>(
                        context: context,
                        builder: (context) => ProfileEditDialog(
                          profile: profile,
                        ),
                      );

                      if (updatedProfile != null) {
                        context.read<ProfileBloc>().add(
                              UpdateProfile(updatedProfile),
                            );
                      }
                    },
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.white,
            ),
          );
        },
        ),
      ),
    );
  }
}

