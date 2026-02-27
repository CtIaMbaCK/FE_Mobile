import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/volunteer_honor_model.dart';

// Widget card cho Volunteer (1 thẻ full width, avatar bên trái)
Widget buildVolunteerHonorCard(VolunteerHonorModel volunteer, {int? rank}) {
  final profile = volunteer.volunteerProfile;
  final name = profile?.fullName ?? 'Chưa có tên';
  final points = profile?.points ?? 0;
  final avatarUrl = profile?.avatarUrl ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF008080).withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // Rank badge (nếu có)
        if (rank != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF008080), width: 2),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFE0F2F1),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF008080),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFE0F2F1),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF008080),
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 16),

        // Name and Points
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFB800)),
                  const SizedBox(width: 4),
                  Text(
                    '$points điểm',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF008080),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper function để lấy màu badge theo rank
Color _getRankColor(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFD700); // Gold
    case 2:
      return const Color(0xFFC0C0C0); // Silver
    case 3:
      return const Color(0xFFCD7F32); // Bronze
    default:
      return const Color(0xFF008080); // Primary color
  }
}
