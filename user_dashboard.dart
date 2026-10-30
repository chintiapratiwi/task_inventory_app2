import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const UserDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState
    extends State<UserDashboardScreen> {
  String _selectedFilter = 'All';

  List<ItemModel> get _filteredItems {
    if (_selectedFilter == 'All') {
      return globalItemList;
    }

    return globalItemList
        .where(
          (item) =>
              item.category ==
              _selectedFilter,
        )
        .toList();
  }

  int get _totalTask {
    return globalItemList
        .where(
          (item) =>
              item.category == 'Task',
        )
        .length;
  }

  int get _totalInventory {
    return globalItemList
        .where(
          (item) =>
              item.category ==
              'Inventaris',
        )
        .length;
  }

  int get _totalPending {
    return globalItemList
        .where(
          (item) =>
              item.status == 'Pending',
        )
        .length;
  }

  Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Pending':
        return const Color(
          0xFFEF4444,
        );

      case 'Proses':
        return const Color(
          0xFFF59E0B,
        );

      case 'Selesai':
        return const Color(
          0xFF10B981,
        );

      default:
        return Colors.grey;
    }
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.05),
              blurRadius: 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color: Colors.teal,
              size: 28,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(
    String title,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,

          decoration:
              BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(title),
        ),

        Text(
          '$value',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),

      (route) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final filteredItems =
        _filteredItems;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAFC),

      appBar: AppBar(
        title: const Text(
          'User Workspace',
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: 'Logout',

            onPressed: _logout,

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          // =========================
          // BANNER
          // =========================

          Container(
            padding:
                const EdgeInsets.all(20),

            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF00BFA6),
                  Color(0xFF00897B),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Selamat Datang 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.user.username,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Kelola Task & Inventory kamu di sini.',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // SUMMARY
          // =========================

          Row(
            children: [
              _buildSummaryCard(
                'Total Item',
                '${globalItemList.length}',
                Icons.inventory_2_outlined,
              ),

              const SizedBox(width: 12),

              _buildSummaryCard(
                'Total Task',
                '$_totalTask',
                Icons.task_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildSummaryCard(
                'Inventaris',
                '$_totalInventory',
                Icons.inventory_outlined,
              ),

              const SizedBox(width: 12),

              _buildSummaryCard(
                'Pending',
                '$_totalPending',
                Icons.pending_actions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =========================
          // STATUS
          // =========================

          const Text(
            'Status Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.all(18),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Column(
              children: [
                _buildChartLegend(
                  'Pending',

                  globalItemList
                      .where(
                        (item) =>
                            item.status ==
                            'Pending',
                      )
                      .length,

                  const Color(
                    0xFFEF4444,
                  ),
                ),

                const SizedBox(height: 12),

                _buildChartLegend(
                  'Proses',

                  globalItemList
                      .where(
                        (item) =>
                            item.status ==
                            'Proses',
                      )
                      .length,

                  const Color(
                    0xFFF59E0B,
                  ),
                ),

                const SizedBox(height: 12),

                _buildChartLegend(
                  'Selesai',

                  globalItemList
                      .where(
                        (item) =>
                            item.status ==
                            'Selesai',
                      )
                      .length,

                  const Color(
                    0xFF10B981,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // FILTER
          // =========================

          const Text(
            'Filter Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Task'),
                _buildFilterChip(
                  'Inventaris',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // DAFTAR ITEM
          // =========================

          const Text(
            'Daftar Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (filteredItems.isEmpty)
            Container(
              padding:
                  const EdgeInsets.all(30),

              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Belum ada data.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          ...filteredItems.map(
            (item) {
              final statusColor =
                  _getStatusColor(
                item.status,
              );

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(14),

                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.teal
                            .withOpacity(0.1),

                    child: Icon(
                      item.category ==
                              'Task'
                          ? Icons.task_alt
                          : Icons
                              .inventory_2_outlined,

                      color: Colors.teal,
                    ),
                  ),

                  title: Text(
                    item.title,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 6,
                    ),

                    child: Text(
                      '${item.category} • Dibuat oleh ${item.createdBy}',
                    ),
                  ),

                  trailing: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withOpacity(0.1),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      item.status,

                      style: TextStyle(
                        color:
                            statusColor,

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // =========================
      // TAMBAH ENTRY
      // =========================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          AddItemScreen(
        user: widget.user,
      ),
    ),
  );

  if (result == true) {
    setState(() {});
  }
},

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'Tambah Entry',
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String filter,
  ) {
    final isSelected =
        _selectedFilter == filter;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: ChoiceChip(
        label: Text(filter),

        selected: isSelected,

        onSelected: (selected) {
          setState(() {
            _selectedFilter =
                filter;
          });
        },
      ),
    );
  }
}