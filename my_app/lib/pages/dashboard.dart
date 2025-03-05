import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String ownerName = "";

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('users')
              .select('username')
              .eq('id', user.id)
              .single();
      setState(() {
        ownerName = response['username'];
      });
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $ownerName'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Column(children: [TabBarViewWidget()]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_billboard'),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class TabBarViewWidget extends StatefulWidget {
  @override
  _TabBarViewWidgetState createState() => _TabBarViewWidgetState();
}

class _TabBarViewWidgetState extends State<TabBarViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [Tab(text: "My Billboards"), Tab(text: "Bids Received")],
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.green,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [MyBillboardsTab(), BidsReceivedTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class MyBillboardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('List of Billboards Here'));
  }
}

class BidsReceivedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('List of Bids Here'));
  }
}
