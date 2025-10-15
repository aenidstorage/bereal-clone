import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rebeal/camera/camera.dart';
import 'package:rebeal/model/post.module.dart';
import 'package:rebeal/model/user.module.dart';
import 'package:rebeal/state/auth.state.dart';
import 'package:rebeal/state/post.state.dart';
import 'package:rebeal/state/search.state.dart';
import 'package:rebeal/pages/myprofile.dart';
import 'package:rebeal/widget/feedpost.dart';
import 'package:rebeal/widget/gridpost.dart';
import 'package:rebeal/widget/bottom_navigation.dart';
import 'feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();
  bool _isGrid = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    var authState = Provider.of<AuthState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.getCurrentUser();
      initPosts();
      initSearch();
      initProfile();
    });
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initPosts() {
    var state = Provider.of<PostState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void _scrollListener() {
    // Can be used for scroll-based UI updates if needed
  }

  Future _bodyView() async {
    if (_isGrid) {
      setState(() {
        _isGrid = false;
      });
    } else {
      setState(() {
        _isGrid = true;
      });
    }
  }

  void _onNavTap(int index) {
    HapticFeedback.mediumImpact();
    switch (index) {
      case 0: // Home - already here, do nothing
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
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);

    return Scaffold(
        extendBody: true,
        bottomNavigationBar: GlassmorphicBottomNav(
          currentIndex: _currentNavIndex,
          onTap: _onNavTap,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: Container(), // Empty - no longer need friends icon
          toolbarHeight: 37,
          flexibleSpace: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10, top: 59),
                child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyProfilePage()));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                            height: 30,
                            width: 30,
                            child: CachedNetworkImage(
                                imageUrl: authState
                                        .profileUserModel?.profilePic ??
                                    "https://i.pinimg.com/originals/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg")))),
              )
                  ],
                ),
          elevation: 0,
          title: Image.asset(
            "assets/logo/logo.png",
            height: 100,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: FadeIn(
            child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 500),
                child: _isGrid
                    ? Consumer<PostState>(
                                builder: (context, state, child) {
                              final now = DateTime.now();
                              final List<PostModel>? list = state
                                  .getPostLists(authState.userModel)!
                                  .where((x) =>
                                      now
                                          .difference(
                                              DateTime.parse(x.createdAt))
                                          .inHours <
                                      24)
                                  .toList();
                              while (list!.length < 10) {
                                list.add(PostModel(
                                  imageFrontPath:
                                      "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
                                  imageBackPath:
                                      "https://htmlcolorcodes.com/assets/images/colors/black-color-solid-background-1920x1080.png",
                                  createdAt: "",
                                  user: UserModel(
                                    displayName: "",
                                  ),
                                ));
                              }
                              return RefreshIndicator(
                                  color: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  onRefresh: () {
                                    HapticFeedback.mediumImpact();
                                    return _bodyView();
                                  },
                                  child: AnimatedOpacity(
                                      opacity: _isGrid ? 1 : 0,
                                      duration: Duration(milliseconds: 1000),
                                      child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      childAspectRatio: 0.8,
                                                      mainAxisSpacing: 10,
                                                      crossAxisSpacing: 10),
                                              controller: _scrollController,
                                              itemCount: list.length,
                                              itemBuilder: (context, index) {
                                                return GridPostWidget(
                                                    postModel: list[index]);
                                              }))));
                        })
                    : Consumer<PostState>(
                                builder: (context, state, child) {
                              final List<PostModel>? list =
                                  state.getPostList(authState.userModel);

                              return RefreshIndicator(
                                  color: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  onRefresh: () {
                                    HapticFeedback.mediumImpact();
                                    return _bodyView();
                                  },
                                  child: AnimatedOpacity(
                                      opacity: !_isGrid ? 1 : 0,
                                      duration: Duration(milliseconds: 300),
                                      child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: list?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            return FeedPostWidget(
                                              postModel: list![index],
                                            );
                                          })));
                        }))));
  }
}
