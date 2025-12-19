// lib/features/services/services_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'services_provider.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0f172a).withOpacity(0.9),
                const Color(0xFF1e293b).withOpacity(0.9),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF06b6d4).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF67e8f9)],
          ).createShader(bounds),
          child: const Text(
            'My Services',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF06b6d4).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06b6d4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF06b6d4)),
              onPressed: () => context.push('/services/add'),
              tooltip: 'Add Service',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
          ),
        ),
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return _buildEmptyState(context, size);
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                16,
                16,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(context, ref, service, size);
              },
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Size size) {
    final maxWidth = size.width > 600 ? 500.0 : size.width * 0.9;
    
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: EdgeInsets.all(size.width > 600 ? 32 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFF06b6d4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06b6d4).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF06b6d4).withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06b6d4).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: size.width > 600 ? 64 : 56,
                      color: const Color(0xFF06b6d4),
                    ),
                  ),
                  SizedBox(height: size.width > 600 ? 24 : 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF67e8f9)],
                    ).createShader(bounds),
                    child: Text(
                      'No Services Yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your first service to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/services/add'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF06b6d4).withOpacity(0.8),
                              const Color(0xFF0891b2).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06b6d4).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Add Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    WidgetRef ref,
    dynamic service,
    Size size,
  ) {
    final isCompact = size.width < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
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
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF06b6d4).withOpacity(0.1),
            highlightColor: const Color(0xFF06b6d4).withOpacity(0.05),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceImage(service, isCompact),
                  SizedBox(width: isCompact ? 12 : 16),
                  Expanded(
                    child: _buildServiceInfo(context, service, isCompact),
                  ),
                  _buildActionMenu(context, ref, service),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(dynamic service, bool isCompact) {
    final imageSize = isCompact ? 70.0 : 80.0;
    
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
                          colors: [
                            const Color(0xFF06b6d4).withOpacity(0.2),
                            const Color(0xFF0891b2).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.broken_image, color: Color(0xFF06b6d4)),
                    ),
                  )
                : Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF06b6d4).withOpacity(0.2),
                          const Color(0xFF0891b2).withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.image, color: Color(0xFF06b6d4)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context, dynamic service, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF67e8f9)],
          ).createShader(bounds),
          child: Text(
            service.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 15 : 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
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
            style: TextStyle(
              color: const Color(0xFF06b6d4),
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 11 : 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, WidgetRef ref, dynamic service) {
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
        icon: const Icon(Icons.more_vert, color: Color(0xFF06b6d4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        color: const Color(0xFF1e293b),
        elevation: 8,
        itemBuilder: (context) => [
          _buildMenuItem('edit', Icons.edit_outlined, 'Edit', const Color(0xFF06b6d4)),
          _buildMenuItem('delete', Icons.delete_outline, 'Delete', const Color(0xFFef4444)),
        ],
        onSelected: (value) async {
          final controller = ref.read(servicesControllerProvider.notifier);
          switch (value) {
            case 'edit':
              context.push('/services/edit/${service.id}');
              break;
            case 'delete':
              final confirm = await _showDeleteDialog(context);
              if (confirm == true) {
                await controller.deleteService(service.id);
              }
              break;
          }
        },
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color,
  ) {
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
              child: Icon(icon, size: 18, color: color),
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

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        title: const Text(
          'Delete Service',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this service?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF06b6d4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFef4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFef4444).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFef4444),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

