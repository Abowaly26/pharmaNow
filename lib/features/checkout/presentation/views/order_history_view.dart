import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/core/widgets/premium_loading_indicator.dart';
import 'package:pharma_now/features/checkout/data/services/order_service.dart';

class OrderHistoryView extends StatefulWidget {
  final String? orderId;
  const OrderHistoryView({super.key, this.orderId});
  static const routeName = 'OrderHistoryView';

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  bool _hasCheckedInitialOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PharmaAppBar(
        title: 'Order History',
        isBack: true,
        onPressed: () => Navigator.pop(context),
      ),
      body: OrderHistoryBody(
        initialOrderId: widget.orderId,
        onOrderFound: (data) {
          if (!_hasCheckedInitialOrder) {
            _hasCheckedInitialOrder = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showOrderDetails(context, data);
            });
          }
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(orderData: orderData),
    );
  }
}

class OrderHistoryBody extends StatefulWidget {
  final String? initialOrderId;
  final Function(Map<String, dynamic>)? onOrderFound;

  const OrderHistoryBody({super.key, this.initialOrderId, this.onOrderFound});

  @override
  State<OrderHistoryBody> createState() => _OrderHistoryBodyState();
}

class _OrderHistoryBodyState extends State<OrderHistoryBody> {
  final orderService = getIt<OrderService>();
  bool _hasProcessedInitialOrder = false;

  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: orderService.getUserOrders(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _buildBodyContent(context, snapshot),
        );
      },
    );
  }

  Widget _buildBodyContent(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        key: ValueKey('loading'),
        child: PremiumLoadingIndicator(),
      );
    }

    if (snapshot.hasError) {
      return RefreshIndicator(
        key: const ValueKey('error'),
        backgroundColor: ColorManager.primaryColor,
        color: ColorManager.secondaryColor,
        onRefresh: _refresh,
        child: _buildErrorState(),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return RefreshIndicator(
        key: const ValueKey('empty'),
        backgroundColor: ColorManager.primaryColor,
        color: ColorManager.secondaryColor,
        onRefresh: _refresh,
        child: _buildEmptyState(),
      );
    }

    final orders = snapshot.data!.docs;

    // Check for initial order to show details (only once)
    if (widget.initialOrderId != null &&
        widget.onOrderFound != null &&
        !_hasProcessedInitialOrder) {
      _hasProcessedInitialOrder = true;
      try {
        final initialOrderDoc = orders.firstWhere(
          (doc) => doc.id == widget.initialOrderId,
        );
        final data = initialOrderDoc.data() as Map<String, dynamic>;
        data['orderId'] = initialOrderDoc.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onOrderFound!(data);
        });
      } catch (_) {
        // Order not found
      }
    }

    return RefreshIndicator(
      key: const ValueKey('content'),
      backgroundColor: ColorManager.primaryColor,
      color: ColorManager.secondaryColor,
      onRefresh: _refresh,
      child: _buildGroupedListView(orders),
    );
  }

  Widget _buildGroupedListView(List<QueryDocumentSnapshot> orders) {
    final Map<String, List<Map<String, dynamic>>> groupedOrders =
        _groupOrdersByStatus(orders);
    final sections = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];
    int totalIndex = 0;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        final sectionOrders = groupedOrders[section.toLowerCase()];

        if (sectionOrders == null || sectionOrders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: _getStatusColor(section.toLowerCase()),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '$section (${sectionOrders.length})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: ColorManager.blackColor,
                      fontFamily: 'Inter',
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            ...sectionOrders.map((orderData) {
              final itemIndex = totalIndex++;
              final staggeredDelay = (itemIndex % 10) * 40;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + staggeredDelay),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 40 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: OrderCard(orderData: orderData),
                      ),
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupOrdersByStatus(
      List<QueryDocumentSnapshot> orders) {
    final Map<String, List<Map<String, dynamic>>> groups = {
      'pending': [],
      'processing': [],
      'shipped': [],
      'delivered': [],
      'cancelled': [],
    };

    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      data['orderId'] = doc.id;
      final status =
          (data['orderStatus'] ?? 'pending').toString().toLowerCase();

      if (groups.containsKey(status)) {
        groups[status]!.add(data);
      } else {
        groups['pending']!.add(data);
      }
    }

    return groups;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.emptyCart,
                height: 220.h,
                width: 220.w,
              ),
              SizedBox(height: 32.h),
              Text(
                'No Orders Yet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.blackColor,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Your order history will appear here.\nStart shopping to see your orders!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.sp,
                    color: ColorManager.greyColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(32.r),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 80.r,
                  color: Colors.red[300],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Ouch! Failed to load orders',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.blackColor,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Pull down to refresh and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: ColorManager.greyColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final orderId = orderData['orderId'] ?? 'Unknown';
    final orderStatus = orderData['orderStatus'] ?? 'pending';
    final totalAmount = (orderData['totalAmount'] ?? 0.0).toDouble();
    final createdAt = orderData['createdAt'] as Timestamp?;
    final cartItems = orderData['cartItem'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => OrderDetailsSheet(orderData: orderData),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.toString().substring(0, 8)}...',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: ColorManager.blackColor,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          _formatDate(createdAt.toDate()),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            color: ColorManager.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  _buildStatusBadge(orderStatus),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Divider(color: Colors.grey[100], thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: ColorManager.secondaryColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.medication_outlined,
                            size: 16.sp, color: ColorManager.secondaryColor),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '${cartItems.length} Products',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.blackColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${totalAmount.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: ColorManager.secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class OrderDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsSheet({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final cartItems = orderData['cartItem'] as List<dynamic>? ?? [];
    final total = (orderData['totalAmount'] ?? 0.0).toDouble();
    final subtotal = (orderData['subtotal'] ?? 0.0).toDouble();
    final delivery = (orderData['deliveryFee'] ?? 0.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: ColorManager.blackColor,
            ),
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final medicine =
                    item['medicineEntity'] as Map<String, dynamic>? ?? {};
                return _buildItemRow(
                  medicine['name'] ?? 'Unknown',
                  item['count'] ?? 0,
                  (medicine['price'] ?? 0.0).toDouble(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Divider(color: Colors.grey[100], thickness: 1),
          ),
          _buildPriceRow('Subtotal', subtotal),
          SizedBox(height: 10.h),
          _buildPriceRow('Delivery Fee', delivery),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.blackColor,
                ),
              ),
              Text(
                '${total.toStringAsFixed(0)} EGP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: ColorManager.secondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, int count, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.blackColor,
                  ),
                ),
                Text(
                  'Quantity: $count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    color: ColorManager.greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(price * count).toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: ColorManager.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: ColorManager.greyColor,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} EGP',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorManager.blackColor,
          ),
        ),
      ],
    );
  }
}
