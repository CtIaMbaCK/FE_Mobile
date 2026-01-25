import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/blog_model.dart';
import 'package:mobile/services/blog_service.dart';

class BlogDetailPage extends StatefulWidget {
  final String blogId;

  const BlogDetailPage({
    super.key,
    required this.blogId,
  });

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final BlogService _service = BlogService();
  final Color primaryColor = const Color(0xFF008080);

  BlogModel? _blog;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlogDetail();
  }

  Future<void> _loadBlogDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final blog = await _service.getBlogDetail(widget.blogId);
      if (blog != null) {
        setState(() {
          _blog = blog;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không tìm thấy bài viết';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải bài viết: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} lúc ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết bài viết',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBlogDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Image
                      if (_blog!.coverImage != null)
                        CachedNetworkImage(
                          imageUrl: _blog!.coverImage!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              _blog!.title,
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Meta info (Organization & Date)
                            Row(
                              children: [
                                // Organization Avatar & Name
                                if (_blog!.organization != null) ...[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _blog!.organization!.avatarUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: _blog!.organization!.avatarUrl!,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.business,
                                                  size: 20,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.business,
                                                size: 20,
                                                color: primaryColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _blog!.organization!.organizationName ??
                                              'Tổ chức',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatTime(_blog!.createdAt),
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 24),

                            // Content
                            Text(
                              _blog!.content ?? 'Không có nội dung',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Updated time (if available)
                            if (_blog!.updatedAt != null &&
                                _blog!.updatedAt != _blog!.createdAt)
                              Text(
                                'Cập nhật lần cuối: ${_formatTime(_blog!.updatedAt!)}',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
