import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void printScreen( printKey) {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();


      final image = await WidgetWraper.fromKey(
        key: printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }
