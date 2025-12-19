import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/services_provider.dart';
import '../chat/chat_provider.dart';
import '../notifications/widgets/notification_badge.dart';
import '../../core/config/app_constants.dart';
import '../../core/utils/formatters.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return '☀️ Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return '🌤️ Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return '🌆 Good Evening';
    } else {
      return '🌙 Good Night';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient (Floating)
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[400]!,
                    Colors.cyan[400]!,
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification Badge at Top
                        Align(
                          alignment: Alignment.topRight,
                          child: NotificationBadge(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_rounded,
                                    color: Colors.white),
                                onPressed: () => context.push('/notifications'),
                              ),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Greeting Text
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Find Services Text
                        const Text(
                          'Find Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Modern Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.blue[600], size: 24),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[600]!, Colors.cyan[400]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: Colors.white, size: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(servicesProvider.notifier).setSearchQuery(value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Categories with Modern Chips
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: AppConstants.serviceCategories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.serviceCategories[index];
                      final isSelected = servicesState.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              ref.read(servicesProvider.notifier).setCategory(
                                    selected ? category : null,
                                  );
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue[600],
                            checkmarkColor: Colors.white,
                            elevation: isSelected ? 4 : 1,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue[600]!
                                    : Colors.grey[200]!,
                                width: isSelected ? 0 : 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Services Grid
          servicesState.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : servicesState.services.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No services found')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = servicesState.services[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () => context.push(
                                    '/service-details/${service.id}',
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image with Gradient Overlay
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: service.imageUrl ??
                                                    AppConstants.defaultServiceImageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) =>
                                                    Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.error_outline),
                                                ),
                                              ),
                                            ),
                                            // Gradient Overlay
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.05),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Content
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue[600]!.withOpacity(0.1),
                                                    Colors.cyan[400]!.withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                Formatters.formatCurrency(service.price),
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (service.provider != null) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber[50],
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star_rounded,
                                                          size: 14,
                                                          color: Colors.amber,
                                                        ),
                                                        const SizedBox(width: 3),
                                                        Text(
                                                          service.provider!.rating
                                                              .toStringAsFixed(1),
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 34,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      await ref
                                                          .read(chatProvider.notifier)
                                                          .getOrCreateConversation(
                                                              service.provider!.id);
                                                      context.push(
                                                          '/chat/${service.provider!.id}');
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(e.toString()),
                                                          backgroundColor: Colors.red,
                                                          behavior:
                                                              SnackBarBehavior.floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    foregroundColor: Colors.blue[700],
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      side: BorderSide(
                                                        color: Colors.blue[100]!,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.chat_bubble_rounded,
                                                          size: 16,
                                                          color: Colors.blue[700]),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Chat',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.blue[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: servicesState.services.length,
                        ),
                      ),
                    ),
        ],
      ),

      // Modern Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            selectedIndex: 0,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 70,
            indicatorColor: Colors.blue[50],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.push('/bookings');
                  break;
                case 2:
                  context.push('/chat');
                  break;
                case 3:
                  context.push('/profile');
                  break;
              }
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.grey[400]),
                selectedIcon: Icon(Icons.home_rounded, color: Colors.blue[700]),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined, color: Colors.grey[400]),
                selectedIcon:
                    Icon(Icons.calendar_today_rounded, color: Colors.blue[700]),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.grey[400]),
                selectedIcon:
                    Icon(Icons.chat_bubble_rounded, color: Colors.blue[700]),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: Colors.grey[400]),
                selectedIcon: Icon(Icons.person_rounded, color: Colors.blue[700]),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

