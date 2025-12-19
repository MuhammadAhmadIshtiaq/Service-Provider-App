// lib/features/services/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0f172a),
            Color(0xFF1e293b),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF06b6d4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF06b6d4).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06b6d4).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF06b6d4).withOpacity(0.1),
            highlightColor: const Color(0xFF06b6d4).withOpacity(0.05),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Image with glow
                  _buildServiceImage(isCompact),
                  SizedBox(width: isCompact ? 12 : 16),
                  
                  // Service Details
                  Expanded(
                    child: _buildServiceDetails(context, isCompact),
                  ),
                  
                  // Actions Menu
                  _buildActionsMenu(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(bool isCompact) {
    final imageSize = isCompact ? 80.0 : 100.0;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: service.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: service.imageUrl!,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06b6d4).withOpacity(0.2),
                            const Color(0xFF0891b2).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06b6d4).withOpacity(0.2),
                            const Color(0xFF0891b2).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.broken_image,
                        color: Color(0xFF06b6d4),
                        size: 32,
                      ),
                    ),
                  )
                : Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF06b6d4).withOpacity(0.2),
                          const Color(0xFF0891b2).withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Color(0xFF06b6d4),
                      size: 40,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetails(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title and Status
        Row(
          children: [
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFF67e8f9),
                  ],
                ).createShader(bounds),
                child: Text(
                  service.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 16 : 18,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (!service.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Inactive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF06b6d4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            service.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF06b6d4),
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 11 : 12,
                ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Description
        if (service.description != null && service.description!.isNotEmpty) ...[
          Text(
            service.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isCompact ? 13 : 14,
                  height: 1.4,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
        ],
        
        // Price and Duration
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildInfoChip(
              icon: Icons.attach_money,
              text: Formatters.currency(service.price),
              color: const Color(0xFF10b981),
              isCompact: isCompact,
            ),
            _buildInfoChip(
              icon: Icons.access_time,
              text: Formatters.duration(service.durationMinutes),
              color: const Color(0xFF06b6d4),
              isCompact: isCompact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required bool isCompact,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isCompact ? 14 : 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: Color(0xFF06b6d4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        color: const Color(0xFF1e293b),
        elevation: 8,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit?.call();
              break;
            case 'toggle':
              onToggleActive?.call();
              break;
            case 'delete':
              onDelete?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          _buildPopupMenuItem(
            value: 'edit',
            icon: Icons.edit_outlined,
            text: 'Edit',
            color: const Color(0xFF06b6d4),
          ),
          _buildPopupMenuItem(
            value: 'toggle',
            icon: service.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            text: service.isActive ? 'Deactivate' : 'Activate',
            color: const Color(0xFF06b6d4),
          ),
          _buildPopupMenuItem(
            value: 'delete',
            icon: Icons.delete_outline,
            text: 'Delete',
            color: const Color(0xFFef4444),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

