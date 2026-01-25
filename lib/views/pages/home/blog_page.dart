import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/blog_model.dart';
import 'package:mobile/services/blog_service.dart';
import 'package:mobile/views/pages/home/buildCard.dart';
import 'package:mobile/views/pages/home/blog_detail_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final BlogService _service = BlogService();
  final Color primaryColor = const Color(0xFF008080);

  List<BlogModel> _blogs = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _blogs = [];
        _hasMore = true;
        _isLoading = true;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.getBlogs(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        limit: _limit,
      );

      if (response != null) {
        final newBlogs = response.items;

        setState(() {
          if (refresh) {
            _blogs = newBlogs;
          } else {
            _blogs.addAll(newBlogs);
          }
          _hasMore = newBlogs.length >= _limit;
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadBlogs(refresh: true);
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Vừa xong';
    }
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
          'Blog và Tin Tức',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
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
                hintText: 'Tìm kiếm bài viết...',
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
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Blogs list
          Expanded(
            child: _isLoading && _blogs.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : _blogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có bài viết',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadBlogs(refresh: true),
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _blogs.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _blogs.length) {
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
                                    _loadBlogs();
                                  }
                                });
                                return const SizedBox.shrink();
                              }
                            }

                            final blog = _blogs[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlogDetailPage(blogId: blog.id),
                                    ),
                                  );
                                },
                                child: buildBlogItem(
                                  imageUrl: blog.coverImage ??
                                      'https://images.unsplash.com/photo-1600818272779-cfa6145222f0?fit=crop&w=200',
                                  title: blog.title,
                                  desc: blog.content != null &&
                                          blog.content!.length > 100
                                      ? '${blog.content!.substring(0, 100)}...'
                                      : blog.content ?? 'Chưa có mô tả',
                                  time: _formatTime(blog.createdAt),
                                ),
                              ),
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
