import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:rebeal/helper/utility.dart';
import 'package:rebeal/model/user.module.dart';
import 'package:rebeal/state/app.state.dart';
import '../model/post.module.dart';

class PostState extends AppStates {
  bool isBusy = false;
  Map<String, List<PostModel>?> postReplyMap = {};
  PostModel? _postToReplyModel;
  PostModel? get postToReplyModel => _postToReplyModel;
  set setPostToReply(PostModel model) {
    _postToReplyModel = model;
  }

  List<PostModel>? _feedlist;
  dabase.Query? _feedQuery;
  List<PostModel>? _postDetailModelList;

  List<PostModel>? get postDetailModel => _postDetailModelList;

  List<PostModel>? get feedlist {
    if (_feedlist == null) {
      return null;
    } else {
      return List.from(_feedlist!.reversed);
    }
  }

  List<PostModel>? getPostList(UserModel? userModel) {
    final now = DateTime.now();

    if (userModel == null) {
      return null;
    }
    List<PostModel>? list;
    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      list = feedlist!.where((x) {
        if ((x.user!.userId == userModel.userId ||
                (userModel.followingList != null &&
                    userModel.followingList!.contains(x.user!.userId))) &&
            now.difference(DateTime.parse(x.createdAt)).inHours < 24) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    
    // Return mock data if no posts exist
    if (list == null || list.isEmpty) {
      return _getMockPosts();
    }
    
    return list;
  }
  
  List<PostModel> _getMockPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        createdAt: now.subtract(Duration(hours: 2)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800",
        bio: "Morning vibes ☀️",
        user: UserModel(
          userId: "mock1",
          displayName: "Sarah Johnson",
          userName: "@sarah_j",
          profilePic: "https://i.pravatar.cc/150?img=1",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(hours: 5)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800",
        bio: "Coffee time ☕",
        user: UserModel(
          userId: "mock2",
          displayName: "Mike Chen",
          userName: "@mike_c",
          profilePic: "https://i.pravatar.cc/150?img=12",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(hours: 8)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800",
        bio: "Lunch break 🍕",
        user: UserModel(
          userId: "mock3",
          displayName: "Emma Wilson",
          userName: "@emma_w",
          profilePic: "https://i.pravatar.cc/150?img=5",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(hours: 12)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1504593811423-6dd665756598?w=800",
        bio: "Gym session 💪",
        user: UserModel(
          userId: "mock4",
          displayName: "Alex Martinez",
          userName: "@alex_m",
          profilePic: "https://i.pravatar.cc/150?img=8",
        ),
      ),
      PostModel(
        createdAt: now.subtract(Duration(hours: 18)).toIso8601String(),
        imageFrontPath: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800",
        imageBackPath: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
        bio: "Sunset walk 🌅",
        user: UserModel(
          userId: "mock5",
          displayName: "Lisa Anderson",
          userName: "@lisa_a",
          profilePic: "https://i.pravatar.cc/150?img=9",
        ),
      ),
    ];
  }

  List<PostModel>? getPostLists(UserModel? userModel) {
    if (userModel == null) {
      return null;
    }

    List<PostModel>? list;

    if (!isBusy && feedlist != null && feedlist!.isNotEmpty) {
      list = feedlist!.where((x) {
        return true;
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  set setFeedModel(PostModel model) {
    _postDetailModelList ??= [];

    _postDetailModelList!.add(model);
    notifyListeners();
  }

  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("posts");
        _feedQuery!.onChildAdded.listen(onPostAdded);
      }
      return Future.value(true);
    } catch (error) {
      return Future.value(false);
    }
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      _feedlist = null;
      notifyListeners();
      kDatabase.child('posts').once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        _feedlist = <PostModel>[];
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((key, value) {
              var model = PostModel.fromJson(value);
              model.key = key;
              _feedlist!.add(model);
            });
            _feedlist!.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
          }
        } else {
          _feedlist = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
    }
  }

  onPostAdded(DatabaseEvent event) {
    PostModel post = PostModel.fromJson(event.snapshot.value as Map);
    post.key = event.snapshot.key!;

    post.key = event.snapshot.key!;
    _feedlist ??= <PostModel>[];
    if ((_feedlist!.isEmpty || _feedlist!.any((x) => x.key != post.key))) {
      _feedlist!.add(post);
    }
    isBusy = false;
    notifyListeners();
  }
}
