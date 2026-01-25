import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/organization_model.dart';

// Widget card cho Organization (1 thẻ full width, avatar bên trái)
Widget buildOrganizationHonorCard(OrganizationModel organization) {
  final profile = organization.organizationProfiles;
  final name = profile?.organizationName ?? 'Chưa có tên';
  final totalCampaigns = profile?.totalCampaigns ?? 0;
  final totalVolunteers = profile?.totalVolunteers ?? 0;
  final avatarUrl = profile?.avatarUrl ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF008080),
              width: 2,
            ),
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
                        Icons.business,
                        size: 32,
                        color: Color(0xFF008080),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFE0F2F1),
                    child: const Icon(
                      Icons.business,
                      size: 32,
                      color: Color(0xFF008080),
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 16),

        // Name and Stats
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
                  const Icon(
                    Icons.campaign,
                    size: 14,
                    color: Color(0xFF008080),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCampaigns chiến dịch',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.people,
                    size: 14,
                    color: Color(0xFF008080),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalVolunteers TNV',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arrow icon
        const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 24,
        ),
      ],
    ),
  );
}
