import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryCards extends StatelessWidget {
  const StoryCards({super.key});

  final List<_StoryItem> stories = const [
    _StoryItem("assets/images/1.jpg", "Sell Waste", LucideIcons.recycle, '/SellWaste'),
    _StoryItem("assets/images/2.jpg", "Competition", LucideIcons.award, '/AddCompetition'),
    _StoryItem("assets/images/3.jpg", "EcoStore", LucideIcons.shoppingBag, '/EcoStore'),
    _StoryItem("assets/images/4.jpg", "Social Scroll", LucideIcons.users, '/Social'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200, // extra height to allow icon + label
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: stories.length,
          separatorBuilder: (context, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final story = stories[index];
            return _StoryCard(story: story);
          },
        ),
      ),
    );
  }
}

class _StoryItem {
  final String imagePath;
  final String label;
  final IconData icon;
  final String route;

  const _StoryItem(this.imagePath, this.label, this.icon, this.route);
}

class _StoryCard extends StatelessWidget {
  final _StoryItem story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: AssetImage(story.imagePath),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -20, // half out of box
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, story.route);
                },
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color.fromARGB(255, 189, 189, 189),
                  child: Icon(
                    story.icon,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28), // give space for the icon
        Text(
          story.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}