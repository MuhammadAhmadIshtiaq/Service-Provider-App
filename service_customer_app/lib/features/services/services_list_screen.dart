// ============================================
// lib/features/services/services_list_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/app_constants.dart';
import '../../core/utils/formatters.dart';
import 'services_provider.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(servicesProvider.notifier).setSearchQuery(value);
              },
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.serviceCategories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: servicesState.selectedCategory == null,
                      onSelected: (selected) {
                        ref.read(servicesProvider.notifier).setCategory(null);
                      },
                    ),
                  );
                }

                final category = AppConstants.serviceCategories[index - 1];
                final isSelected = servicesState.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(servicesProvider.notifier).setCategory(
                            selected ? category : null,
                          );
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Services List
          Expanded(
            child: servicesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : servicesState.services.isEmpty
                    ? const Center(child: Text('No services found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: servicesState.services.length,
                        itemBuilder: (context, index) {
                          final service = servicesState.services[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                context.push('/service-details/${service.id}');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Service Image
                                  CachedNetworkImage(
                                    imageUrl: service.imageUrl ??
                                        AppConstants.defaultServiceImageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),

                                  // Service Info
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                service.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Formatters.formatCurrency(
                                                service.price,
                                              ),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (service.description != null)
                                          Text(
                                            service.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            Chip(
                                              label: Text(service.category),
                                              avatar: const Icon(
                                                Icons.category,
                                                size: 16,
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                Formatters.formatDuration(
                                                  service.durationMinutes,
                                                ),
                                              ),
                                              avatar: const Icon(
                                                Icons.access_time,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (service.provider != null) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: service
                                                            .provider!
                                                            .businessLogoUrl !=
                                                        null
                                                    ? CachedNetworkImageProvider(
                                                        service.provider!
                                                            .businessLogoUrl!,
                                                      )
                                                    : null,
                                                child: service.provider!
                                                            .businessLogoUrl ==
                                                        null
                                                    ? Text(
                                                        service.provider!
                                                            .businessName[0],
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  service
                                                      .provider!.businessName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                service.provider!.rating
                                                    .toStringAsFixed(1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}