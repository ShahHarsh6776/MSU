import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_billboard_page.dart';
import 'profile_page.dart';

class OwnerDashboardPage extends StatefulWidget {
  final String ownerId;

  const OwnerDashboardPage({super.key, required this.ownerId});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboardPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> billboards = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchBillboards();
  }

  Future<void> fetchBillboards() async {
    try {
      final response = await supabase
          .from('billboards')
          .select(
            'id, location, size, manual_price, ai_predicted_price, is_bidding_active',
          )
          .eq('owner_id', widget.ownerId);

      List<Map<String, dynamic>> updatedBillboards =
          List<Map<String, dynamic>>.from(response);

      for (var billboard in updatedBillboards) {
        final highestBid =
            await supabase
                .from('bids')
                .select('bid_amount, sponsor_id, sponsors(username)')
                .eq('billboard_id', billboard['id'])
                .order('bid_amount', ascending: false)
                .limit(1)
                .maybeSingle();

        billboard['highest_bid'] =
            highestBid != null ? highestBid['bid_amount'] : 'No Bids';
        billboard['highest_bidder'] =
            highestBid != null ? highestBid['sponsors']['username'] : 'No Bids';
      }

      setState(() {
        billboards = updatedBillboards;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching billboards: $e")));
    }
  }

  Future<void> startBidding(String billboardId, DateTime endTime) async {
    await supabase
        .from('billboards')
        .update({
          'is_bidding_active': true,
          'bidding_end_time': endTime.toIso8601String(),
        })
        .eq('id', billboardId);
    fetchBillboards();
  }

  Future<void> stopBidding(String billboardId) async {
    await supabase
        .from('billboards')
        .update({'is_bidding_active': false})
        .eq('id', billboardId);
    fetchBillboards();
  }

  Widget _buildBillboardList() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : billboards.isEmpty
        ? const Center(child: Text("No billboards found."))
        : ListView.builder(
          itemCount: billboards.length,
          itemBuilder: (context, index) {
            final billboard = billboards[index];
            final bool isBiddingActive = billboard['is_bidding_active'];
            final String billboardId = billboard['id'];

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('📍 Location: ${billboard['location']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📏 Size: ${billboard['size']} sq ft'),
                    Text('💰 Manual Price: \$${billboard['manual_price']}'),
                    Text('🤖 AI Price: \$${billboard['ai_predicted_price']}'),
                    Text(
                      '🏆 Highest Bid: \$${billboard['highest_bid']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '👤 Highest Bidder: ${billboard['highest_bidder']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isBiddingActive
                                  ? null
                                  : () {
                                    DateTime endTime = DateTime.now().add(
                                      const Duration(hours: 2),
                                    );
                                    startBidding(billboardId, endTime);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Start Bidding"),
                        ),
                        ElevatedButton(
                          onPressed:
                              isBiddingActive
                                  ? () => stopBidding(billboardId)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Stop Bidding"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildBillboardList();
      case 1:
        return const Center(child: Text('Add Billboard Page'));
      case 2:
        return const Center(child: Text('Bids Page'));
      case 3:
        return const Center(child: Text('Analytics Page'));
      case 4:
        return const ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddBillboardPage(ownerId: widget.ownerId),
        ),
      );
      if (result == true) fetchBillboards();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Bids'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
