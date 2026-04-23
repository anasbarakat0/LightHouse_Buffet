import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
  });

  String _currency(double amount) => '${amount.toStringAsFixed(2)} S.P';

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.quantity == 0;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isOutOfStock ? const Color(0xFFF5F6F8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOutOfStock
                  ? Colors.red.withValues(alpha: 0.14)
                  : darkNavy.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 7,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: isOutOfStock
                    //         ? Colors.red.withValues(alpha: 0.08)
                    //         : orange.withValues(alpha: 0.1),
                    //     borderRadius: BorderRadius.circular(9),
                    //   ),
                    //   child: Text(
                    //     isOutOfStock ? "Unavailable" : "Available",
                    //     style: textTheme.bodySmall?.copyWith(
                    //       color: isOutOfStock ? Colors.red : orange,
                    //       fontWeight: FontWeight.w700,
                    //       fontSize: 11,
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),
                    Icon(
                      isOutOfStock
                          ? Icons.block_outlined
                          : Icons.add_circle_outline_rounded,
                      size: 16,
                      color: isOutOfStock ? Colors.red : darkNavy,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      product.name,
                      // textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: isOutOfStock ? grey : darkNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.2,
                        locale: const Locale('ar'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        isOutOfStock
                            ? "Out of stock"
                            : _currency(product.consumptionPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isOutOfStock ? Colors.red : darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // if (!isOutOfStock)
                    //   Text(
                    //     "${product.quantity} left",
                    //     style: textTheme.bodySmall?.copyWith(
                    //       color: grey,
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 11,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
