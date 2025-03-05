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
    print("Fetching billboards for owner: ${widget.ownerId}...");
    try {
      final response = await supabase
          .from('billboards')
          .select(
            'id, owner_id, location, size, manual_price, ai_predicted_price, availability, owner_name',
          )
          .eq('owner_id', widget.ownerId);

      print("Billboards fetched: ${response.length}");

      setState(() {
        billboards = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching billboards: $error");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading billboards: $error")),
      );
    }
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
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  '📍 Location: ${billboard['location']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📏 Size: ${billboard['size']} sq ft'),
                    Text('🏢 Owner: ${billboard['owner_name']}'),
                    Text('💰 Manual Price: \$${billboard['manual_price']}'),
                    Text(
                      '🤖 AI Price: \$${billboard['ai_predicted_price']}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      billboard['availability']
                          ? '✅ Available for Bidding'
                          : '❌ Not Available',
                      style: TextStyle(
                        color:
                            billboard['availability']
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddBillboardPage(ownerId: widget.ownerId),
        ),
      );

      if (result == true) {
        fetchBillboards(); // Refresh billboard list after adding
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
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
