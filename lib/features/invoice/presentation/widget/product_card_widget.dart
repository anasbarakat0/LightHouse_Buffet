// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';

// ignore: must_be_immutable
class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  void Function()? onTap;
  ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Opacity(
                opacity: (product.quantity == 0) ? 0.7 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: navy,
                      ),
                      maxLines: 2,
                    ),
                    const Spacer(),
                    Text(
                      'Price: ${product.consumptionPrice.toStringAsFixed(2)} S.P',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: orange),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    BarcodeWidget(
                      height: 75,
                      data: product.barCode,
                      barcode: Barcode.ean13(drawEndChar: true),
                      drawText: true,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (product.quantity == 0)
            Positioned(
              top: 50,
              child: SvgPicture.asset(
                "assets/svg/out_of_stock.svg",
                width: 160,
                color: Colors.red[800],
              ),
            ),
        ],
      ),
    );
  }
}
