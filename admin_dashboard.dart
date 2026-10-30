
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'All';

  // ADMIN UTAMA
  bool get _isMainAdmin =>
      widget.user.username.toLowerCase() == 'admin1';

  List<ItemModel> get _filteredItems {
    if (_selectedFilter == 'All') {
      return globalItemList;
    }

    if (_selectedFilter == 'Approve') {
      return [];
    }

    return globalItemList
        .where((item) => item.status == _selectedFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFEF4444);
      case 'Proses':
        return const Color(0xFFF59E0B);
      case 'Selesai':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  // LOGOUT
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // UBAH STATUS ITEM + SIMPAN
  Future<void> _changeStatus(ItemModel item) async {
    String selectedStatus = item.status;

    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  _buildStatusOption(
                    'Pending',
                    selectedStatus,
                    (value) {
                      setModalState(() => selectedStatus = value);
                    },
                  ),
                  _buildStatusOption(
                    'Proses',
                    selectedStatus,
                    (value) {
                      setModalState(() => selectedStatus = value);
                    },
                  ),
                  _buildStatusOption(
                    'Selesai',
                    selectedStatus,
                    (value) {
                      setModalState(() => selectedStatus = value);
                    },
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final oldStatus = item.status;

                        Navigator.pop(sheetContext);

                        setState(() {
                          item.status = selectedStatus;
                        });

                        try {
                          await LocalStorage.saveData();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status berhasil diperbarui'),
                            ),
                          );
                        } catch (e) {
                          item.status = oldStatus;

                          if (!mounted) return;

                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal menyimpan status: $e',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan Status'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // PILIHAN STATUS
  Widget _buildStatusOption(
    String status,
    String selectedStatus,
    Function(String) onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(status),
      value: status,
      groupValue: selectedStatus,
      activeColor: _getStatusColor(status),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // HAPUS ITEM + SIMPAN
  void _deleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Item?'),
          content: Text(
            'Yakin ingin menghapus "${item.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final index = globalItemList.indexOf(item);

                if (index == -1) return;

                globalItemList.removeAt(index);

                Navigator.pop(dialogContext);

                setState(() {});

                try {
                  await LocalStorage.saveData();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item berhasil dihapus'),
                    ),
                  );
                } catch (e) {
                  globalItemList.insert(index, item);

                  if (!mounted) return;

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus item: $e'),
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // TERIMA AKUN + SIMPAN
  Future<void> _approveUser(UserAccount user) async {
    if (!_isMainAdmin) return;

    final oldStatus = user.status;

    setState(() {
      user.status = 'Active';
    });

    try {
      await LocalStorage.saveData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akun ${user.username} berhasil diterima.',
          ),
        ),
      );
    } catch (e) {
      user.status = oldStatus;

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan persetujuan: $e'),
        ),
      );
    }
  }

  // TOLAK AKUN + SIMPAN
  Future<void> _rejectUser(UserAccount user) async {
    if (!_isMainAdmin) return;

    final oldStatus = user.status;

    setState(() {
      user.status = 'Rejected';
    });

    try {
      await LocalStorage.saveData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun ${user.username} ditolak.'),
        ),
      );
    } catch (e) {
      user.status = oldStatus;

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan penolakan: $e'),
        ),
      );
    }
  }

  // PERSETUJUAN AKUN
  Widget _buildAccountApproval() {
    if (!_isMainAdmin) {
      return const SizedBox.shrink();
    }

    final pendingUsers = registeredUsers
        .where((user) => user.status == 'Pending')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Persetujuan Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (pendingUsers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 45,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Tidak ada pendaftaran akun yang perlu disetujui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

        ...pendingUsers.map((user) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: ${user.role}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectUser(user),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveUser(user),
                        child: const Text('Terima'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // KARTU METRIK
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LEGENDA KATEGORI
  Widget _buildLegendDot(
    String title,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title)),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = globalItemList
        .where((item) => item.status == 'Pending')
        .length;

    final processCount = globalItemList
        .where((item) => item.status == 'Proses')
        .length;

    final completedCount = globalItemList
        .where((item) => item.status == 'Selesai')
        .length;

    final taskCount = globalItemList
        .where((item) => item.category == 'Task')
        .length;

    final inventoryCount = globalItemList
        .where((item) => item.category == 'Inventaris')
        .length;

    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BANNER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9A3412),
                  Color(0xFFC2410C),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kelola data Task & Inventory.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // METRIK
          Row(
            children: [
              _buildMetricCard(
                'Need Action',
                '$pendingCount',
                Icons.pending_actions,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'In Progress',
                '$processCount',
                Icons.sync,
                const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildMetricCard(
                'Completed',
                '$completedCount',
                Icons.check_circle,
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Total Data',
                '${globalItemList.length}',
                Icons.storage,
                const Color(0xFF0284C7),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DISTRIBUSI KATEGORI
          const Text(
            'Distribusi Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildLegendDot(
                  'Task',
                  taskCount,
                  const Color(0xFF0284C7),
                ),
                const SizedBox(height: 14),
                _buildLegendDot(
                  'Inventaris',
                  inventoryCount,
                  const Color(0xFFD97706),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // FILTER
          const Text(
            'Filter Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Proses'),
                _buildFilterChip('Selesai'),
                if (_isMainAdmin) _buildFilterChip('Approve'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // DATA SISTEM
          const Text(
            'Data Sistem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (_selectedFilter == 'Approve' && _isMainAdmin)
            _buildAccountApproval(),

          if (filteredItems.isEmpty &&
              _selectedFilter != 'Approve')
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    'Tidak ada data.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          ...filteredItems.map((item) {
            final statusColor = _getStatusColor(item.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: Icon(
                    item.category == 'Task'
                        ? Icons.task_alt
                        : Icons.inventory_2_outlined,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${item.category} • ${item.createdBy}',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ubah Status',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _changeStatus(item),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteItem(item),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // FILTER CHIP
  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }
}
