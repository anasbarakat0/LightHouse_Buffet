import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_invoice.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductDataSource extends DataGridSource {
  final Function(ProductInvoice) onRemove;

  ProductDataSource({
    required List<ProductInvoice> productData,
    required this.onRemove,
  }) {
    _productData = productData.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<ProductInvoice>(columnName: 'remove', value: e),
        DataGridCell<String>(columnName: 'Item', value: e.product.name),
        DataGridCell<int>(columnName: 'Qty', value: e.quantity),
        DataGridCell<double>(columnName: 'unit price', value: e.product.consumptionPrice),
        // Add a cell for the remove action.
      ]);
    }).toList();
  }

  List<DataGridRow> _productData = [];

  @override
  List<DataGridRow> get rows => _productData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.columnName == "remove") {
          return Container(
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Call the callback with the current product invoice.
                onRemove(e.value as ProductInvoice);
              },
            ),
          );
        }
        return Container(
          alignment: e.columnName == "Qty"
              ? Alignment.center
              : e.columnName == "Item"
                  ? Alignment.centerLeft
                  : Alignment.bottomRight,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            e.value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}