import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BidPlacementPage extends StatefulWidget {
  final String billboardId;
  final String location;
  final String size;
  final double basePrice;
  final String companyName;
  final String sponsorId;

  const BidPlacementPage({
    super.key,
    required this.billboardId,
    required this.location,
    required this.size,
    required this.basePrice,
    required this.companyName,
    required this.sponsorId,
  });

  @override
  State<BidPlacementPage> createState() => _BidPlacementPageState();
}

class _BidPlacementPageState extends State<BidPlacementPage> {
  final _bidAmountController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isBiddingActive = false;
  double? _highestBid;

  @override
  void initState() {
    super.initState();
    _fetchBiddingStatus();
    _fetchHighestBid();
  }

  Future<void> _fetchBiddingStatus() async {
    final response =
        await _supabase
            .from('billboards')
            .select('is_bidding_active')
            .eq('id', widget.billboardId)
            .maybeSingle();

    if (response != null && response['is_bidding_active'] == true) {
      setState(() {
        _isBiddingActive = true;
      });
    }
  }

  Future<void> _fetchHighestBid() async {
    final response =
        await _supabase
            .from('bids')
            .select('bid_amount, bid_status')
            .eq('billboard_id', widget.billboardId)
            .order('bid_amount', ascending: false)
            .limit(1)
            .maybeSingle();

    if (response != null && response['bid_status'] == 'approved') {
      setState(() {
        _highestBid = response['bid_amount'];
      });
    }
  }

  Future<void> _placeBid() async {
    final bidAmount = double.tryParse(_bidAmountController.text.trim());
    if (bidAmount == null || bidAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid bid amount')));
      return;
    }

    if (_highestBid != null && bidAmount <= _highestBid!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bid must be higher than the current highest approved bid.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabase.from('bids').insert({
        'billboard_id': widget.billboardId,
        'sponsor_id': widget.sponsorId,
        'bid_amount': bidAmount,
        'bid_status': 'pending',
      });

      _fetchHighestBid();
      _bidAmountController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bid placed successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing bid: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place a Bid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Location: ${widget.location}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('🏢 Owner: ${widget.companyName}'),
            Text('📏 Size: ${widget.size} sq ft'),
            Text('💰 Base Price: \$${widget.basePrice}'),
            if (_highestBid != null)
              Text(
                '🏆 Highest Approved Bid: \$$_highestBid',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            if (!_isBiddingActive)
              const Text(
                '❌ Bidding is currently closed for this billboard.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_isBiddingActive) ...[
              TextField(
                controller: _bidAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Your Bid Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _placeBid,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Place Bid'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
