import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Components/AppColors.dart';

class UserCardScroller extends StatelessWidget {
  final List<String> ngos;
  final List<String> workers;
  final List<String> sellers;

  const UserCardScroller({
    super.key,
    required this.ngos,
    required this.workers,
    required this.sellers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NGOBox(users: ngos),
        const SizedBox(height: 12),
        WorkerBox(users: workers),
        const SizedBox(height: 12),
        SellerBox(users: sellers),
      ],
    );
  }
}

// ✅ NGO Box
class NGOBox extends StatelessWidget {
  final List<String> users;
  const NGOBox({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return _buildBox(
      context,
      "NGOs",
      users,
      LucideIcons.warehouse,
      onRegister: () {
        Navigator.pushNamed(context, '/registerNGO');
      },
      onView: (user) {
        Navigator.pushNamed(context, '/viewNGO', arguments: user);
      },
      onViewAll: () {
        Navigator.pushNamed(context, '/viewAllNGOs');
      },
    );
  }
}

// ✅ Worker Box
class WorkerBox extends StatelessWidget {
  final List<String> users;
  const WorkerBox({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return _buildBox(
      context,
      "Workers",
      users,
      LucideIcons.hardHat,
      onRegister: () {
        Navigator.pushNamed(context, '/workers');
      },
      onView: (user) {
        Navigator.pushNamed(context, '/viewWorker', arguments: user);
      },
      onViewAll: () {
        Navigator.pushNamed(context, '/ShowWorkers');
      },
    );
  }
}

// ✅ Seller Box
class SellerBox extends StatelessWidget {
  final List<String> users;
  const SellerBox({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return _buildBox(
      context,
      "Sellers",
      users,
      LucideIcons.store,
      onRegister: () {
        Navigator.pushNamed(context, '/addseller');
      },
      onView: (user) {
        Navigator.pushNamed(context, '/viewSeller', arguments: user);
      },
      onViewAll: () {
        Navigator.pushNamed(context, '/ShowSeller');
      },
    );
  }
}

// ✅ Shared Box Builder
Widget _buildBox(
  BuildContext context,
  String title,
  List<String> users,
  IconData icon, {
  required VoidCallback onRegister,
  required Function(String user) onView,
  required VoidCallback onViewAll,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.softWhite, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.softWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.paleGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Register New", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onViewAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View All", style: TextStyle(color: AppColors.paleGreen)),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// User List
        ...users.map((user) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.softWhite,
                    child: Icon(Icons.person, color: AppColors.paleGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$user is active",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onView(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.peach,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("View", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )),
      ],
    ),
  );
}
