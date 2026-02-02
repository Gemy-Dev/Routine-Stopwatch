import 'package:flutter/material.dart';
import 'package:routine_stopwatch/core/theme/app_theme.dart';
import '../../../domain/entities/profile.dart';
import '../../../core/constants/sound_constants.dart';

class ProfileEditDialog extends StatefulWidget {
  final Profile profile;

  const ProfileEditDialog({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late int _selectedSoundIndex;
  late int? _cycleMultiplier;
  late bool _playUntilStopped;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _minutesController = TextEditingController(
      text: widget.profile.triggerTime.inMinutes.toString(),
    );
    _secondsController = TextEditingController(
      text: (widget.profile.triggerTime.inSeconds % 60).toString(),
    );
    _selectedSoundIndex = widget.profile.soundIndex;
    _cycleMultiplier = widget.profile.cycleMultiplier;
    _playUntilStopped = widget.profile.playUntilStopped;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.lightGrey,
      title: const Text(
        'Edit Profile',
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trigger Time (MM:SS)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    ':',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Seconds',
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedSoundIndex,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Sound',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              dropdownColor: Colors.white,
              items: List.generate(SoundConstants.soundCount, (index) {
                final soundIndex = index + 1;
                return DropdownMenuItem<int>(
                  value: soundIndex,
                  child: Text(
                    SoundConstants.getSoundName(soundIndex),
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSoundIndex = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'Play Until Stopped',
                style: TextStyle(color: Colors.black),
              ),
              value: _playUntilStopped,
              onChanged: (value) {
                setState(() {
                  _playUntilStopped = value ?? false;
                  if (_playUntilStopped) {
                    _cycleMultiplier = null;
                  } else {
                    _cycleMultiplier = _cycleMultiplier ?? 1;
                  }
                });
              },
            ),
            if (!_playUntilStopped) ...[
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Cycle Multiplier (30s per cycle)',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final multiplier = int.tryParse(value);
                  setState(() {
                    _cycleMultiplier = multiplier;
                  });
                },
                controller: TextEditingController(
                  text: _cycleMultiplier?.toString() ?? '1',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        FilledButton(
          onPressed: () {
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            final seconds = int.tryParse(_secondsController.text) ?? 0;
            final triggerDuration = Duration(
              minutes: minutes,
              seconds: seconds.clamp(0, 59),
            );
            final updatedProfile = widget.profile.copyWith(
              name: _nameController.text.trim().isEmpty
                  ? widget.profile.name
                  : _nameController.text.trim(),
              triggerTime: triggerDuration,
              soundIndex: _selectedSoundIndex,
              cycleMultiplier: _playUntilStopped ? null : (_cycleMultiplier ?? 1),
              playUntilStopped: _playUntilStopped,
            );
            Navigator.of(context).pop(updatedProfile);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

