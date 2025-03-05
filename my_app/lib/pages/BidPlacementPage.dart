import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BidPlacementPage extends StatefulWidget {
  final String billboardId;
  final String location;
  final String size;
  final double basePrice;
  final String companyName;

  const BidPlacementPage({
    super.key,
    required this.billboardId,
    required this.location,
    required this.size,
    required this.basePrice,
    required this.companyName,
  });

  @override
  _BidPlacementPageState createState() => _BidPlacementPageState();
}

class _BidPlacementPageState extends State<BidPlacementPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _bidController = TextEditingController();
  double? _aiPredictedPrice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAiPredictedPrice();
  }

  /// Fetch AI Predicted Price for this billboard
  Future<void> _fetchAiPredictedPrice() async {
    try {
      final data = await _supabase
          .from('billboards')
          .select('ai_predicted_price')
          .eq('id', widget.billboardId)
          .single();

      setState(() {
        _aiPredictedPrice = data['ai_predicted_price']?.toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching AI price: $e")),
      );
    }
  }

  /// Places the bid in the `bids` table
  Future<void> _placeBid() async {
    try {
      final bidAmount = double.tryParse(_bidController.text);
      if (bidAmount == null || bidAmount <= 0) {
        throw Exception("Please enter a valid bid amount.");
      }

      // Example sponsor ID (You need to replace this with the actual sponsor's ID from auth)
      final sponsorId = _supabase.auth.currentUser?.id;

      if (sponsorId == null) {
        throw Exception("Sponsor not logged in.");
      }

      await _supabase.from('bids').insert({
  'billboard_id': widget.billboardId, // Ensure this is a string (UUID)
  'sponsor_id': sponsorId,
  'bid_amount': bidAmount,
  'bid_status': 'Pending', // Correct column name
  'bid_time': DateTime.now().toIso8601String(),

});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid placed successfully!")),
      );

      Navigator.pop(context); // Return to dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Place Bid")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📍 Location: ${widget.location}"),
                  Text("🏢 Company: ${widget.companyName}"),
                  Text("📏 Size: ${widget.size} sq ft"),
                  Text("💰 Base Price: \$${widget.basePrice}"),
                  Text(
                    "🤖 AI Predicted Price: \$${_aiPredictedPrice ?? 'N/A'}",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _bidController,
                    decoration: const InputDecoration(labelText: "Enter your bid amount"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _placeBid, child: const Text("Submit Bid")),
                ],
              ),
      ),
    );
  }
}
