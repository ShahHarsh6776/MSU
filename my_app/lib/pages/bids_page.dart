import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BidsPage extends StatefulWidget {
  final String sponsorId;

  const BidsPage({super.key, required this.sponsorId});

  @override
  State<BidsPage> createState() => _BidsPageState();
}

class _BidsPageState extends State<BidsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBids();
  }

  Future<void> _fetchBids() async {
    setState(() => _isLoading = true);

    try {
      final data = await _supabase
          .from('bids')
          .select('bid_amount, bid_status, billboard_id, billboards(location, size, owner_name)')
          .eq('sponsor_id', widget.sponsorId)
          .order('created_at', ascending: false);

      setState(() {
        _bids = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bids: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Bids')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bids.isEmpty
              ? const Center(child: Text('No bids placed yet.'))
              : ListView.builder(
                  itemCount: _bids.length,
                  itemBuilder: (context, index) {
                    final bid = _bids[index];
                    final billboard = bid['billboards'] ?? {};

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          '📍 Location: ${billboard['location'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🏢 Owner: ${billboard['owner_name'] ?? 'N/A'}'),
                            Text('📏 Size: ${billboard['size'] ?? 'N/A'} sq ft'),
                            Text('💰 Your Bid: \$${bid['bid_amount']}'),
                            Text(
                              '📌 Status: ${bid['bid_status']}',
                              style: TextStyle(
                                color: bid['bid_status'] == 'approved'
                                    ? Colors.green
                                    : bid['bid_status'] == 'pending'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
