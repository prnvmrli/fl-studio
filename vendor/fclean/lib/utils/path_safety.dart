import 'dart:io';

import 'package:path/path.dart' as p;

bool isProtectedPath(String rawPath) {
  final normalized = p.normalize(p.absolute(rawPath));
  final parsed = p.split(normalized);

  if (normalized == p.rootPrefix(normalized) || parsed.length <= 1) {
    return true;
  }

  final lower = normalized.toLowerCase();
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  final protected = <String>[
    '/',
    '/bin',
    '/boot',
    '/dev',
    '/etc',
    '/lib',
    '/private',
    '/sbin',
    '/sys',
    '/usr',
    '/var',
    'c:\\',
    'c:\\windows',
    'c:\\program files',
    'c:\\program files (x86)',
  ];

  if (home != null && p.equals(normalized, p.normalize(home))) {
    return true;
  }

  return protected.any((entry) => lower == p.normalize(entry).toLowerCase());
}

bool isInside(String child, String parent) {
  final childPath = p.normalize(p.absolute(child));
  final parentPath = p.normalize(p.absolute(parent));
  return p.equals(childPath, parentPath) || p.isWithin(parentPath, childPath);
}
