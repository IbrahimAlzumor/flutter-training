import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const InvoiceScreen(),
    );
  }
}

enum ColAlign { left, center, right }

class ColumnSpec {
  final String key;
  final String label;
  final int weight;
  final ColAlign align;

  const ColumnSpec({
    required this.key,
    required this.label,
    this.weight = 1,
    this.align = ColAlign.left,
  });

  ColumnSpec merge(ColumnSpec? other) {
    if (other == null) return this;
    return ColumnSpec(
      key: other.key,
      label: other.label.isNotEmpty ? other.label : label,
      weight: other.weight > 0 ? other.weight : weight,
      align: other.align,
    );
  }
}

class Labels {
  final String titleEn;
  final String titleAr;
  final String invoiceTo;
  final String invoiceCurrency;
  final String copy;
  final String notes;
  final String authorizedSignature;
  final String totalDue;
  final String pageText;

  const Labels({
    required this.titleEn,
    required this.titleAr,
    required this.invoiceTo,
    required this.invoiceCurrency,
    required this.copy,
    required this.notes,
    required this.authorizedSignature,
    required this.totalDue,
    required this.pageText,
  });

  static const defaults = Labels(
    titleEn: "Tax Invoice",
    titleAr: "فاتورة ضريبية",
    invoiceTo: "INVOICE TO:",
    invoiceCurrency: "INVOICE CURRENCY:",
    copy: "Copy",
    notes: "NOTES",
    authorizedSignature: "Authorized Signature",
    totalDue: "TOTAL DUE",
    pageText: "Page 1/1",
  );

  Labels merge(Labels? other) {
    if (other == null) return this;
    return Labels(
      titleEn: other.titleEn.isNotEmpty ? other.titleEn : titleEn,
      titleAr: other.titleAr.isNotEmpty ? other.titleAr : titleAr,
      invoiceTo: other.invoiceTo.isNotEmpty ? other.invoiceTo : invoiceTo,
      invoiceCurrency: other.invoiceCurrency.isNotEmpty
          ? other.invoiceCurrency
          : invoiceCurrency,
      copy: other.copy.isNotEmpty ? other.copy : copy,
      notes: other.notes.isNotEmpty ? other.notes : notes,
      authorizedSignature: other.authorizedSignature.isNotEmpty
          ? other.authorizedSignature
          : authorizedSignature,
      totalDue: other.totalDue.isNotEmpty ? other.totalDue : totalDue,
      pageText: other.pageText.isNotEmpty ? other.pageText : pageText,
    );
  }
}

class LayoutSpec {
  final PdfPageFormat pageFormat;
  final pw.EdgeInsets margin;
  final double gapSm;
  final double gapMd;
  final double lineThickness;

  final double titleSize;
  final double smallSize;
  final double tableHeaderSize;
  final double tableCellSize;

  const LayoutSpec({
    required this.pageFormat,
    required this.margin,
    required this.gapSm,
    required this.gapMd,
    required this.lineThickness,
    required this.titleSize,
    required this.smallSize,
    required this.tableHeaderSize,
    required this.tableCellSize,
  });

  static LayoutSpec defaults() => LayoutSpec(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
    gapSm: 6,
    gapMd: 12,
    lineThickness: 1,
    titleSize: 18,
    smallSize: 8,
    tableHeaderSize: 8.5,
    tableCellSize: 8.5,
  );

  LayoutSpec merge(LayoutSpec? other) {
    if (other == null) return this;
    return LayoutSpec(
      pageFormat: other.pageFormat,
      margin: other.margin,
      gapSm: other.gapSm,
      gapMd: other.gapMd,
      lineThickness: other.lineThickness,
      titleSize: other.titleSize,
      smallSize: other.smallSize,
      tableHeaderSize: other.tableHeaderSize,
      tableCellSize: other.tableCellSize,
    );
  }
}

class MetaSpec {
  final Map<String, String> left;
  final Map<String, String> right;

  const MetaSpec({required this.left, required this.right});

  static MetaSpec defaults() => const MetaSpec(
    left: {"name": "Ibrahim", "area": "Main Area English"},
    right: {
      "INVOICE NUMBER": "2100000005",
      "INVOICE DATE": "22/09/2026",
      "CUSTOMER ID": "0000034",
    },
  );

  MetaSpec merge(MetaSpec? other) {
    if (other == null) return this;
    return MetaSpec(
      left: {...left, ...other.left},
      right: {...right, ...other.right},
    );
  }
}

class BlocksSpec {
  final bool showArabicTitle;
  final bool showCopy;
  final bool showCurrency;
  final bool showNotes;
  final bool showBarcode;
  final bool showSignatures;
  final bool showFooter;

  const BlocksSpec({
    required this.showArabicTitle,
    required this.showCopy,
    required this.showCurrency,
    required this.showNotes,
    required this.showBarcode,
    required this.showSignatures,
    required this.showFooter,
  });

  static const defaults = BlocksSpec(
    showArabicTitle: true,
    showCopy: true,
    showCurrency: true,
    showNotes: true,
    showBarcode: true,
    showSignatures: true,
    showFooter: true,
  );

  BlocksSpec merge(BlocksSpec? other) {
    if (other == null) return this;
    return BlocksSpec(
      showArabicTitle: other.showArabicTitle,
      showCopy: other.showCopy,
      showCurrency: other.showCurrency,
      showNotes: other.showNotes,
      showBarcode: other.showBarcode,
      showSignatures: other.showSignatures,
      showFooter: other.showFooter,
    );
  }
}

class InvoiceSpec {
  final Labels labels;
  final LayoutSpec layout;
  final MetaSpec meta;
  final BlocksSpec blocks;

  final List<ColumnSpec> columns;
  final List<Map<String, dynamic>> rows;

  final String currencyValue;
  final String barcodeValue;
  final String footerLeft;
  final String footerRight;
  final String footerUrl;

  const InvoiceSpec({
    required this.labels,
    required this.layout,
    required this.meta,
    required this.blocks,
    required this.columns,
    required this.rows,
    required this.currencyValue,
    required this.barcodeValue,
    required this.footerLeft,
    required this.footerRight,
    required this.footerUrl,
  });

  static InvoiceSpec defaults() => InvoiceSpec(
    labels: Labels.defaults,
    layout: LayoutSpec.defaults(),
    meta: MetaSpec.defaults(),
    blocks: BlocksSpec.defaults,
    columns: const [
      ColumnSpec(
        key: "itemNo",
        label: "ITEM NO",
        weight: 1,
        align: ColAlign.left,
      ),
      ColumnSpec(
        key: "description",
        label: "PRODUCT DESCRIPTION",
        weight: 3,
        align: ColAlign.left,
      ),
      ColumnSpec(key: "unit", label: "UNIT", weight: 1, align: ColAlign.center),
      ColumnSpec(
        key: "qty",
        label: "QUANTITY",
        weight: 1,
        align: ColAlign.right,
      ),
      ColumnSpec(
        key: "discount",
        label: "DISCOUNT PRICE",
        weight: 1,
        align: ColAlign.right,
      ),
      ColumnSpec(
        key: "total",
        label: "LINE TOTAL",
        weight: 1,
        align: ColAlign.right,
      ),
    ],
    rows: const [
      {
        "itemNo": "000000019",
        "description":
            "7299012910\nINVOICE NO: 2023 1234565\nوصف عربي تجريبي للسطر\n1256423554",
        "unit": "Piece",
        "qty": 1,
        "discount": 50.62,
        "total": 4.31,
      },
    ],
    currencyValue: "ILS",
    barcodeValue: "2100000005",
    footerLeft: "Bisan Enterprise Demo",
    footerRight: "بيسان انتربرايز - نسخة تجريبية",
    footerUrl: "https://qa.bisan.com:3333/login.html",
  );

  InvoiceSpec merge(InvoiceSpec? other) {
    if (other == null) return this;

    final mergedColumns = _mergeColumns(this.columns, other.columns);

    final mergedRows = other.rows.isNotEmpty ? other.rows : rows;

    return InvoiceSpec(
      labels: labels.merge(other.labels),
      layout: layout.merge(other.layout),
      meta: meta.merge(other.meta),
      blocks: blocks.merge(other.blocks),
      columns: mergedColumns,
      rows: mergedRows,
      currencyValue: other.currencyValue.isNotEmpty
          ? other.currencyValue
          : currencyValue,
      barcodeValue: other.barcodeValue.isNotEmpty
          ? other.barcodeValue
          : barcodeValue,
      footerLeft: other.footerLeft.isNotEmpty ? other.footerLeft : footerLeft,
      footerRight: other.footerRight.isNotEmpty
          ? other.footerRight
          : footerRight,
      footerUrl: other.footerUrl.isNotEmpty ? other.footerUrl : footerUrl,
    );
  }

  static List<ColumnSpec> _mergeColumns(
    List<ColumnSpec> base,
    List<ColumnSpec> incoming,
  ) {
    if (incoming.isEmpty) return base;

    final baseByKey = {for (final c in base) c.key: c};
    final result = <ColumnSpec>[];

    for (final inc in incoming) {
      final b = baseByKey[inc.key];
      result.add((b ?? inc).merge(inc));
    }

    return result;
  }
}

class InvoiceRenderer {
  static pw.TextAlign _ta(ColAlign a) {
    switch (a) {
      case ColAlign.left:
        return pw.TextAlign.left;
      case ColAlign.center:
        return pw.TextAlign.center;
      case ColAlign.right:
        return pw.TextAlign.right;
    }
  }

  static String _fmt(dynamic v) {
    if (v == null) return "";
    if (v is num) return v.toStringAsFixed(2);
    return v.toString();
  }

  static double _sumColumn(List<Map<String, dynamic>> rows, String key) {
    double s = 0;
    for (final r in rows) {
      final v = r[key];
      if (v is num) s += v.toDouble();
    }
    return s;
  }

  static Future<Uint8List> buildPdf(
    InvoiceSpec spec,
    PdfPageFormat format,
  ) async {
    final s = InvoiceSpec.defaults().merge(spec);
    final doc = pw.Document();

    final titleStyle = pw.TextStyle(
      fontSize: s.layout.titleSize,
      fontWeight: pw.FontWeight.bold,
    );
    final smallBold = pw.TextStyle(
      fontSize: s.layout.smallSize,
      fontWeight: pw.FontWeight.bold,
    );
    final small = pw.TextStyle(fontSize: s.layout.smallSize);
    final headerStyle = pw.TextStyle(
      fontSize: s.layout.tableHeaderSize,
      fontWeight: pw.FontWeight.bold,
    );
    final cellStyle = pw.TextStyle(fontSize: s.layout.tableCellSize);

    pw.Widget hLine() =>
        pw.Container(height: s.layout.lineThickness, color: PdfColors.black);

    pw.Widget cell(String text, ColumnSpec col, pw.TextStyle style) {
      return pw.Expanded(
        flex: col.weight <= 0 ? 1 : col.weight,
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: pw.Text(text, style: style, textAlign: _ta(col.align)),
        ),
      );
    }

    pw.Widget rowFromColumns(
      List<ColumnSpec> cols,
      Map<String, dynamic> row,
      pw.TextStyle style,
    ) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [for (final c in cols) cell(_valueForCell(row, c), c, style)],
      );
    }

    pw.Widget headerRow(List<ColumnSpec> cols) {
      return pw.Row(
        children: [for (final c in cols) cell(c.label, c, headerStyle)],
      );
    }

    pw.Widget rightMetaBox(Map<String, String> meta) {
      pw.Widget metaRow(String k, String v) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(k, style: smallBold),
              pw.Text(v, style: smallBold),
            ],
          ),
        );
      }

      final entries = meta.entries.toList();

      return pw.Container(
        width: 200,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 1),
        ),
        child: pw.Column(
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              metaRow(entries[i].key, entries[i].value),
              if (i != entries.length - 1) hLine(),
            ],
          ],
        ),
      );
    }

    final subTotal = _sumColumn(s.rows, "total");
    final vat = 0.0;
    final totalDue = subTotal + vat;

    doc.addPage(
      pw.Page(
        pageFormat: s.layout.pageFormat,
        margin: s.layout.margin,
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(child: pw.Text(s.labels.titleEn, style: titleStyle)),
              if (s.blocks.showArabicTitle) ...[
                pw.SizedBox(height: 2),
                pw.Center(child: pw.Text(s.labels.titleAr, style: smallBold)),
              ],
              pw.SizedBox(height: s.layout.gapMd),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(s.labels.invoiceTo, style: smallBold),
                            pw.SizedBox(width: 6),
                            pw.Text(
                              s.meta.left["name"] ?? "",
                              style: smallBold,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 62),
                          child: pw.Text(
                            s.meta.left["area"] ?? "",
                            style: small,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: s.layout.gapMd),
                  rightMetaBox(s.meta.right),
                ],
              ),

              pw.SizedBox(height: s.layout.gapSm),

              if (s.blocks.showCopy)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [pw.Text(s.labels.copy, style: small)],
                ),

              if (s.blocks.showCurrency)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "${s.labels.invoiceCurrency}  ${s.currencyValue}",
                      style: smallBold,
                    ),
                  ],
                ),

              pw.SizedBox(height: s.layout.gapMd),

              hLine(),
              pw.SizedBox(height: s.layout.gapSm),
              headerRow(s.columns),
              pw.SizedBox(height: s.layout.gapSm),
              hLine(),
              pw.SizedBox(height: s.layout.gapSm),

              for (final r in s.rows) ...[
                rowFromColumns(s.columns, r, cellStyle),
                pw.SizedBox(height: s.layout.gapSm),
              ],

              hLine(),
              pw.SizedBox(height: s.layout.gapMd),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 170,
                    child: pw.Column(
                      children: [
                        _kv(
                          "LINE TOTAL",
                          subTotal.toStringAsFixed(2),
                          smallBold,
                          small,
                        ),
                        _kv(
                          "VAT (0%)",
                          vat.toStringAsFixed(2),
                          smallBold,
                          small,
                        ),
                        _kv(
                          s.labels.totalDue,
                          totalDue.toStringAsFixed(2),
                          pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: s.layout.gapMd),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: s.blocks.showNotes
                        ? pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(s.labels.notes, style: smallBold),
                              pw.SizedBox(height: s.layout.gapSm),
                              pw.Text(
                                "Number of items:   ${s.rows.length}",
                                style: small,
                              ),
                              pw.Text(
                                "Issuing Warehouse:  Ramallah warehouse",
                                style: small,
                              ),
                            ],
                          )
                        : pw.SizedBox(),
                  ),
                  pw.SizedBox(width: s.layout.gapMd),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(s.labels.authorizedSignature, style: small),
                      pw.SizedBox(height: s.layout.gapSm),
                      if (s.blocks.showBarcode)
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.code128(),
                          data: s.barcodeValue,
                          width: 170,
                          height: 34,
                          drawText: false,
                        ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: s.layout.gapMd),

              if (s.blocks.showSignatures)
                pw.Row(
                  children: [
                    for (int i = 1; i <= 3; i++) ...[
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            hLine(),
                            pw.SizedBox(height: 4),
                            pw.Text("Sign $i", style: small),
                          ],
                        ),
                      ),
                      if (i != 3) pw.SizedBox(width: 18),
                    ],
                  ],
                ),

              if (s.blocks.showFooter) ...[
                pw.Spacer(),
                hLine(),
                pw.SizedBox(height: s.layout.gapSm),
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(s.footerLeft, style: smallBold)),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(s.footerRight, style: smallBold),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        "Address",
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          s.labels.pageText,
                          style: const pw.TextStyle(fontSize: 7),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(s.footerUrl, style: const pw.TextStyle(fontSize: 7)),
              ],
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _kv(String k, String v, pw.TextStyle ks, pw.TextStyle vs) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(k, style: ks),
          pw.Text(v, style: vs),
        ],
      ),
    );
  }

  static String _valueForCell(Map<String, dynamic> row, ColumnSpec c) {
    final v = row[c.key];
    if (v == null) return "";
    if (v is num) return v.toStringAsFixed(2);
    return v.toString();
  }
}

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  InvoiceSpec requestSpec = InvoiceSpec.defaults();

  void _simulateIncomingNewColumn() {
    setState(() {
      requestSpec = InvoiceSpec.defaults().merge(
        InvoiceSpec(
          labels: Labels.defaults,
          layout: LayoutSpec.defaults().merge(
            LayoutSpec(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.fromLTRB(20, 18, 20, 18),
              gapSm: 5,
              gapMd: 10,
              lineThickness: 1,
              titleSize: 18,
              smallSize: 8,
              tableHeaderSize: 8.5,
              tableCellSize: 8.5,
            ),
          ),
          meta: MetaSpec.defaults(),
          blocks: BlocksSpec.defaults,
          columns: const [
            ColumnSpec(
              key: "itemNo",
              label: "ITEM NO",
              weight: 1,
              align: ColAlign.left,
            ),
            ColumnSpec(
              key: "description",
              label: "PRODUCT DESCRIPTION",
              weight: 1,
              align: ColAlign.left,
            ),
            ColumnSpec(
              key: "batch",
              label: "BATCH",
              weight: 1,
              align: ColAlign.center,
            ),
            ColumnSpec(
              key: "unit",
              label: "UNIT",
              weight: 1,
              align: ColAlign.center,
            ),
            ColumnSpec(
              key: "qty",
              label: "QUANTITY",
              weight: 1,
              align: ColAlign.right,
            ),
            ColumnSpec(
              key: "total",
              label: "LINE TOTAL",
              weight: 1,
              align: ColAlign.right,
            ),
          ],
          rows: const [
            {
              "itemNo": "000000019",
              "description": "Example with new column",
              "batch": "B-7781",
              "unit": "Piece",
              "qty": 1,
              "total": 4.31,
            },
          ],
          currencyValue: "ILS",
          barcodeValue: "2100000005",
          footerLeft: "Bisan Enterprise Demo",
          footerRight: "بيسان انتربرايز - نسخة تجريبية",
          footerUrl: "https://qa.bisan.com:3333/login.html",
        ),
      );
    });
  }

  Future<void> _printDirectly() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return InvoiceRenderer.buildPdf(requestSpec, format);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generic Invoice (Direct Print)"),
        actions: [
          IconButton(
            onPressed: _simulateIncomingNewColumn,
            icon: const Icon(Icons.add),
            tooltip: "Simulate: New Column From Request",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.print, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Ready to Print",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _printDirectly,
              icon: const Icon(Icons.print),
              label: const Text("PRINT NOW"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
