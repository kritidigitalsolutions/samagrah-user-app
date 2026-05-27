// import 'package:samagrah/data/network/network_api_service.dart';
// import 'package:samagrah/res/app_urls.dart';
// import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

// class AgoraRepo {
//   final _api = NetworkApiService();

//   // POST /api/user/video/token
//   Future<VideoTokenResModel> fetchToken(VideoTokenReqModel req) async {
//     try {
//       final token = await AuthLocalstorageService.getToken() ?? '';
//       _api.setToken(token);
//       final res = await _api.postApi(AppUrls.videoToken, req.toJson());
//       return VideoTokenResModel.fromJson(res['data'] ?? res); // ✅ unwrap data
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // POST /api/user/video/start
//   Future<VideoCallResModel> startCall(VideoStartReqModel req) async {
//     try {
//       final token = await AuthLocalstorageService.getToken() ?? '';
//       _api.setToken(token);
//       final res = await _api.postApi(AppUrls.videoStart, req.toJson());
//       return VideoCallResModel.fromJson(res['data'] ?? res);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // POST /api/user/video/:id/end
//   Future<void> endCall(String callId) async {
//     try {
//       final token = await AuthLocalstorageService.getToken() ?? '';
//       _api.setToken(token);
//       final uri = "${AppUrls.video}/$callId/end";
//       await _api.postApi(uri, {});
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // GET /api/user/video/:id
//   Future<VideoCallResModel> getCall(String callId) async {
//     try {
//       final token = await AuthLocalstorageService.getToken() ?? '';
//       _api.setToken(token);
//       final uri = "${AppUrls.video}/$callId";
//       final res = await _api.getApi(uri);
//       return VideoCallResModel.fromJson(res['data'] ?? res);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

// class VideoTokenReqModel {
//   final String channelName;
//   final int uid;
//   final int expireSeconds;

//   VideoTokenReqModel({
//     required this.channelName,
//     required this.uid,
//     this.expireSeconds = 3600,
//   });

//   Map<String, dynamic> toJson() => {
//     'channelName': channelName,
//     'uid': uid,
//     'expireSeconds': expireSeconds,
//   };
// }

// class VideoTokenResModel {
//   final String appId;
//   final String token;
//   final String channelName;
//   final int uid;

//   VideoTokenResModel({
//     required this.appId,
//     required this.token,
//     required this.channelName,
//     required this.uid,
//   });

//   factory VideoTokenResModel.fromJson(Map<String, dynamic> json) =>
//       VideoTokenResModel(
//         appId: json['appId'] ?? '',
//         token: json['token'] ?? '',
//         channelName: json['channelName'] ?? '',
//         uid: json['uid'] ?? 0,
//       );
// }

// class VideoStartReqModel {
//   final String channelName;
//   final String calleeId;
//   final int uid;
//   final Map<String, dynamic>? meta;

//   VideoStartReqModel({
//     required this.channelName,
//     required this.calleeId,
//     required this.uid,
//     this.meta,
//   });

//   Map<String, dynamic> toJson() => {
//     'channelName': channelName,
//     'calleeId': calleeId,
//     'uid': uid,
//     if (meta != null) 'meta': meta,
//   };
// }

// class VideoCallResModel {
//   final String? id;
//   final String? channelName;
//   final String? status;
//   final String? calleeId;
//   final int? uid;

//   VideoCallResModel({
//     this.id,
//     this.channelName,
//     this.status,
//     this.calleeId,
//     this.uid,
//   });

//   factory VideoCallResModel.fromJson(Map<String, dynamic> json) =>
//       VideoCallResModel(
//         id: json['_id'] ?? json['id'],
//         channelName: json['channelName'],
//         status: json['status'],
//         calleeId: json['calleeId'],
//         uid: json['uid'],
//       );
// }
