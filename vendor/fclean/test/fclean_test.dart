import 'dart:io';

import 'package:fclean/fclean.dart';
import 'package:test/test.dart';

void main() {
  test('command runner exposes core commands', () {
    final runner = buildCommandRunner(logger: Logger(level: Level.quiet));

    expect(
      runner.commands.keys,
      containsAll(['clean', 'scan', 'analyze', 'doctor', 'cache', 'init']),
    );
    expect(runner.commands['cache']!.subcommands.keys, contains('gc'));
  });

  test('platform abstraction can resolve common directories', () {
    const platform = PlatformService();
    expect(platform.tempDirectory, isNotEmpty);
  });

  test('Windows pub cache defaults to LOCALAPPDATA Pub Cache', () {
    const platform = PlatformService(
      current: HostPlatform.windows,
      environment: {'LOCALAPPDATA': r'C:\Users\tester\AppData\Local'},
    );

    expect(
      platform.pubCacheDirectory,
      r'C:\Users\tester\AppData\Local\Pub\Cache',
    );
  });

  test('PUB_CACHE overrides platform pub cache defaults', () {
    const platform = PlatformService(
      current: HostPlatform.windows,
      environment: {
        'PUB_CACHE': r'D:\pub-cache',
        'LOCALAPPDATA': r'C:\Users\tester\AppData\Local',
      },
    );

    expect(platform.pubCacheDirectory, r'D:\pub-cache');
  });

  test('deleteChildren keeps the parent directory intact', () async {
    final root = await Directory.systemTemp.createTemp('fclean_test_');
    final child = File('${root.path}/artifact.tmp');
    await child.writeAsString('cache');

    const fileSystem = FileSystemService();
    final deleted = await fileSystem.deleteChildren(root.path, dryRun: false);

    expect(deleted, isTrue);
    expect(root.existsSync(), isTrue);
    expect(child.existsSync(), isFalse);
    await root.delete();
  });
}
