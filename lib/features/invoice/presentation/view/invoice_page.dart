// ignore_for_file: public_member_api_docs
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/view/scan_page.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/product_invoice.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/create_invoice_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_all_products_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/local/product_data_source.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/create_invoice_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_all_products_service.dart';
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
  int perPage = 50;
  int currentPage = 1;
  late TextEditingController _controller;

  void removeFromInvoice(ProductInvoice productInvoice) {
    setState(() {
      products.remove(productInvoice);
      totalPrice = products.fold(
        0.0,
        (prev, p) => prev + (p.product.consumptionPrice * p.quantity),
      );
      productDataSource = ProductDataSource(
        productData: products,
        onRemove: removeFromInvoice,
      );
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      productDataSource = ProductDataSource(
        productData: products,
        onRemove: removeFromInvoice,
      );
      totalPrice = products.fold(
        0.0,
        (prev, p) => prev + (p.product.consumptionPrice * p.quantity),
      );
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
                ),
              ),
            ),
          )..add(GetAllProducts(page: currentPage, size: perPage)),
        ),
        BlocProvider(
          create: (context) => CreateInvoiceBloc(
            CreateInvoiceRepo(
              createInvoiceService: CreateInvoiceService(dio: Dio()),
              networkConnection: NetworkConnection(
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
          body: Row(
            children: [
              InvoiceWidget(
                onBarcodeScanned: (value) {
                  print("Scanned barcode: $value");
                  try {
                    // Find the product by barcode (ensure uniqueness by id)
                    var add = productsForSearching
                        .firstWhere((p) => p.barCode == value);
                    addToInvoice(add);
                  } catch (e) {
                    print("No element found with barcode: $value");
                  }
                },
                productDataSource: productDataSource,
                totalPrice: totalPrice,
                onSubmit: () {
                  // Clear previous orders to avoid duplicates
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
              Container(
                width: MediaQuery.of(context).size.width * 2 / 3,
                height: MediaQuery.of(context).size.height,
                color: navy,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: SvgPicture.asset(
                        "assets/svg/lighthouse_ch.svg",
                        width: MediaQuery.of(context).size.width / 2.5,
                      ),
                    ),
                    // Use Positioned.fill to fill available space
                    Positioned.fill(
                      child:
                          BlocConsumer<GetAllProductsBloc, GetAllProductsState>(
                        listener: (context, state) {
                          print("Products state: ${state.runtimeType}");
                        },
                        builder: (context, state) {
                          if (state is SuccessGettingProducts) {
                            // Optionally, refresh the productsForSearching list only once:
                            // Here we clear and add unique products from the response.
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.88,
                                      ),
                                      itemCount: state.response.body.length,
                                      itemBuilder: (context, index) {
                                        var product = ProductModel.fromMap(
                                          state.response.body[index].toMap(),
                                        );
                                        return InkWell(
                                          onTap: () {
                                            addToInvoice(product);
                                          },
                                          child: ProductCardWidget(
                                            product: product,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (state is LoadingGetProducts) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Loading...",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 20),
                                CircularProgressIndicator(),
                              ],
                            );
                          } else {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Loading...",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 20),
                                CircularProgressIndicator(),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
