import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/pages/profile_page.dart';
import 'sponsor_analytics_page.dart';

class SponsorDashboardPage extends StatefulWidget {
  const SponsorDashboardPage({super.key});

  @override
  State<SponsorDashboardPage> createState() => _SponsorDashboardPageState();
}

class _SponsorDashboardPageState extends State<SponsorDashboardPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _billboards = [];
  List<String> _locations = ["All Locations"];
  String _selectedLocation = "All Locations";
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchBillboards();
  }

  // Fetch unique billboard locations from Supabase
  Future<void> _fetchLocations() async {
    try {
      final data = await _supabase.from('billboards').select('location');

      final fetchedLocations =
          data
              .map<String>((row) => row['location'].toString())
              .toSet()
              .toList();

      setState(() {
        _locations = ["All Locations", ...fetchedLocations];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching locations: $e')));
    }
  }

  // Fetch billboards from Supabase
  Future<void> _fetchBillboards() async {
    setState(() => _isLoading = true);

    try {
      var query = _supabase
          .from('billboards')
          .select(
            'id, owner_id, location, size, manual_price, ai_predicted_price, availability, owner_name',
          )
          .eq('availability', true); // Only show available billboards

      if (_selectedLocation != "All Locations") {
        query = query.eq('location', _selectedLocation);
      }

      final data = await query;

      setState(() {
        _billboards = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching billboards: $e')));
    }
  }

  // Build the billboard list with a dropdown filter
  Widget _buildBillboardList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedLocation,
            items:
                _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value!;
                _fetchBillboards();
              });
            },
            decoration: const InputDecoration(
              labelText: "Select Location",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _billboards.isEmpty
                  ? const Center(child: Text('No billboards available.'))
                  : ListView.builder(
                    itemCount: _billboards.length,
                    itemBuilder: (context, index) {
                      final billboard = _billboards[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
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
                              Text('🏢 Owner: ${billboard['owner_name']}'),
                              Text('📏 Size: ${billboard['size']} sq ft'),
                              Text(
                                '💰 Manual Price: \$${billboard['manual_price']}',
                              ),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              // Navigate to billboard details or bidding page
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // Handle bottom navigation bar item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define different pages for navigation
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildBillboardList();
      case 1:
        return const Center(child: Text('Add Page'));
      case 2:
        return const Center(child: Text('Bids Page'));
      case 3:
        return const SponsorAnalyticsPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildBillboardList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sponsor Dashboard')),
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
