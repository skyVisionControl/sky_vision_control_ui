class Detection {
  final String label;
  final double confidence;
  // piksel koordinatları
  final double left, top, right, bottom;

  Detection({
    required this.label,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  // YOLO plugininden gelen map'i dayanıklı şekilde parse et
  factory Detection.fromMap(Map m, {required int imgW, required int imgH}) {
    String label = '${m['class'] ?? m['label'] ?? 'unknown'}';
    final conf = (m['confidence'] ?? m['score'] ?? 0.0).toDouble();

    double l=0, t=0, r=imgW.toDouble(), b=imgH.toDouble();

    if (m['left'] != null) {
      l = (m['left'] as num).toDouble();
      t = (m['top'] as num).toDouble();
      r = (m['right'] as num).toDouble();
      b = (m['bottom'] as num).toDouble();
    } else if (m['x1'] != null) {
      l = (m['x1'] as num).toDouble();
      t = (m['y1'] as num).toDouble();
      r = (m['x2'] as num).toDouble();
      b = (m['y2'] as num).toDouble();
    } else if (m['box'] != null) {
      // [x1,y1,x2,y2] normalized (0..1) olabilir
      final List box = m['box'];
      if (box.length >= 4) {
        l = (box[0] as num).toDouble();
        t = (box[1] as num).toDouble();
        r = (box[2] as num).toDouble();
        b = (box[3] as num).toDouble();
        // normalized geldiyse piksele çevir
        if (l <= 1 && r <= 1 && t <= 1 && b <= 1) {
          l *= imgW; r *= imgW; t *= imgH; b *= imgH;
        }
      }
    }

    // emniyet
    l = l.clamp(0, imgW.toDouble());
    r = r.clamp(0, imgW.toDouble());
    t = t.clamp(0, imgH.toDouble());
    b = b.clamp(0, imgH.toDouble());

    return Detection(label: label, confidence: conf, left: l, top: t, right: r, bottom: b);
  }
}