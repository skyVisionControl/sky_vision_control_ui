import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

/// OCR servisi - Alkolmetre ekranındaki sayıları okur
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// ROI PNG/JPEG byte'larından en iyi **sayısal** değeri döndürür (örn. 0.45)
  Future<String?> readNumeric(Uint8List roiBytes) async {
    // En sağlam yol: geçici dosyaya yazıp fromFilePath kullanmak
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/roi_${DateTime.now().millisecondsSinceEpoch}.png');
    await f.writeAsBytes(roiBytes, flush: true);

    final input = InputImage.fromFile(f);
    final result = await _recognizer.processImage(input);

    // Tüm metni birleştir
    final text = result.text.replaceAll('\n', ' ').trim();

    // en olası numeric (virgül veya noktalı) yakala
    final reg = RegExp(r'(\d+[.,]?\d*)');
    final match = reg.allMatches(text).map((m) => m.group(1)!).toList();

    await f.delete().catchError((_) {});

    if (match.isEmpty) return null;

    // Basit seçim: en uzun olanı al
    match.sort((a,b) => b.length.compareTo(a.length));
    // virgülü noktaya çevir
    return match.first.replaceAll(',', '.');
  }

  Future<void> dispose() async => _recognizer.close();
}