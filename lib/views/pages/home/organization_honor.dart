import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/organization_model.dart';
import 'package:mobile/services/organization_service.dart';
import 'package:mobile/views/pages/home/organization_card.dart';

class OrganizationHonor extends StatefulWidget {
  const OrganizationHonor({super.key});

  @override
  State<OrganizationHonor> createState() => _OrganizationHonorState();
}

class _OrganizationHonorState extends State<OrganizationHonor> {
  final OrganizationService _service = OrganizationService();
  final Color primaryColor = const Color(0xFF008080);

  List<OrganizationModel> _organizations = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  String _searchQuery = '';
  String _selectedStatus = 'ACTIVE'; // Mặc định chỉ hiển thị ACTIVE
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _organizations = [];
        _hasMore = true;
        _isLoading = true;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.getOrganizations(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _selectedStatus,
        page: _currentPage,
        limit: _limit,
      );

      if (response != null) {
        final newOrganizations = response.items;

        setState(() {
          if (refresh) {
            _organizations = newOrganizations;
          } else {
            _organizations.addAll(newOrganizations);
          }
          _hasMore = newOrganizations.length >= _limit;
          _currentPage++;
          _isLoading = false;
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
    _loadOrganizations(refresh: true);
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
          'Vinh danh Tổ Chức Xã Hội',
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
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tổ chức...',
                    hintStyle: GoogleFonts.roboto(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF008080),
                    ),
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
                const SizedBox(height: 12),
                // Filter chips
                Row(
                  children: [
                    _buildFilterChip('ACTIVE', 'Hoạt động'),
                    const SizedBox(width: 8),
                    _buildFilterChip('PENDING', 'Chờ duyệt'),
                    const SizedBox(width: 8),
                    _buildFilterChip('REJECTED', 'Từ chối'),
                  ],
                ),
              ],
            ),
          ),

          // Info banner
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
                    Icons.business,
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
                        'Tổng số tổ chức',
                        style: GoogleFonts.roboto(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_organizations.length}',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Organizations list
          Expanded(
            child: _isLoading && _organizations.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _organizations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tổ chức',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadOrganizations(refresh: true),
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _organizations.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _organizations.length) {
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
                                _loadOrganizations();
                              }
                            });
                            return const SizedBox.shrink();
                          }
                        }

                        final organization = _organizations[index];

                        return buildOrganizationHonorCard(organization);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _loadOrganizations(refresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
