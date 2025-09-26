import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AdminbottomBar.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/Components/UserCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<int> _animation1;
  late Animation<int> _animation2;
  late Animation<int> _animation3;

  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 3;

  List<String> _activeWorkers = [];
  List<String> _activeSellers = [];

  @override
  void initState() {
    super.initState();

    _fetchActiveWorkers();
    _fetchActiveSellers();

    _controller1 = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller2 = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller3 = AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _animation1 = IntTween(begin: 1, end: 21).animate(_controller1)..addListener(() => setState(() {}));
    _animation2 = IntTween(begin: 1, end: 40).animate(_controller2)..addListener(() => setState(() {}));
    _animation3 = IntTween(begin: 1, end: 8).animate(_controller3)..addListener(() => setState(() {}));

    _controller1.forward();
    _controller2.forward();
    _controller3.forward();
  }

  Future<void> _fetchActiveWorkers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .where('status', isEqualTo: 'Active')
          .get();

      final names = snapshot.docs.map((doc) => doc['WorkerName'].toString()).toList();

      setState(() {
        _activeWorkers = names;
      });
    } catch (e) {
      print('Error fetching active workers: $e');
    }
  }

  Future<void> _fetchActiveSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .where('status', isEqualTo: 'Active')
          .get();

      final names = snapshot.docs.map((doc) => doc['fullName'].toString()).toList();

      setState(() {
        _activeSellers = names;
      });
    } catch (e) {
      print('Error fetching active sellers: $e');
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCounterBox(int value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.mint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Counters
              Row(
                children: [
                  _buildCounterBox(_animation1.value, "Registered NGOs"),
                  _buildCounterBox(_animation2.value, "Registered Workers"),
                  _buildCounterBox(_animation3.value, "Registered Sellers"),
                ],
              ),
              const SizedBox(height: 24),

              // Dynamic User List
              UserCardScroller(
                ngos: ['Red Cross', 'UNICEF'],
                workers: _activeWorkers,
                sellers: _activeSellers,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomBar(),
    );
  }
}
