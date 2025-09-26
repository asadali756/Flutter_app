import 'package:flutter/material.dart';
import 'package:project/Components/AppColors.dart';

class AdminAppbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AdminAppbar({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Color.fromARGB(0, 151, 179, 174),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:  Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.menu, color:Colors.black),
      ),
      centerTitle: true,
      title:Text("EcoCycle.pk" , style: TextStyle(color: Colors.black),) ,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications,
                  color:Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor:
                     Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.mail_outline),
                          title: const Text('New Message from User'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.warning_amber),
                          title: const Text('System Alert Triggered'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              right: 10,
              top: 10,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        )
      ],
    );
  }
}

