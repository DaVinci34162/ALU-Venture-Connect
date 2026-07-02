import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/pages/opportunity_detail_page.dart';
import '../bloc/opportunity_bloc.dart';
import '../bloc/opportunity_event.dart';
import '../bloc/opportunity_state.dart';

const List<Map<String, dynamic>> _categories = [
  {'label': 'All', 'icon': Icons.apps},
  {'label': 'Engineering', 'icon': Icons.code},
  {'label': 'Design', 'icon': Icons.design_services},
  {'label': 'Marketing', 'icon': Icons.campaign},
  {'label': 'Data', 'icon': Icons.bar_chart},
  {'label': 'Operations', 'icon': Icons.settings},
  {'label': 'Research', 'icon': Icons.science},
];

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OpportunityBloc>()
        ..add(const WatchOpportunitiesStarted()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Explore'),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Search bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search opportunities...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (query) {
                    context
                        .read<OpportunityBloc>()
                        .add(OpportunitySearchChanged(query));
                  },
                ),
              ),
              // Category chips
              Container(
                color: AppColors.surface,
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected =
                        _selectedCategory == cat['label'];
                    return GestureDetector(
                      onTap: () {
                        setState(
                                () => _selectedCategory = cat['label']);
                        context.read<OpportunityBloc>().add(
                            OpportunitySearchChanged(
                                cat['label'] == 'All'
                                    ? ''
                                    : cat['label']));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Results
              Expanded(
                child: BlocBuilder<OpportunityBloc, OpportunityState>(
                  builder: (context, state) {
                    if (state.isLoadingFeed &&
                        state.opportunities.isEmpty) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final results = state.filteredOpportunities;
                    if (results.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64,
                                color: AppColors.textHint
                                    .withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No opportunities found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final opp = results[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OpportunityDetailPage(opportunity: opp),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.primaryGradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.work_outline,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opp.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opp.startupName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        children: opp.tags
                                            .take(2)
                                            .map((tag) => Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration:
                                          BoxDecoration(
                                            color: AppColors
                                                .primary
                                                .withValues(
                                                alpha: 0.1),
                                            borderRadius:
                                            BorderRadius
                                                .circular(6),
                                          ),
                                          child: Text(
                                            tag,
                                            style:
                                            const TextStyle(
                                              fontSize: 10,
                                              color:
                                              AppColors.primary,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textHint),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}