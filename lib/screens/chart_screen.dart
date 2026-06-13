import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_theme.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedSymbol = 'XAUUSD';
  String _selectedInterval = '1H';

  final List<Map<String, String>> _symbols = [
    {'label': 'XAU/USD (Gold)', 'value': 'XAUUSD', 'icon': '🥇'},
    {'label': 'BTC/USD (Bitcoin)', 'value': 'BTCUSD', 'icon': '₿'},
    {'label': 'EUR/USD', 'value': 'EURUSD', 'icon': '💶'},
    {'label': 'GBP/USD', 'value': 'GBPUSD', 'icon': '💷'},
  ];

  final List<String> _intervals = ['1m', '5m', '15m', '1H', '4H', '1D'];

  String _getTradingViewInterval(String interval) {
    switch (interval) {
      case '1m': return '1';
      case '5m': return '5';
      case '15m': return '15';
      case '1H': return '60';
      case '4H': return '240';
      case '1D': return 'D';
      default: return '60';
    }
  }

  String _buildChartUrl() {
    final tvInterval = _getTradingViewInterval(_selectedInterval);
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #0A1628; }
    .tradingview-widget-container { width: 100%; height: 100vh; }
  </style>
</head>
<body>
  <div class="tradingview-widget-container">
    <div id="tv_chart"></div>
    <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
    <script type="text/javascript">
    new TradingView.widget({
      "width": "100%",
      "height": "100%",
      "symbol": "$_selectedSymbol",
      "interval": "$tvInterval",
      "timezone": "Asia/Jakarta",
      "theme": "dark",
      "style": "1",
      "locale": "id",
      "toolbar_bg": "#0A1628",
      "enable_publishing": false,
      "hide_top_toolbar": false,
      "hide_legend": false,
      "save_image": false,
      "container_id": "tv_chart",
      "backgroundColor": "#0A1628",
      "gridColor": "#1E3A5F"
    });
    </script>
  </div>
</body>
</html>
''';
  }

  late WebViewController _webController;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildChartUrl());
  }

  void _reloadChart() {
    _webController.loadHtmlString(_buildChartUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, -0.2),
          colors: [Color(0xFF0D3B2E), AppTheme.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Live Chart',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Symbol selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _symbols.map((s) {
                  final selected = _selectedSymbol == s['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSymbol = s['value']!);
                      _reloadChart();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryGreen
                            : AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryGreen
                              : AppTheme.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(s['icon']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            s['label']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppTheme.primaryDark
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Interval selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _intervals.map((interval) {
                  final selected = _selectedInterval == interval;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedInterval = interval);
                      _reloadChart();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accentGold.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppTheme.accentGold
                              : AppTheme.borderColor,
                        ),
                      ),
                      child: Text(
                        interval,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppTheme.accentGold
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Chart WebView
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: WebViewWidget(controller: _webController),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
