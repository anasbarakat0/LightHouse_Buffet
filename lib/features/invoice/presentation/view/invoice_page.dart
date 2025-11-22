// ignore_for_file: public_member_api_docs
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/view/scan_page.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_invoice.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/create_invoice_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_all_products_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_product_by_barcode_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/local/product_data_source.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/create_invoice_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_all_products_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_product_by_barcode_service.dart';
import 'package:lighthouse_buffet/features/invoice/domain/usecase/get_all_products_usecase.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/Bloc/create_invoice_bloc.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/Bloc/get_all_products_bloc.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/widget/invoice_widget.dart';
import 'package:lighthouse_buffet/features/invoice/presentation/widget/product_card_widget.dart';

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
  List<ProductModel> productsForSearching = []; // Will only add unique products
  late ProductDataSource productDataSource;
  late TextEditingController _controller;
  late GetProductByBarcodeRepo _getProductByBarcodeRepo;
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
    productDataSource = ProductDataSource(
      productData: products,
      onRemove: removeFromInvoice,
    );
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
    _controller = TextEditingController();
    products = [];
    productDataSource = ProductDataSource(
      productData: products,
      onRemove: removeFromInvoice,
    );

    // Initialize barcode search repository
    final dio = Dio();
    final service = GetProductByBarcodeService(dio: dio);
    final networkConnection = NetworkConnection(
      internetConnectionChecker: InternetConnectionChecker.createInstance(
        addresses: [
          AddressCheckOption(
            uri: Uri.parse("https://www.google.com"),
            timeout: const Duration(seconds: 3),
          ),
          AddressCheckOption(
            uri: Uri.parse("https://1.1.1.1"),
            timeout: const Duration(seconds: 3),
          ),
        ],
      ),
    );
    _getProductByBarcodeRepo = GetProductByBarcodeRepo(
      getProductByBarcodeService: service,
      networkConnection: networkConnection,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetAllProductsBloc(
            GetAllProductsUsecase(
              getAllProductsRepo: GetAllProductsRepo(
                getAllProductsService: GetAllProductsService(dio: Dio()),
                networkConnection: NetworkConnection(
                  internetConnectionChecker:
                      InternetConnectionChecker.createInstance(
                    addresses: [
                      AddressCheckOption(
                        uri: Uri.parse("https://www.google.com"),
                        timeout: const Duration(seconds: 3),
                      ),
                      AddressCheckOption(
                        uri: Uri.parse("https://1.1.1.1"),
                        timeout: const Duration(seconds: 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )..add(GetAllProducts()),
        ),
        BlocProvider(
          create: (context) => CreateInvoiceBloc(
            CreateInvoiceRepo(
              createInvoiceService: CreateInvoiceService(dio: Dio()),
              networkConnection: NetworkConnection(
                internetConnectionChecker:
                    InternetConnectionChecker.createInstance(
                  addresses: [
                    AddressCheckOption(
                      uri: Uri.parse("https://www.google.com"),
                      timeout: const Duration(seconds: 3),
                    ),
                    AddressCheckOption(
                      uri: Uri.parse("https://1.1.1.1"),
                      timeout: const Duration(seconds: 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        BlocListener<CreateInvoiceBloc, CreateInvoiceState>(
          listener: (context, state) {
            if (state is SuccessCreateInvoice) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanPage(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(state.response.message),
                ),
              );
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
          child: Container(), // wrap your UI tree here
        ),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: darkNavy,
          body: Row(
            children: [
              // Invoice Sidebar
              InvoiceWidget(
                onBarcodeScanned: (value) async {
                  if (_isSearchingByBarcode)
                    return; // Prevent multiple simultaneous searches

                  print("Scanned barcode: $value");

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
                  final result =
                      await _getProductByBarcodeRepo.getProductByBarcode(value);

                  setState(() {
                    _isSearchingByBarcode = false;
                  });

                  result.fold(
                    (failure) {
                      // Handle error
                      String errorMessage = _getBarcodeErrorMessage(failure);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    (response) {
                      // Handle success
                      if (response.status == "OK" && response.body != null) {
                        // Convert ProductByBarcodeBody to ProductModel
                        final productBody = response.body!;
                        final product = ProductModel(
                          id: productBody.id,
                          name: productBody.name,
                          costPrice: productBody.costPrice,
                          quantity: productBody.quantity,
                          consumptionPrice: productBody.consumptionPrice,
                          barCode: productBody.barCode,
                        );

                        // Add to local list if not already there
                        if (!productsForSearching
                            .any((p) => p.id == product.id)) {
                          productsForSearching.add(product);
                        }

                        addToInvoice(product);
                      } else {
                        // Invalid response
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "This product is not available in the system. Please try again or contact the reception desk for assistance.",
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 4),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [navy, darkNavy],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: SvgPicture.asset(
                            "assets/svg/lighthouse_ch.svg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Products Grid
                      BlocConsumer<GetAllProductsBloc, GetAllProductsState>(
                        listener: (context, state) {
                          print("Products state: ${state.runtimeType}");
                        },
                        builder: (context, state) {
                          if (state is SuccessGettingProducts) {
                            productsForSearching.clear();
                            for (var pMap in state.response.body) {
                              var product = ProductModel.fromMap(pMap.toMap());
                              if (!productsForSearching
                                  .any((p) => p.id == product.id)) {
                                productsForSearching.add(product);
                              }
                            }

                            return Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: darkNavy.withOpacity(0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: SafeArea(
                                    bottom: false,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          color: orange,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Products",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: orange.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: orange.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            "${state.response.body.length} items",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: orange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Products Grid
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 1.7,
                                      ),
                                      itemCount: state.response.body.length,
                                      itemBuilder: (context, index) {
                                        var product = ProductModel.fromMap(
                                          state.response.body[index].toMap(),
                                        );
                                        return ProductCardWidget(
                                          product: product,
                                          onTap: () {
                                            addToInvoice(product);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (state is LoadingGetProducts) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: orange,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Loading Products...",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Error loading products",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
