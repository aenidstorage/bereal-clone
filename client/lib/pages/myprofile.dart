import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rebeal/camera/camera.dart';
import 'package:rebeal/model/post.module.dart';
import 'package:rebeal/model/user.module.dart';
import 'package:rebeal/pages/home.dart';
import 'package:rebeal/state/auth.state.dart';
import 'package:rebeal/pages/settings.dart';
import 'package:rebeal/widget/bottom_navigation.dart';
import 'package:rebeal/widget/gridpost.dart';
import 'package:rebeal/widget/gradient_background.dart';
import '../styles/color.dart';
import 'edit.dart';
import 'feed.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MyProfilePage> {
  // Generate mock posts for the user
  List<PostModel> _getMockUserPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        createdAt: now.subtract(Duration(hours: 3)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800",
        bio: "Coffee vibes ☕️",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(hours: 8)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800",
        bio: "Morning workout 💪",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(days: 1, hours: 2)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800",
        bio: "Sunset views 🌅",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(days: 2)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800",
        bio: "Weekend adventures 🎉",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(days: 3)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800",
        bio: "Good times 🎊",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(days: 4)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1496345875659-11f7dd282d1d?w=800",
        bio: "Throwback 📸",
        user: UserModel(
          userId: "user1",
          displayName: "You",
          userName: "@you",
          profilePic: "https://i.pravatar.cc/150?img=10",
        ),
      ),
    ];
  }

  void _onNavTap(int index) {
    HapticFeedback.mediumImpact();
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1: // Friends
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeedPage()),
        );
        break;
      case 2: // Camera
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraPage()),
        );
        break;
      case 3: // Chat - placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat coming soon!'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 4: // Profile - already here, do nothing
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    final mockPosts = _getMockUserPosts();
    return Scaffold(
        extendBody: true,
        bottomNavigationBar: GlassmorphicBottomNav(
          currentIndex: 4, // Profile page
          onTap: _onNavTap,
        ),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            actions: [
              FadeIn(
                  duration: Duration(milliseconds: 1000),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()));
                      },
                      child: Icon(Icons.more_horiz, color: Colors.white)))
            ],
            leading: FadeIn(
                duration: Duration(milliseconds: 1000),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white))),
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: FadeInRight(
                duration: Duration(milliseconds: 300),
                child: Text(
                  "Profile",
                  style: TextStyle(color: Colors.white),
                ))),
        body: GradientBackground(
          child: Center(
            child: FadeInDown(
              child: ListView(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()));
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              height: 120,
                              width: 120,
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: 100,
                                  imageUrl: state
                                          .profileUserModel?.profilePic ??
                                      "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg"),
                            ))),
                    Container(height: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()));
                        },
                        child: Text(
                          state.profileUserModel?.displayName.toString() ?? "",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()));
                        },
                        child: Text(
                          state.profileUserModel?.userName.toString() ?? "",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        )),
                    Container(height: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()));
                        },
                        child: Text(
                          "${state.profileUserModel?.bio ?? ""}",
                          style: TextStyle(
                              color: ReBealColor.ReBealLightGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        )),
                     Container(
                       height: 20,
                     ),
                     // Posts section header
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           "Your Posts",
                           style: TextStyle(
                               color: Colors.white,
                               fontSize: 21,
                               fontWeight: FontWeight.w700),
                         ),
                         Text(
                           "${mockPosts.length} posts",
                           style: TextStyle(
                               color: ReBealColor.ReBealLightGrey,
                               fontSize: 14,
                               fontWeight: FontWeight.w400),
                         ),
                       ],
                     ),
                     Container(
                       height: 15,
                     ),
                     // Posts grid
                     GridView.builder(
                       shrinkWrap: true,
                       physics: NeverScrollableScrollPhysics(),
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 3,
                         childAspectRatio: 0.8,
                         mainAxisSpacing: 10,
                         crossAxisSpacing: 10,
                       ),
                       itemCount: mockPosts.length,
                       itemBuilder: (context, index) {
                         return GridPostWidget(postModel: mockPosts[index]);
                       },
                     ),
                     Container(
                       height: 100, // Extra space for bottom nav
                     ),
                  ],
                ))
          ],
        ),
              ),
            ),
          ),
        );
  }
}
