import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/volunteer_honor_model.dart';
import 'package:mobile/services/volunteer_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/pages/home/volunteer_card.dart';

class VolunteerHonor extends StatefulWidget {
  const VolunteerHonor({super.key});

  @override
  State<VolunteerHonor> createState() => _VolunteerHonorState();
}

class _VolunteerHonorState extends State<VolunteerHonor> {
  final VolunteerService _service = VolunteerService();
  final Color primaryColor = const Color(0xFF008080);

  List<VolunteerHonorModel> _volunteers = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Thông tin user hiện tại để highlight
  String? _currentUserId;
  int? _myRank;
  int? _myPoints;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadVolunteers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    final user = AuthService.currentUser;
    _currentUserId = user?.id;
    _myPoints = user?.profile.points;
  }

  Future<void> _loadVolunteers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _volunteers = [];
        _hasMore = true;
        _isLoading = true;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.getVolunteers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        limit: _limit,
      );

      if (response != null) {
        final newVolunteers = response.items;

        // Sắp xếp theo điểm giảm dần
        newVolunteers.sort((a, b) {
          final pointsA = a.volunteerProfile?.points ?? 0;
          final pointsB = b.volunteerProfile?.points ?? 0;
          return pointsB.compareTo(pointsA);
        });

        setState(() {
          if (refresh) {
            _volunteers = newVolunteers;
          } else {
            _volunteers.addAll(newVolunteers);
          }
          _hasMore = newVolunteers.length >= _limit;
          _currentPage++;
          _isLoading = false;

          // Tìm rank của mình
          if (_currentUserId != null) {
            final myIndex = _volunteers.indexWhere(
              (v) => v.id == _currentUserId,
            );
            if (myIndex != -1) {
              _myRank = myIndex + 1;
            }
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadVolunteers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vinh danh Tình Nguyện Viên',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tình nguyện viên...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF008080)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // My stats card (nếu là volunteer)
          if (_currentUserId != null && _myPoints != null && _myRank != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF008080), Color(0xFF00A0A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF008080).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hạng của bạn',
                          style: GoogleFonts.roboto(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '#$_myRank',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$_myPoints điểm',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Volunteers list
          Expanded(
            child: _isLoading && _volunteers.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _volunteers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tình nguyện viên',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadVolunteers(refresh: true),
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _volunteers.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _volunteers.length) {
                          // Load more indicator
                          if (_isLoading) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                            );
                          } else {
                            // Trigger load more
                            Future.delayed(Duration.zero, () {
                              if (_hasMore && !_isLoading) {
                                _loadVolunteers();
                              }
                            });
                            return const SizedBox.shrink();
                          }
                        }

                        final volunteer = _volunteers[index];
                        final isCurrentUser = volunteer.id == _currentUserId;
                        final rank = index + 1;

                        return Container(
                          decoration: isCurrentUser
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: buildVolunteerHonorCard(volunteer, rank: rank),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
