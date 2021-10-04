import 'package:figma/figma.dart' as figma;
import 'package:flutter_figma/src/converters/context/context.dart';
import 'package:flutter_figma/src/converters/wrappers/effect.dart';
import 'package:flutter_figma/src/converters/wrappers/decorated.dart';
import 'package:flutter_figma/src/converters/wrappers/expanded.dart';
import 'package:flutter_figma/src/converters/wrappers/opacity.dart';
import 'package:flutter_figma/src/converters/wrappers/padding.dart';
import 'package:flutter_figma/src/converters/wrappers/transform.dart';
import 'package:flutter_figma/src/helpers/api_extensions.dart';
import 'package:flutter_figma/src/helpers/naming.dart';
import 'package:rfw/formats.dart';
import 'package:collection/collection.dart';

import 'node.dart';

part 'frame.absolute.dart';
part 'frame.auto.dart';

BlobNode convert(FigmaComponentContext context, figma.Frame node, bool isRoot) {
  var result = () {
    switch (node.layoutMode) {
      case figma.LayoutMode.vertical:
      case figma.LayoutMode.horizontal:
        return _autoLayout(context, node);
      default:
        return _absoluteLayout(context, node);
    }
  }();

  result = wrapBackgroundBlurred(
    context,
    node.name ?? 'frame',
    result,
    node.effects,
    node.rectangleCornerRadii,
    0.0, //TODO
  );

  result = wrapDecorated(
    context,
    node.name ?? 'frame',
    node.fills,
    node.strokes,
    node.cornerRadius,
    node.rectangleCornerRadii,
    0.0, //TODO
    node.strokeWeight,
    node.strokeAlign,
    result,
  )!;

  result = wrapOpacity(result, node.opacity);
  result = wrapTransform(result, node.relativeTransform);

  return result;
}

typedef ChildModifier = BlobNode Function(figma.Node node, BlobNode result);

List<BlobNode> _children(
    FigmaComponentContext context, List<figma.Node?> children,
    [ChildModifier? modifier]) {
  return [
    ...children.whereNotNull().map(
      (x) {
        final blob = convertNode(context, x, false);
        return modifier != null && blob != null ? modifier(x, blob) : blob;
      },
    ).whereNotNull()
  ];
}
