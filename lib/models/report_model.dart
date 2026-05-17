class SalesReport {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalSales;
  final double totalCash;
  final double totalTransfer;
  final double totalQris;
  final double totalReceivable;
  final double totalProfit;
  final List<ProductSales> productSales;
  final Map<String, double>? dailyBreakdown;

  SalesReport({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalSales,
    required this.totalCash,
    required this.totalTransfer,
    required this.totalQris,
    required this.totalReceivable,
    required this.totalProfit,
    required this.productSales,
    this.dailyBreakdown,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalTransactions: json['total_transactions'],
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalCash: (json['total_cash'] ?? 0).toDouble(),
      totalTransfer: (json['total_transfer'] ?? 0).toDouble(),
      totalQris: (json['total_qris'] ?? 0).toDouble(),
      totalReceivable: (json['total_receivable'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      productSales: (json['product_sales'] as List)
          .map((p) => ProductSales.fromJson(p))
          .toList(),
      dailyBreakdown: json['daily_breakdown'] != null
          ? Map<String, double>.from(json['daily_breakdown'])
          : null,
    );
  }
}

class ProductSales {
  final String productName;
  final int quantity;
  final double total;
  final double profit;

  ProductSales({
    required this.productName,
    required this.quantity,
    required this.total,
    required this.profit,
  });

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      productName: json['product_name'],
      quantity: json['quantity'],
      total: (json['total'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
    );
  }
}

class ProfitReport {
  final DateTime startDate;
  final DateTime endDate;
  final EggProfit egg;
  final RiceProfit rice;
  final double grandTotalProfit;
  final double grandTotalSales;

  ProfitReport({
    required this.startDate,
    required this.endDate,
    required this.egg,
    required this.rice,
    required this.grandTotalProfit,
    required this.grandTotalSales,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      startDate: DateTime.parse(json['period']['start_date']),
      endDate: DateTime.parse(json['period']['end_date']),
      egg: EggProfit.fromJson(json['egg']),
      rice: RiceProfit.fromJson(json['rice']),
      grandTotalProfit: (json['grand_total_profit'] ?? 0).toDouble(),
      grandTotalSales: (json['grand_total_sales'] ?? 0).toDouble(),
    );
  }
}

class EggProfit {
  final double totalProfit;
  final double totalSales;
  final List<EggProfitDetail> details;

  EggProfit({
    required this.totalProfit,
    required this.totalSales,
    required this.details,
  });

  factory EggProfit.fromJson(Map<String, dynamic> json) {
    return EggProfit(
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      details: (json['details'] as List)
          .map((d) => EggProfitDetail.fromJson(d))
          .toList(),
    );
  }
}

class EggProfitDetail {
  final String product;
  final double profit;
  final double sales;
  final int quantity;
  final double profitPerUnit;

  EggProfitDetail({
    required this.product,
    required this.profit,
    required this.sales,
    required this.quantity,
    required this.profitPerUnit,
  });

  factory EggProfitDetail.fromJson(Map<String, dynamic> json) {
    return EggProfitDetail(
      product: json['product'],
      profit: (json['profit'] ?? 0).toDouble(),
      sales: (json['sales'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      profitPerUnit: (json['profit_per_unit'] ?? 0).toDouble(),
    );
  }
}

class RiceProfit {
  final double totalProfit;
  final double totalSales;
  final List<RiceProfitDetail> details;

  RiceProfit({
    required this.totalProfit,
    required this.totalSales,
    required this.details,
  });

  factory RiceProfit.fromJson(Map<String, dynamic> json) {
    return RiceProfit(
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      details: (json['details'] as List)
          .map((d) => RiceProfitDetail.fromJson(d))
          .toList(),
    );
  }
}

class RiceProfitDetail {
  final String product;
  final double profit;
  final double sales;
  final int quantity;
  final double profitPerUnit;

  RiceProfitDetail({
    required this.product,
    required this.profit,
    required this.sales,
    required this.quantity,
    required this.profitPerUnit,
  });

  factory RiceProfitDetail.fromJson(Map<String, dynamic> json) {
    return RiceProfitDetail(
      product: json['product'],
      profit: (json['profit'] ?? 0).toDouble(),
      sales: (json['sales'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      profitPerUnit: (json['profit_per_unit'] ?? 0).toDouble(),
    );
  }
}