import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lighthouse_buffet/core/di/injection.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_invoice.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/create_invoice_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_all_products_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_product_by_barcode_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/local/product_data_source.dart';
import 'package:lighthouse_buffet/features/invoice/domain/usecase/get_all_products_usecase.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/Bloc/create_invoice_bloc.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/Bloc/get_all_products_bloc.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/widget/invoice_widget.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/widget/product_card_widget.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';

class InvoicePage extends StatefulWidget {
  final String uuid;
  const InvoicePage({
    super.key,
    required this.uuid,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  double totalPrice = 0.0;
  List<ProductInvoice> products = [];
  List<OrderRequest> productsForInvoice = [];
  List<ProductModel> productsForSearching = [];
  late ProductDataSource productDataSource;
  late GetProductByBarcodeRepo _getProductByBarcodeRepo;
  late GetAllProductsBloc _getAllProductsBloc;
  late CreateInvoiceBloc _createInvoiceBloc;
  bool _isSearchingByBarcode = false;

  void removeFromInvoice(ProductInvoice productInvoice) {
    setState(() {
      products.remove(productInvoice);
      _updateTotalPrice();
    });
  }

  void _updateTotalPrice() {
    totalPrice = products.fold(
      0.0,
      (prev, p) => prev + (p.product.consumptionPrice * p.quantity),
    );
    productDataSource.updateData(products);
  }

  void updateQuantity(ProductInvoice productInvoice, int newQuantity) {
    setState(() {
      productInvoice.quantity = newQuantity;
      _updateTotalPrice();
    });
  }

  @override
  void initState() {
    super.initState();
    products = [];
    productDataSource = ProductDataSource(
      productData: products,
      onRemove: removeFromInvoice,
    );
    _getProductByBarcodeRepo = getIt<GetProductByBarcodeRepo>();
    _getAllProductsBloc = GetAllProductsBloc(
      GetAllProductsUsecase(getAllProductsRepo: getIt<GetAllProductsRepo>()),
    )..add(GetAllProducts());
    _createInvoiceBloc = CreateInvoiceBloc(getIt<CreateInvoiceRepo>());
  }

  @override
  void dispose() => super.dispose();

  String _getBarcodeErrorMessage(Failures failure) {
    if (failure is ServerFailure) {
      // Check if it's a "product not found" error
      if (failure.message.toLowerCase().contains("no product") ||
          failure.message.toLowerCase().contains("not found")) {
        return "This product is not available in the system. Please try again or contact the reception desk for assistance.";
      }
      return failure.message;
    } else if (failure is OfflineFailure) {
      return "No internet connection. Please check your connection and try again.";
    } else {
      return "An error occurred while searching for the product. Please try again or contact the reception desk for assistance.";
    }
  }

  String _normalizeArabicForSorting(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  int _compareArabicNames(String first, String second) {
    return _normalizeArabicForSorting(first)
        .compareTo(_normalizeArabicForSorting(second));
  }

  bool _isSandwichProduct(ProductModel product) {
    return _normalizeArabicForSorting(product.name)
        .contains(_normalizeArabicForSorting('سندويش'));
  }

  int _productsGridCount(double availableWidth) {
    return 4;
  }

  double _productsGridAspectRatio(double availableWidth) {
    return 1.9;
  }

  Widget _buildProductsGrid(
    List<ProductModel> productsList, {
    required double availableWidth,
  }) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = productsList[index];
          return ProductCardWidget(
            product: product,
            onTap: () {
              addToInvoice(product);
            },
          );
        },
        childCount: productsList.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _productsGridCount(availableWidth),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: _productsGridAspectRatio(availableWidth),
      ),
    );
  }

  Widget _buildProductsTopBar(
    BuildContext context, {
    required int totalCount,
    required bool isSyncing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: darkNavy.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Products",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSyncing
                      ? "Updating product list..."
                      : "Choose products and add them to the invoice.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: grey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSyncing
                  ? orange.withValues(alpha: 0.1)
                  : lightGrey.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              isSyncing ? "Syncing" : "$totalCount items",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSyncing ? orange : darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int itemCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: BoxBorder.all(color: grey.withValues(alpha: 0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$itemCount",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: orange,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySectionCard(
    BuildContext context, {
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: darkNavy.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: grey,
            ),
      ),
    );
  }

  Widget _buildProductsLoadingView(
    BuildContext context, {
    required double availableWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        key: const ValueKey('products-loading'),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              minHeight: 4,
              color: orange,
              backgroundColor: Color(0x1A10375C),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _productsGridCount(availableWidth) * 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _productsGridCount(availableWidth),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: _productsGridAspectRatio(availableWidth),
              ),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.55, end: 1),
                  duration: Duration(milliseconds: 220 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 12),
                        child: child,
                      ),
                    );
                  },
                  child: _buildLoadingProductCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingProductCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final cardWidth = constraints.maxWidth;
        final padding = (cardHeight * 0.11).clamp(10.0, 14.0).toDouble();
        final badgeHeight = (cardHeight * 0.16).clamp(16.0, 22.0).toDouble();
        final titleHeight = (cardHeight * 0.14).clamp(12.0, 18.0).toDouble();
        final subtitleHeight = (cardHeight * 0.1).clamp(10.0, 14.0).toDouble();
        final ctaHeight = (cardHeight * 0.24).clamp(26.0, 38.0).toDouble();
        final innerGap = (cardHeight * 0.06).clamp(6.0, 10.0).toDouble();
        final badgeWidth = (cardWidth * 0.28).clamp(48.0, 72.0).toDouble();
        final subtitleWidth = (cardWidth * 0.48).clamp(82.0, 124.0).toDouble();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: darkNavy.withValues(alpha: 0.06),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: badgeWidth,
                  height: badgeHeight,
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: titleHeight,
                  decoration: BoxDecoration(
                    color: darkNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: innerGap),
                Container(
                  width: subtitleWidth,
                  height: subtitleHeight,
                  decoration: BoxDecoration(
                    color: darkNavy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: innerGap),
                Container(
                  height: ctaHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        orange.withValues(alpha: 0.82),
                        yellow.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsErrorState(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Center(
      key: const ValueKey('products-error'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 56,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: grey,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<GetAllProductsBloc>().add(GetAllProducts());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('products-empty'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: darkNavy.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 54,
                  color: orange.withValues(alpha: 0.92),
                ),
                const SizedBox(height: 18),
                Text(
                  "No products available right now",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "The products list is currently empty. Try refreshing in a moment.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: grey,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentSuccessDialog(String message) async {
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'payment-success',
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _PaymentSuccessDialog(
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handlePaymentSuccess(String message) async {
    await _showPaymentSuccessDialog(message);

    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  void addToInvoice(ProductModel product) {
    setState(() {
      // Find if the product is already in the invoice
      int index = products.indexWhere((p) => p.product.id == product.id);
      if (index > -1) {
        // Check if the current invoice quantity is less than the available product quantity
        if (products[index].quantity < product.quantity) {
          products[index].quantity++;
        } else {
          // Optionally show a message that the maximum has been reached
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cannot add more than available quantity.",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white)),
              backgroundColor: Colors.red[800],
            ),
          );
        }
      } else {
        // Only add if there is at least one unit available
        if (product.quantity > 0) {
          products.add(ProductInvoice(product: product, quantity: 1));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "No available stock for this product.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red[800],
            ),
          );
        }
      }
      // Update the product data source and recalc total price
      _updateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GetAllProductsBloc>.value(
      value: _getAllProductsBloc,
      child: BlocProvider<CreateInvoiceBloc>.value(
        value: _createInvoiceBloc,
        child: BlocListener<CreateInvoiceBloc, CreateInvoiceState>(
          listener: (context, state) async {
            if (state is SuccessCreateInvoice) {
              await _handlePaymentSuccess(state.response.message);
            } else if (state is ExceptionCreateInvoice) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.message),
                ),
              );
            } else if (state is OfflineFailureCreateInvoice) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.orange,
                  content: Text(state.message),
                ),
              );
            }
          },
          child: Builder(builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF1F4F7),
              body: Row(
                children: [
                  // Invoice Sidebar
                  InvoiceWidget(
                    onBarcodeScanned: (value) async {
                      if (_isSearchingByBarcode) {
                        return; // Prevent multiple simultaneous searches
                      }

                      setState(() {
                        _isSearchingByBarcode = true;
                      });

                      // First try to find in local list
                      try {
                        var add = productsForSearching
                            .firstWhere((p) => p.barCode == value);
                        setState(() {
                          _isSearchingByBarcode = false;
                        });
                        addToInvoice(add);
                        return;
                      } catch (e) {
                        // Not found locally, search via API
                      }

                      // Search via API
                      final result = await _getProductByBarcodeRepo
                          .getProductByBarcode(value);

                      if (!mounted) return;
                      setState(() {
                        _isSearchingByBarcode = false;
                      });

                      result.fold(
                        (failure) {
                          if (!mounted) return;
                          String errorMessage =
                              _getBarcodeErrorMessage(failure);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        (response) {
                          if (!mounted) return;
                          if (response.status == "OK" &&
                              response.body != null) {
                            final productBody = response.body!;
                            final product = ProductModel(
                              id: productBody.id,
                              name: productBody.name,
                              costPrice: productBody.costPrice,
                              quantity: productBody.quantity,
                              consumptionPrice: productBody.consumptionPrice,
                              barCode: productBody.barCode,
                            );

                            if (!productsForSearching
                                .any((p) => p.id == product.id)) {
                              productsForSearching.add(product);
                            }

                            addToInvoice(product);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "This product is not available in the system. Please try again or contact the reception desk for assistance.",
                                ),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                      );
                    },
                    productDataSource: productDataSource,
                    totalPrice: totalPrice,
                    onRemove: removeFromInvoice,
                    onQuantityUpdate: updateQuantity,
                    onSubmit: () {
                      if (products.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please add at least one product"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      productsForInvoice.clear();
                      for (var p in products) {
                        productsForInvoice.add(
                          OrderRequest(
                              productId: p.product.id, quantity: p.quantity),
                        );
                      }
                      context.read<CreateInvoiceBloc>().add(
                            CreateInvoice(
                              body: CreateInvoiceRequest(
                                qrCode: widget.uuid,
                                orders: productsForInvoice,
                              ),
                            ),
                          );
                    },
                  ),

                  // Products Grid Section
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: darkNavy.withValues(alpha: 0.06),
                              ),
                            ),
                            child: BlocBuilder<GetAllProductsBloc,
                                GetAllProductsState>(
                              builder: (context, state) {
                                Widget content;

                                if (state is SuccessGettingProducts) {
                                  final productsList = state.response.body
                                      .map<ProductModel>(
                                        (p) => ProductModel.fromMap(p.toMap()),
                                      )
                                      .toList()
                                    ..sort((a, b) =>
                                        _compareArabicNames(a.name, b.name));
                                  final sandwichProducts = productsList
                                      .where(_isSandwichProduct)
                                      .toList();
                                  final regularProducts = productsList
                                      .where((product) =>
                                          !_isSandwichProduct(product))
                                      .toList();
                                  productsForSearching.clear();
                                  for (var product in productsList) {
                                    if (!productsForSearching
                                        .any((p) => p.id == product.id)) {
                                      productsForSearching.add(product);
                                    }
                                  }

                                  content = Column(
                                    key: const ValueKey('products-success'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          10,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: productsList.length,
                                          isSyncing: _isSearchingByBarcode,
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomScrollView(
                                          cacheExtent: 200,
                                          slivers: [
                                            if (regularProducts.isNotEmpty)
                                              SliverPadding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  14,
                                                ),
                                                sliver: _buildProductsGrid(
                                                  regularProducts,
                                                  availableWidth:
                                                      availableWidth - 32,
                                                ),
                                              ),
                                            SliverToBoxAdapter(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  10,
                                                ),
                                                child: _buildSectionHeader(
                                                  context,
                                                  title: "السندويش",
                                                  itemCount:
                                                      sandwichProducts.length,
                                                ),
                                              ),
                                            ),
                                            if (sandwichProducts.isNotEmpty)
                                              SliverPadding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  16,
                                                ),
                                                sliver: _buildProductsGrid(
                                                  sandwichProducts,
                                                  availableWidth:
                                                      availableWidth - 32,
                                                ),
                                              )
                                            else
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                    16,
                                                    0,
                                                    16,
                                                    16,
                                                  ),
                                                  child: _buildEmptySectionCard(
                                                    context,
                                                    message:
                                                        "No products with سندويش in the name.",
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (state is LoadingGetProducts ||
                                    state is GetAllProductsInitial) {
                                  content = Column(
                                    key:
                                        const ValueKey('products-loading-wrap'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          0,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: 0,
                                          isSyncing: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildProductsLoadingView(
                                          context,
                                          availableWidth: availableWidth - 32,
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (state is NoProductsToShow) {
                                  content = Column(
                                    key: const ValueKey('products-empty-wrap'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          0,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: 0,
                                          isSyncing: false,
                                        ),
                                      ),
                                      Expanded(
                                        child:
                                            _buildProductsEmptyState(context),
                                      ),
                                    ],
                                  );
                                } else if (state is ForbiddenGetProducts) {
                                  content = Column(
                                    key: const ValueKey(
                                        'products-forbidden-wrap'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          0,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: 0,
                                          isSyncing: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildProductsErrorState(
                                          context,
                                          title: "Access denied",
                                          message: state.message,
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (state is ExceptionGetProducts) {
                                  content = Column(
                                    key: const ValueKey('products-error-wrap'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          0,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: 0,
                                          isSyncing: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildProductsErrorState(
                                          context,
                                          title: "Couldn't load products",
                                          message: state.message,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  content = Column(
                                    key: const ValueKey(
                                        'products-fallback-wrap'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          0,
                                        ),
                                        child: _buildProductsTopBar(
                                          context,
                                          totalCount: 0,
                                          isSyncing: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildProductsLoadingView(
                                          context,
                                          availableWidth: availableWidth - 32,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: content,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PaymentSuccessDialog extends StatefulWidget {
  final String message;

  const _PaymentSuccessDialog({
    required this.message,
  });

  @override
  State<_PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<_PaymentSuccessDialog> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryMessage = widget.message.trim().isEmpty
        ? "تم حفظ الفاتورة وإتمام العملية بنجاح."
        : widget.message.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Center(
              child: SafeArea(
                minimum: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF11395D),
                          Color(0xFF03233B),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 40,
                          offset: const Offset(0, 24),
                        ),
                        BoxShadow(
                          color: const Color(0xFF24C874).withValues(alpha: 0.2),
                          blurRadius: 36,
                          spreadRadius: -8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -42,
                          right: -26,
                          child: _DialogGlow(
                            size: 132,
                            color: yellow.withValues(alpha: 0.16),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: -22,
                          child: _DialogGlow(
                            size: 118,
                            color: const Color(
                              0xFF24C874,
                            ).withValues(alpha: 0.14),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4AE690),
                                    Color(0xFF17B86B),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2FD782,
                                    ).withValues(alpha: 0.36),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.16),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "تمت عملية الدفع بنجاح",
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              secondaryMessage,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: yellow.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 18,
                                    color: yellow.withValues(alpha: 0.92),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "سيتم الإغلاق تلقائيًا خلال ثانيتين",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.88),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _DialogGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
