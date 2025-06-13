import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // --- State Management ---
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String _errorMessage = '';

  // Tracks the selected index for the BottomNavBar.
  int _selectedIndex = 0;

  // --- API Configuration ---
  String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/'; // For Android emulator
    }
    return 'http://127.0.0.1:8000/api/'; // For iOS, web, and desktop
  }

  // --- Lifecycle & Data Fetching ---
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  /// Fetches notifications from the Laravel backend.
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token not found. Please log in again.';
      });
      return;
    }

    final url = Uri.parse('${_baseUrl}notifications');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              'Failed to load notifications: ${errorData['message'] ?? response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'An error occurred. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Building ---
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
              const Text(
                'Notifications',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: AppColors.primary,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  /// Builds the main content area based on the current state.
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState(_errorMessage);
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final bool isRead = notification['is_read'] == true || notification['is_read'] == 1;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isRead ? Colors.transparent : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(
              isRead
                  ? Icons.notifications_none_outlined
                  : Icons.notifications_active,
              color: isRead ? Colors.grey : AppColors.primary,
              size: 30,
            ),
            title: Text(
              notification['title'] ?? 'No Title',
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            subtitle: Text(
              notification['body'] ?? 'No content available.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () {
              // Optional: Implement logic to mark notification as read on tap
              // and navigate to a detailed view if needed.
            },
          ),
        );
      },
    );
  }

  /// Builds the widget for the empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Notifications Yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary)),
          SizedBox(height: 8),
          Text('New notifications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  /// Builds the widget for displaying errors.
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Something Went Wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: _fetchNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
