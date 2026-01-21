import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Invoice Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        useMaterial3: true,
      ),
      home: const PrintPreviewScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum PrintAlignment { left, center, right }

class TableColumn {
  String label;
  String key;
  PrintAlignment alignment;
  double widthWeight;

  TableColumn({
    required this.label,
    required this.key,
    this.alignment = PrintAlignment.left,
    this.widthWeight = 1.0,
  });
}

class PrintableItem {
  final String text;
  final TextStyle style;
  final double y;
  final double? guideX;
  final PrintAlignment alignment;
  final bool isSeparator;
  final double width;
  Rect finalRect = Rect.zero;
  bool isValid = true;

  PrintableItem({
    required this.text,
    required this.y,
    this.guideX,
    this.style = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontFamily: 'Roboto',
    ),
    this.alignment = PrintAlignment.left,
    this.isSeparator = false,
    this.width = 0,
  });
}

class PrintPreviewScreen extends StatefulWidget {
  const PrintPreviewScreen({super.key});

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  final double pageWidth = 600;
  final double pageHeight = 840;
  final EdgeInsets pageMargins = const EdgeInsets.all(40.0);

  List<PrintableItem> laidOutItems = [];

  List<TableColumn> activeColumns = [
    TableColumn(
      label: "DESCRIPTION",
      key: "description",
      widthWeight: 1.0,
      alignment: PrintAlignment.left,
    ),
    TableColumn(
      label: "QTY",
      key: "qty",
      widthWeight: 1.0,
      alignment: PrintAlignment.right,
    ),
    TableColumn(
      label: "PRICE",
      key: "price",
      widthWeight: 1.0,
      alignment: PrintAlignment.right,
    ),
    TableColumn(
      label: "TOTAL",
      key: "total",
      widthWeight: 1.0,
      alignment: PrintAlignment.right,
    ),
  ];

  final List<Map<String, dynamic>> invoiceData = [
    {
      "description": "Web Development",
      "qty": 1,
      "price": 1200.00,
      "unit": "Project",
      "total": 1200.00,
    },
    {
      "description": "Hosting Setup",
      "qty": 1,
      "price": 250.00,
      "unit": "Year",
      "total": 250.00,
    },
    {
      "description": "Domain Reg",
      "qty": 2,
      "price": 15.00,
      "unit": "Year",
      "total": 30.00,
    },
    {
      "description": "Consultation",
      "qty": 5,
      "price": 80.00,
      "unit": "Hour",
      "total": 400.00,
    },
  ];

  @override
  void initState() {
    super.initState();
    _createContentAndPerformLayout();
  }

  String formatValue(dynamic value, String key) {
    if (value == null) return "";
    if (value is double && (key == 'price' || key == 'total')) {
      return "\$${value.toStringAsFixed(2)}";
    }
    return value.toString();
  }

  void _createContentAndPerformLayout() {
    final List<PrintableItem> items = [];
    double currentY = pageMargins.top;
    items.add(
      PrintableItem(
        text: "INVOICE",
        y: currentY,
        guideX: pageWidth / 2,
        alignment: PrintAlignment.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: Colors.black,
        ),
      ),
    );
    currentY += 60;

    items.add(
      PrintableItem(
        text: "Tech Solutions Inc.",
        y: currentY,
        guideX: pageMargins.left,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
    items.add(
      PrintableItem(
        text: "Date: Oct 27, 2023",
        y: currentY,
        guideX: pageWidth - pageMargins.right,
        alignment: PrintAlignment.right,
      ),
    );
    currentY += 40;

    double totalWeight = activeColumns.fold(
      0,
      (sum, col) => sum + col.widthWeight,
    );
    double printableWidth = pageWidth - pageMargins.left - pageMargins.right;

    List<double> columnGuides = [];
    double currentX = pageMargins.left;

    for (var col in activeColumns) {
      double colWidth = (col.widthWeight / totalWeight) * printableWidth;

      if (col.alignment == PrintAlignment.left) {
        columnGuides.add(currentX);
      } else if (col.alignment == PrintAlignment.center) {
        columnGuides.add(currentX + (colWidth / 2));
      } else {
        columnGuides.add(currentX + colWidth);
      }

      currentX += colWidth;
    }

    items.add(
      PrintableItem(
        text: "",
        y: currentY,
        isSeparator: true,
        width: printableWidth,
        guideX: pageMargins.left,
      ),
    );
    currentY += 10;

    final headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.black,
    );

    for (int i = 0; i < activeColumns.length; i++) {
      items.add(
        PrintableItem(
          text: activeColumns[i].label,
          y: currentY,
          guideX: columnGuides[i],
          alignment: activeColumns[i].alignment,
          style: headerStyle,
        ),
      );
    }

    currentY += 20;
    items.add(
      PrintableItem(
        text: "",
        y: currentY,
        isSeparator: true,
        width: printableWidth,
        guideX: pageMargins.left,
      ),
    );
    currentY += 20;

    double subtotal = 0;

    for (var rowData in invoiceData) {
      if (rowData.containsKey('total')) {
        subtotal += (rowData['total'] as num).toDouble();
      }

      for (int i = 0; i < activeColumns.length; i++) {
        var col = activeColumns[i];
        String text = formatValue(rowData[col.key], col.key);

        items.add(
          PrintableItem(
            text: text,
            y: currentY,
            guideX: columnGuides[i],
            alignment: col.alignment,
          ),
        );
      }
      currentY += 25;
    }

    currentY += 10;
    items.add(
      PrintableItem(
        text: "",
        y: currentY,
        isSeparator: true,
        width: printableWidth,
        guideX: pageMargins.left,
      ),
    );
    currentY += 20;

    double totalGuide = pageWidth - pageMargins.right;
    items.add(
      PrintableItem(
        text: "Total: ${formatValue(subtotal, 'total')}",
        y: currentY,
        guideX: totalGuide,
        alignment: PrintAlignment.right,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );

    _performLayout(items);
  }

  void _performLayout(List<PrintableItem> items) {
    final List<PrintableItem> processedItems = [];
    for (var item in items) {
      if (item.isSeparator) {
        double finalX = item.guideX ?? pageMargins.left;
        item.finalRect = Rect.fromLTWH(finalX, item.y, item.width, 1);
        item.isValid = true;
        processedItems.add(item);
        continue;
      }

      final textPainter = TextPainter(
        text: TextSpan(text: item.text, style: item.style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: pageWidth);

      final double textWidth = textPainter.width;
      final double textHeight = textPainter.height;
      final double effectiveGuideX = item.guideX ?? pageMargins.left;

      double finalX;
      switch (item.alignment) {
        case PrintAlignment.left:
          finalX = effectiveGuideX;
          break;
        case PrintAlignment.center:
          finalX = effectiveGuideX - (textWidth / 2);
          break;
        case PrintAlignment.right:
          finalX = effectiveGuideX - textWidth;
          break;
      }

      bool isItemValid = true;
      if (finalX < pageMargins.left ||
          (finalX + textWidth) > (pageWidth - pageMargins.right)) {
        isItemValid = false;
      }
      if (item.y < pageMargins.top ||
          (item.y + textHeight) > (pageHeight - pageMargins.bottom)) {
        isItemValid = false;
      }

      item.finalRect = Rect.fromLTWH(finalX, item.y, textWidth, textHeight);
      item.isValid = isItemValid;
      processedItems.add(item);
    }

    setState(() {
      laidOutItems = processedItems;
    });
  }

  Future<void> _printDocument() async {
    final doc = pw.Document();
    final customPageFormat = PdfPageFormat(pageWidth, pageHeight, marginAll: 0);

    doc.addPage(
      pw.Page(
        pageFormat: customPageFormat,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: laidOutItems.where((item) => item.isValid).map((item) {
              if (item.isSeparator) {
                return pw.Positioned(
                  left: item.finalRect.left,
                  top: item.finalRect.top,
                  child: pw.Container(
                    width: item.finalRect.width,
                    height: 1,
                    color: PdfColors.black,
                  ),
                );
              }
              return pw.Positioned(
                left: item.finalRect.left,
                top: item.finalRect.top,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: item.text.split('\n').map((line) {
                    return pw.Text(
                      line,
                      style: pw.TextStyle(
                        fontSize: item.style.fontSize,
                        fontWeight: item.style.fontWeight == FontWeight.bold
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                        color: PdfColor.fromInt(
                          item.style.color?.value ?? Colors.black.value,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  void _showColumnSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Configure Columns"),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...activeColumns.map(
                      (col) => ListTile(
                        title: Text(col.label),
                        subtitle: Text("Key: ${col.key}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setStateDialog(() {
                              activeColumns.remove(col);
                            });
                            _createContentAndPerformLayout();
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add 'Unit Type' Column"),
                      onPressed: () {
                        setStateDialog(() {
                          if (!activeColumns.any((c) => c.key == 'unit')) {
                            activeColumns.insert(
                              2,
                              TableColumn(
                                label: "UNIT",
                                key: "unit",
                                widthWeight: 1.0,
                                alignment: PrintAlignment.center,
                              ),
                            );
                          }
                        });
                        _createContentAndPerformLayout();
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      child: const Text("Reset to Default (Even Spacing)"),
                      onPressed: () {
                        setStateDialog(() {
                          activeColumns = [
                            TableColumn(
                              label: "DESCRIPTION",
                              key: "description",
                              widthWeight: 1.0,
                              alignment: PrintAlignment.left,
                            ),
                            TableColumn(
                              label: "QTY",
                              key: "qty",
                              widthWeight: 1.0,
                              alignment: PrintAlignment.right,
                            ),
                            TableColumn(
                              label: "PRICE",
                              key: "price",
                              widthWeight: 1.0,
                              alignment: PrintAlignment.right,
                            ),
                            TableColumn(
                              label: "TOTAL",
                              key: "total",
                              widthWeight: 1.0,
                              alignment: PrintAlignment.right,
                            ),
                          ];
                        });
                        _createContentAndPerformLayout();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showColumnSettings,
            tooltip: "Configure Columns",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomPaint(
                      size: Size(pageWidth, pageHeight),
                      painter: PagePreviewPainter(
                        pageWidth: pageWidth,
                        pageHeight: pageHeight,
                        margins: pageMargins,
                        items: laidOutItems,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printDocument,
              icon: const Icon(Icons.print),
              label: const Text("PRINT INVOICE"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PagePreviewPainter extends CustomPainter {
  final double pageWidth;
  final double pageHeight;
  final EdgeInsets margins;
  final List<PrintableItem> items;

  PagePreviewPainter({
    required this.pageWidth,
    required this.pageHeight,
    required this.margins,
    required this.items,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(2, 2, pageWidth, pageHeight),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      Paint()..style = PaintingStyle.stroke,
    );

    for (var item in items) {
      if (item.isSeparator) {
        canvas.drawRect(item.finalRect, Paint()..color = Colors.black);
        continue;
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: item.isValid
              ? item.style
              : item.style.copyWith(color: Colors.red),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: pageWidth);

      textPainter.paint(canvas, item.finalRect.topLeft);

      if (!item.isValid) {
        canvas.drawRect(
          item.finalRect,
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
