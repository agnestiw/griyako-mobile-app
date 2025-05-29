import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/history_item.dart';
import '../widgets/bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 1;
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> _allHistory = [
    {'location': 'Surabaya Barat', 'description': 'Apartment Benson'},
    {'location': 'Gubeng Airlangga', 'description': 'Kos-kosan Bu Indri'},
    {'location': 'Jl. Demak Baru', 'description': 'Kontrakan Bu Lastri'},
    {'location': 'Manukan Tama Gang 10', 'description': 'Rumah Second'},
    {'location': 'Gadel Jaya', 'description': 'Rumah Baru'},
    {'location': 'Pakal, Benowo, Surabaya', 'description': 'Ruko'},
  ];

  List<Map<String, String>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _filteredHistory = List.from(_allHistory);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        _filteredHistory = _allHistory.where((item) {
          return item['location']!.toLowerCase().contains(query) ||
              item['description']!.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.secondary, size: 24),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'What are you looking for?',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.secondary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search location or property',
                          hintStyle:
                              TextStyle(color: AppColors.grey, fontSize: 16),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                            color: AppColors.secondary, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'History',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredHistory.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = _filteredHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(item['location']!,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(item['description']!),
                            onTap: () {
                              // Optional: handle tap on item
                            },
                          );
                        },
                      )
                    : const Center(child: Text('No results found')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
