import 'package:figma/figma.dart' as figma;
import 'package:flutter_figma/src/converters/arguments/border_radius.dart';
import 'package:flutter_figma/src/converters/arguments/gradient.dart';
import 'package:flutter_figma/src/converters/context/context.dart';
import 'package:rfw/rfw.dart';

import 'color.dart';

Object? convertPaint(
  FigmaComponentContext context,
  String name,
  figma.Paint? fill,
  figma.Paint? stroke,
  num? strokeWeight,
  figma.StrokeAlign? strokeAlign,
  num? globalCornerRadius,
  List<num>? rectangleCornerRadii,
  num? cornerSmoothing,
) {
  final strokeColorName = stroke == null ||
          stroke.type != figma.PaintType.solid ||
          stroke.color == null
      ? null
      : context.theme.colors
          .create(convertColor(stroke.color!, stroke.opacity ?? 1.0), name);
  final fillColorName =
      fill == null || fill.type != figma.PaintType.solid || fill.color == null
          ? null
          : context.theme.colors
              .create(convertColor(fill.color!, fill.opacity ?? 1.0), name);

  return {
    if (fill != null) ...{
      if (fill.type == figma.PaintType.image && fill.imageRef != null)
        'image': {
          'source': StateReference(['theme', 'images', fill.imageRef!]),
          'fit': () {
            switch (fill.scaleMode) {
              case figma.ScaleMode.fit:
                return 'contain';
              default:
                return 'cover';
            }
          }()
        },
      if (fill.type == figma.PaintType.solid && fillColorName != null)
        'color': StateReference(['theme', 'color', fillColorName]),
      if (fill.type != figma.PaintType.solid)
        'gradient': convertGradient(context, name, fill),
    },
    'shape': {
      if (globalCornerRadius != null)
        'borderRadius': convertBorderRadius(
          [
            globalCornerRadius,
            globalCornerRadius,
            globalCornerRadius,
            globalCornerRadius,
          ],
          cornerSmoothing,
        ),
      if (rectangleCornerRadii != null)
        'borderRadius':
            convertBorderRadius(rectangleCornerRadii, cornerSmoothing),
      if (stroke != null && strokeWeight != null) ...{
        if (strokeAlign != null)
          'borderAlign': () {
            switch (strokeAlign) {
              case figma.StrokeAlign.inside:
                return 'inside';
              case figma.StrokeAlign.outside:
                return 'outside';
              case figma.StrokeAlign.center:
                return 'center';
            }
          }(),
        'side': {
          'width': strokeWeight,
          if (stroke.type == figma.PaintType.solid && strokeColorName != null)
            'color': StateReference(['theme', 'color', strokeColorName]),
          if (stroke.type !=
              figma.PaintType.solid) // TODO custom gradient borders
            'color': StateReference(
              [
                'theme',
                'color',
                context.theme.colors.create(
                  convertColor(stroke.gradientStops!.first.color!),
                  name,
                ),
              ],
            ),
        },
      },
    },
  };
}
