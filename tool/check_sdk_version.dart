// Block a release when the SDK version in code is not recorded in
// config-sdk-version.json.
//
// The rule: the version declared in pubspec.yaml must be the FIRST entry of
// `sdk_versions` in config-sdk-version.json.
//
//   - A change that does not touch the SDK version passes automatically,
//     because the pubspec version already sits at the top of the file.
//   - A change that bumps the real SDK version fails until a matching entry is
//     added, newest-first, to config-sdk-version.json.
//
// Run from the package root:  dart run tool/check_sdk_version.dart
// Exits 0 on success, 1 on failure. Dart SDK only, no package dependencies.

import 'dart:convert';
import 'dart:io';

const config = 'config-sdk-version.json';

/// type -> pattern whose first group is the version. Anchored to the line that
/// declares *this package's* version, so a dependency pin elsewhere in the file
/// cannot be mistaken for it.
final patterns = <String, RegExp>{
  'package_json': RegExp(r'^\s*"version"\s*:\s*"([^"]+)"'),
  'pubspec_yaml': RegExp(r'^version:\s*(\S+)\s*$'),
  'podspec': RegExp("""^\\s*s\\.version\\s*=\\s*['"]([^'"]+)['"]"""),
  'gradle_version_name': RegExp(r'''^\s*versionName\s*["']([^"']+)["']'''),
  'cordova_plugin_xml': RegExp(r'^\s*<plugin[^>]*?\sversion\s*=\s*"([^"]+)"'),
};

final errors = <String>[];
final warnings = <String>[];

String? readVersion(String file, String kind) {
  final pattern = patterns[kind];
  if (pattern == null) {
    errors.add('Unknown version_source type "$kind" in $config.');
    return null;
  }
  final f = File(file);
  if (!f.existsSync()) {
    errors.add('Version manifest "$file" (from $config) does not exist.');
    return null;
  }
  final text = f.readAsStringSync();
  if (kind == 'cordova_plugin_xml') {
    final m = RegExp(r'<plugin\b[^>]*?\sversion\s*=\s*"([^"]+)"', dotAll: true)
        .firstMatch(text);
    return m?.group(1)?.trim();
  }
  for (final line in const LineSplitter().convert(text)) {
    final m = pattern.firstMatch(line);
    if (m != null) return m.group(1)!.trim();
  }
  return null;
}

/// Sortable key. A prerelease (1.2.0-beta.1) sorts below its release.
List<int> vkey(String v) {
  final nums = RegExp(r'\d+')
      .allMatches(v)
      .map((m) => int.parse(m.group(0)!))
      .take(3)
      .toList();
  while (nums.length < 3) {
    nums.add(0);
  }
  nums.add(RegExp(r'[-+]').hasMatch(v) ? 0 : 1);
  return nums;
}

int cmpDesc(String a, String b) {
  final ka = vkey(a), kb = vkey(b);
  for (var i = 0; i < ka.length; i++) {
    if (ka[i] != kb[i]) return kb[i] - ka[i];
  }
  return 0;
}

int run() {
  final cfgFile = File(config);
  if (!cfgFile.existsSync()) {
    stdout.writeln('$config not found in ${Directory.current.path}.');
    stdout.writeln('Every Linkrunner SDK repo must carry $config at its root.');
    return 1;
  }

  Map<String, dynamic> cfg;
  try {
    cfg = jsonDecode(cfgFile.readAsStringSync()) as Map<String, dynamic>;
  } on FormatException catch (e) {
    stdout.writeln('$config is not valid JSON: ${e.message}');
    return 1;
  }

  final raw = cfg['sdk_versions'];
  if (raw is! List || raw.isEmpty) {
    stdout.writeln("$config has no non-empty 'sdk_versions' array.");
    return 1;
  }
  final entries = raw.cast<Map<String, dynamic>>();

  final src = (cfg['version_source'] as Map<String, dynamic>?) ?? {};
  final manifest = src['file'] as String?;
  final kind = src['type'] as String?;
  if (manifest == null || kind == null) {
    stdout.writeln("$config is missing the 'version_source' block.");
    stdout.writeln('Expected e.g. "version_source": {"file": "pubspec.yaml", '
        '"type": "pubspec_yaml"}');
    return 1;
  }

  final codeVersion = readVersion(manifest, kind);
  if (codeVersion == null && errors.isEmpty) {
    errors.add('Could not find a version declaration in "$manifest".');
  }

  // --- structural checks --------------------------------------------------
  final versions = entries.map((e) => e['version'] as String?).toList();
  if (versions.any((v) => v == null || v.isEmpty)) {
    errors.add("Every entry in $config needs a non-empty 'version'.");
  }
  final present = versions.whereType<String>().toList();

  final dupes = present.where((v) => present.where((o) => o == v).length > 1).toSet().toList()..sort();
  if (dupes.isNotEmpty) {
    errors.add('$config lists duplicate versions: ${dupes.join(', ')}');
  }

  final ordered = [...present]..sort(cmpDesc);
  if (present.join(' ') != ordered.join(' ')) {
    errors.add('$config must be ordered newest-first. Expected to start with '
        '"${ordered.first}" but found "${versions.first}".');
  }

  final top = entries.first;
  if (top['pushed_date'] == null || '${top['pushed_date']}'.isEmpty) {
    warnings.add('Latest entry "${top['version']}" has no \'pushed_date\'.');
  }
  if (top['description'] == null || '${top['description']}'.isEmpty) {
    warnings.add('Latest entry "${top['version']}" has no \'description\'.');
  }

  // --- the core rule ------------------------------------------------------
  if (codeVersion != null && errors.isEmpty) {
    final listed = top['version'];
    if (codeVersion != listed) {
      if (present.contains(codeVersion)) {
        errors.add('$manifest declares "$codeVersion", which IS listed in '
            '$config but not at the top (top is "$listed").\n'
            "    The newest release must be the first entry of 'sdk_versions'.");
      } else {
        errors.add('$manifest declares version "$codeVersion", but that version '
            'is missing from $config (top entry is "$listed").\n'
            '    You bumped the SDK version without recording it. Add this as '
            "the FIRST entry of 'sdk_versions':\n\n"
            '      {\n'
            '        "version": "$codeVersion",\n'
            '        "pushed_date": "YYYY-MM-DD",\n'
            '        "description": "What changed in this release."\n'
            '      }\n');
      }
    }
  }

  // --- mirrors that must not drift ---------------------------------------
  final mirrors = (cfg['version_mirrors'] as List?) ?? const [];
  for (final m in mirrors.cast<Map<String, dynamic>>()) {
    final mp = m['file'] as String?;
    if (mp == null || !File(mp).existsSync()) continue;
    final mver = readVersion(mp, m['type'] as String);
    if (mver != null && codeVersion != null && mver != codeVersion) {
      errors.add('$mp declares "$mver" but $manifest declares "$codeVersion". '
          'These must stay in sync.');
    }
  }

  // --- report -------------------------------------------------------------
  final sdk = cfg['sdk'] ?? 'SDK';
  for (final w in warnings) {
    stdout.writeln('warning: $w');
  }
  if (errors.isNotEmpty) {
    stdout.writeln('\nSDK version check failed for $sdk.\n');
    for (final e in errors) {
      stdout.writeln('  x $e');
    }
    stdout.writeln('\n  Manifest : $manifest');
    stdout.writeln('  Config   : $config (${entries.length} versions, '
        'latest "${top['version']}")');
    return 1;
  }

  stdout.writeln('SDK version check passed for $sdk. $manifest declares '
      '"$codeVersion" and it is the latest entry in $config '
      '(${entries.length} versions recorded).');
  return 0;
}

void main() => exit(run());
