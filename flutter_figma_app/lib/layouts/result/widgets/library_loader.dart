import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_figma/flutter_figma.dart';
import 'package:flutter_figma_app/state/result.dart';
import 'package:flutter_figma_app/widgets/async_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryLoader extends ConsumerWidget {
  const LibraryLoader({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(remoteLibraryProvider);
    return AsyncLayout<FigmaRemoteLibrary?>(
      value: library,
      builder: (context, value, _) {
        if (value == null) {
          return const Center(
            child: Text(
              'No available library',
            ),
          );
        }
        return InheritedRemote(
          child: child,
          versions: const {
            'figma': 1,
          },
          libraries: {
            'figma': value,
          },
        );
      },
    );
  }
}