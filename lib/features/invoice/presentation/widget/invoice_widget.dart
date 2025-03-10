import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/local/product_data_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InvoiceWidget extends StatefulWidget {
  final ProductDataSource productDataSource;
  final double totalPrice;
  // Replace the text field input with a barcode scanned callback.
  final Function(String barcode) onBarcodeScanned;
  final VoidCallback onSubmit;

  const InvoiceWidget({
    super.key,
    required this.productDataSource,
    required this.totalPrice,
    required this.onBarcodeScanned,
    required this.onSubmit,
  });

  @override
  _InvoiceWidgetState createState() => _InvoiceWidgetState();
}

class _InvoiceWidgetState extends State<InvoiceWidget> {
  final FocusNode _focusNode = FocusNode();
  String _barcodeBuffer = "";

  @override
  void initState() {
    super.initState();
    // Ensure focus is on this widget so it can receive key events.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // If the Enter key is pressed, process the scanned barcode.
      print(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_barcodeBuffer.isNotEmpty) {
          widget.onBarcodeScanned(_barcodeBuffer);
          _barcodeBuffer = "";
        }
      } else {
        // Append printable characters to the buffer.
        // You might need to adjust the filtering logic depending on your scanner.
        final String? character = event.character;
        if (character != null && character.isNotEmpty) {
          _barcodeBuffer += character;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        color: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  const SizedBox(height: 40),
                  SvgPicture.asset(
                    "assets/svg/dark-en-logo.svg",
                    width: MediaQuery.of(context).size.width / 6,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: SfDataGrid(
                      source: widget.productDataSource,
                      rowHeight: 40,
                      headerRowHeight: 50,
                      allowEditing: true,
                      editingGestureType: EditingGestureType.doubleTap,
                      footer: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Total Price: ${widget.totalPrice}",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      columns: <GridColumn>[
                        GridColumn(
                          width: 75,
                          columnName: 'remove',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                          ),
                        ),
                        GridColumn(
                          width: 150,
                          columnName: 'Item',
                          label: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Name'),
                          ),
                        ),
                        GridColumn(
                          width: 75,
                          columnName: 'Qty',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('Qty'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'unit price',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: const Text('Unit Price'),
                          ),
                        ),
                        // New column for the remove button.
                        
                      ],
                    ),
                  ),
                  // Remove the text field widget.
                  // You could show instructions or leave this area empty.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 32.0),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: widget.onSubmit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 32.0),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
