import 'dart:convert';
import '../config/api_config.dart';
import '../models/group.dart';
import '../models/group_message.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Group Service
/// Handles group operations
class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  final _api = ApiService();

  /// Create a new group
  Future<Group?> createGroup({
    required String name,
    String? description,
    String type = 'private',
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.groups,
        body: {
          'name': name,
          if (description != null) 'description': description,
          'type': type,
        },
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return Group.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  /// Get all groups for current user
  Future<List<Group>> getGroups() async {
    try {
      final response = await _api.get(ApiConfig.myGroups);

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch groups: $e');
    }
  }

  /// Get group by ID
  Future<Group?> getGroupById(String id) async {
    try {
      final response = await _api.get(ApiConfig.groupById(id));

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return Group.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch group: $e');
    }
  }

  /// Get group members
  Future<List<User>> getGroupMembers(String groupId) async {
    try {
      final response = await _api.get(ApiConfig.groupMembers(groupId));

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch group members: $e');
    }
  }

  /// Add member to group
  Future<bool> addMember(String groupId, String userId) async {
    try {
      final response = await _api.post(
        ApiConfig.addGroupMember(groupId),
        body: {'user_id': userId},
      );

      return _api.isSuccess(response);
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  /// Remove member from group
  Future<bool> removeMember(String groupId, String userId) async{
    try {
      final response =
          await _api.delete(ApiConfig.removeGroupMember(groupId, userId));

      return _api.isSuccess(response);
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  /// Get group messages
  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    try {
      final response = await _api.get(ApiConfig.groupMessages(groupId));

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => GroupMessage.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch group messages: $e');
    }
  }

  /// Send message to group
  Future<GroupMessage?> sendGroupMessage({
    required String groupId,
    required String content,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.sendGroupMessage,
        body: {'group_id': groupId, 'content': content},
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return GroupMessage.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Delete group
  Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await _api.delete(ApiConfig.groupById(groupId));
      return _api.isSuccess(response);
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }
}

