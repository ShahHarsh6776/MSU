import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure this is in pubspec.yaml
import 'package:supabase_flutter/supabase_flutter.dart';

class SponsorAnalyticsPage extends StatefulWidget {
  const SponsorAnalyticsPage({super.key});

  @override
  State<SponsorAnalyticsPage> createState() => _SponsorAnalyticsPageState();
}

class _SponsorAnalyticsPageState extends State<SponsorAnalyticsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bids = [];
  bool _isLoading = true;
  String _sponsorId = ""; // Replace with actual sponsor ID retrieval

  @override
  void initState() {
    super.initState();
    _fetchSponsorBids();
    listenToSponsorBids();
  }

  // Fetch initial bids from Supabase
  Future<void> _fetchSponsorBids() async {
    setState(() => _isLoading = true);

    try {
      final data = await _supabase
          .from('bids')
          .select('id, billboard_id, bid_amount, status, created_at')
          .eq('sponsor_id', _sponsorId)
          .order('created_at', ascending: false);

      setState(() {
        _bids = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching bids: $e')));
    }
  }

  // Listen for real-time bid updates
  void listenToSponsorBids() {
    _supabase
        .from('bids')
        .stream(primaryKey: ['id'])
        .eq('sponsor_id', _sponsorId)
        .listen(
          (bids) {
            setState(() {
              _bids =
                  bids.map((bid) => Map<String, dynamic>.from(bid)).toList();
            });
          },
          onError: (error) {
            debugPrint('Error listening to sponsor bids: $error');
          },
        );
  }

  // Build a simple analytics chart
  Widget _buildAnalyticsChart() {
    if (_bids.isEmpty) {
      return const Center(child: Text("No bid data available."));
    }

    // Extract bid amounts for charting
    List<FlSpot> bidData =
        _bids.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            entry.value['bid_amount'].toDouble(),
          );
        }).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: bidData,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.blueAccent,
                ], // Gradient instead of colors
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Build bid list
  Widget _buildBidList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _bids.isEmpty
        ? const Center(child: Text("No bids available."))
        : ListView.builder(
          itemCount: _bids.length,
          itemBuilder: (context, index) {
            final bid = _bids[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text("Bid Amount: \$${bid['bid_amount']}"),
                subtitle: Text("Status: ${bid['status']}"),
                trailing: Text(bid['created_at']),
              ),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sponsor Analytics")),
      body: Column(
        children: [_buildAnalyticsChart(), Expanded(child: _buildBidList())],
      ),
    );
  }
}
