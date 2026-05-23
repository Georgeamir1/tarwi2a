import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/order.dart';
import '../../../core/logger/app_logger.dart';

class ThermalPrinterService {
  static const _paperSize = PdfPageFormat.roll80;

  Future<bool> printOrder(Order order) async {
    try {
      final pdf = await _generateReceipt(order);
      final printer = await Printing.pickPrinter(
        context: _rootContext!,
        title: 'اختر الطابعة',
      );
      if (printer == null) return false;
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (_) async => pdf,
        format: _paperSize,
        usePrinterSettings: true,
      );
      appLogger.d('[ThermalPrinterService] printOrder success: ${order.id}');
      return true;
    } catch (e) {
      appLogger.e('[ThermalPrinterService] printOrder error', error: e);
      if (e.toString().contains('User cancelled')) return false;
      rethrow;
    }
  }

  static BuildContext? _rootContext;

  static void init(BuildContext context) {
    _rootContext = context;
  }

  Future<Uint8List> _generateReceipt(Order order) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: _paperSize,
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'ترويقه',
                style: pw.TextStyle(font: arabicBold, fontSize: 20),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormat('yyyy/MM/dd - hh:mm a')
                    .format(order.createdAt.toLocal()),
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              pw.Text(
                'طلب #${order.id.substring(0, 8).toUpperCase()}',
                style: pw.TextStyle(font: arabicBold, fontSize: 14),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('العميل: ${order.customerName}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الهاتف: ${order.customerPhone}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textDirection: pw.TextDirection.rtl),
                ],
              ),
              if (order.customerAddress != null) ...[
                pw.SizedBox(height: 2),
                pw.Text('العنوان: ${order.customerAddress}',
                    style: pw.TextStyle(font: arabicFont, fontSize: 11),
                    textDirection: pw.TextDirection.rtl),
              ],
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              ...order.items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${item.productName} × ${item.quantity}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 11),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                        pw.Text(
                          '${item.subtotal.toStringAsFixed(0)} ج',
                          style: pw.TextStyle(font: arabicFont, fontSize: 11),
                        ),
                      ],
                    ),
                  )),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'الإجمالي',
                    style: pw.TextStyle(font: arabicBold, fontSize: 14),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    '${order.totalAmount.toStringAsFixed(0)} جنيه',
                    style: pw.TextStyle(font: arabicBold, fontSize: 14),
                  ),
                ],
              ),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'ملاحظات: ${order.notes}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 10),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
              pw.SizedBox(height: 16),
              pw.Text(
                'شكراً لزيارتكم — بالهنا والشفا',
                style: pw.TextStyle(font: arabicFont, fontSize: 11),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
