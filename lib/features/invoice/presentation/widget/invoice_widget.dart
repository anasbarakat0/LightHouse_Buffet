import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_invoice.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/local/product_data_source.dart';

class InvoiceWidget extends StatefulWidget {
  final ProductDataSource productDataSource;
  final double totalPrice;
  final Function(String barcode) onBarcodeScanned;
  final VoidCallback onSubmit;
  final Function(ProductInvoice) onRemove;
  final Function(ProductInvoice, int)? onQuantityUpdate;

  const InvoiceWidget({
    super.key,
    required this.productDataSource,
    required this.totalPrice,
    required this.onBarcodeScanned,
    required this.onSubmit,
    required this.onRemove,
    this.onQuantityUpdate,
  });

  @override
  State<InvoiceWidget> createState() => _InvoiceWidgetState();
}

class _InvoiceWidgetState extends State<InvoiceWidget> {
  final FocusNode _focusNode = FocusNode();
  String _barcodeBuffer = "";

  List<ProductInvoice> get _invoiceItems {
    return widget.productDataSource.rows.map((row) {
      return row
          .getCells()
          .firstWhere((cell) => cell.columnName == 'remove')
          .value as ProductInvoice;
    }).toList(growable: false);
  }

  int get _totalUnits {
    return _invoiceItems.fold(0, (sum, item) => sum + item.quantity);
  }

  String _currency(double amount) => '${amount.toStringAsFixed(2)} S.P';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestScannerFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _requestScannerFocus() {
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_barcodeBuffer.isNotEmpty) {
        widget.onBarcodeScanned(_barcodeBuffer);
        _barcodeBuffer = "";
      }
      return;
    }

    final character = event.character;
    if (character != null && character.isNotEmpty) {
      _barcodeBuffer += character;
    }
  }

  Future<void> _openQuantityDialog(ProductInvoice productInvoice) async {
    await _showQuantityDialog(productInvoice);
    _requestScannerFocus();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceItems = _invoiceItems;
    final itemCount = invoiceItems.length;
    final panelWidth =
        (MediaQuery.sizeOf(context).width * 0.29).clamp(320.0, 392.0);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _requestScannerFocus,
        child: Container(
          width: panelWidth.toDouble(),
          color: const Color(0xFFF5F7FA),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  _buildHeader(
                    context,
                    itemCount: itemCount,
                    totalUnits: _totalUnits,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: darkNavy.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildListHeader(context, itemCount: itemCount),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: itemCount == 0
                                  ? _buildEmptyState(context)
                                  : ListView.separated(
                                      key: const ValueKey('invoice-list'),
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        8,
                                        10,
                                        10,
                                      ),
                                      itemCount: itemCount,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        return _buildInvoiceItemCard(
                                          context,
                                          productInvoice: invoiceItems[index],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFooter(
                    context,
                    itemCount: itemCount,
                    totalUnits: _totalUnits,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required int itemCount,
    required int totalUnits,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkNavy.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Invoice",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _buildFocusChip(context),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildStatChip(context, label: "Items", value: "$itemCount"),
              _buildStatChip(context, label: "Units", value: "$totalUnits"),
              _buildStatChip(
                context,
                label: "Total",
                value: _currency(widget.totalPrice),
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusChip(BuildContext context) {
    final isReady = _focusNode.hasFocus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color:
            isReady ? const Color(0x1431C178) : yellow.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isReady ? const Color(0xFF31C178) : yellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isReady ? "Scanner ready" : "Tap to focus",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: darkNavy,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required String value,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted
            ? orange.withValues(alpha: 0.1)
            : lightGrey.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: highlighted ? orange : darkNavy,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, {required int itemCount}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: darkNavy.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Selected products",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (itemCount > 0)
            Text(
              "$itemCount",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: orange,
                    fontWeight: FontWeight.w800,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('invoice-empty'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 28,
                color: orange.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "No products selected",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              "Scan a product to add it here.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItemCard(
    BuildContext context, {
    required ProductInvoice productInvoice,
  }) {
    final product = productInvoice.product;
    final quantity = productInvoice.quantity;
    final itemTotal = product.consumptionPrice * quantity;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _openQuantityDialog(productInvoice);
        },
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFDFE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: darkNavy.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: darkNavy,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "x$quantity",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: orange,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      widget.onRemove(productInvoice);
                      _requestScannerFocus();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildItemChip(
                    context,
                    label: "Unit",
                    value: _currency(product.consumptionPrice),
                  ),
                  _buildItemChip(
                    context,
                    label: "Total",
                    value: _currency(itemTotal),
                    highlighted: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemChip(
    BuildContext context, {
    required String label,
    required String value,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? orange.withValues(alpha: 0.1)
            : lightGrey.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: highlighted ? orange : darkNavy,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context, {
    required int itemCount,
    required int totalUnits,
  }) {
    final canSubmit = itemCount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkNavy.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grand total",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: grey,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currency(widget.totalPrice),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                "$itemCount items / $totalUnits units",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: grey,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkNavy,
                    side: BorderSide(
                      color: darkNavy.withValues(alpha: 0.12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canSubmit ? widget.onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: grey.withValues(alpha: 0.35),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Submit Invoice",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showQuantityDialog(ProductInvoice productInvoice) async {
    final quantityController = TextEditingController(
      text: productInvoice.quantity.toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            productInvoice.product.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                onChanged: (value) {
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: orange,
                    iconSize: 32,
                    onPressed: () {
                      final currentQty =
                          int.tryParse(quantityController.text) ?? 1;
                      if (currentQty > 1) {
                        quantityController.text = (currentQty - 1).toString();
                        setDialogState(() {});
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quantityController.text,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: orange,
                    iconSize: 32,
                    onPressed: () {
                      final currentQty =
                          int.tryParse(quantityController.text) ?? 1;
                      final maxQty = productInvoice.product.quantity;
                      if (currentQty < maxQty) {
                        quantityController.text = (currentQty + 1).toString();
                        setDialogState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Maximum quantity is $maxQty"),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Max: ${productInvoice.product.quantity}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newQty = int.tryParse(quantityController.text) ?? 1;
                if (newQty > 0 && newQty <= productInvoice.product.quantity) {
                  if (widget.onQuantityUpdate != null) {
                    widget.onQuantityUpdate!(productInvoice, newQty);
                  } else {
                    productInvoice.quantity = newQty;
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Invalid quantity. Must be between 1 and ${productInvoice.product.quantity}",
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
              ),
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
