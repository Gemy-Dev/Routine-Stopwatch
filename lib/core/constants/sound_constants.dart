class SoundInfo {
  final String name;
  final String fileName;

  const SoundInfo({
    required this.name,
    required this.fileName,
  });
}

class SoundConstants {
  SoundConstants._();

  static const String soundAssetPath = 'assets/sounds/';
  
  // Map of sound index (1-8) to SoundInfo (name and .mp3 file)
  // To add new sounds, just add entries to this map
  static const Map<int, SoundInfo> sounds = {
    1: SoundInfo(name: 'Deep Beep', fileName: 'beep.mp3'),
    2: SoundInfo(name: 'Buzzer', fileName: 'buzzer.mp3'),
    3: SoundInfo(name: 'Bell', fileName: 'bell.mp3'),
    4: SoundInfo(name: 'Chime', fileName: 'chime.mp3'),
    5: SoundInfo(name: 'Alert', fileName: 'alert.mp3'),
    6: SoundInfo(name: 'Tone', fileName: 'tone.mp3'),
    7: SoundInfo(name: 'Signal', fileName: 'signal.mp3'),
    8: SoundInfo(name: 'Notification', fileName: 'notification.mp3'),
  };
  
  static int get soundCount => sounds.length;
  
  static String getSoundPath(int index) {
    final soundInfo = sounds[index];
    if (soundInfo == null) {
      // Return first sound as default
      return '$soundAssetPath${sounds[1]!.fileName}';
    }
    return '$soundAssetPath${soundInfo.fileName}';
  }
  
  static String getSoundName(int index) {
    final soundInfo = sounds[index];
    if (soundInfo == null) {
      // Return first sound name as default
      return sounds[1]!.name;
    }
    return soundInfo.name;
  }
  
  static List<String> get allSoundNames {
    return sounds.values.map((info) => info.name).toList();
  }
  
  static List<String> get allSoundFiles {
    return sounds.values.map((info) => info.fileName).toList();
  }
}

