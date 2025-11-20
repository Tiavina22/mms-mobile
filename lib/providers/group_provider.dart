import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/group_message.dart';
import '../models/user.dart';
import '../services/group_service.dart';

/// Group Provider
/// Manages group chats
class GroupProvider with ChangeNotifier {
  final _groupService = GroupService();

  List<Group> _groups = [];
  Map<String, List<GroupMessage>> _groupMessagesCache = {};
  Map<String, List<User>> _groupMembersCache = {};
  bool _isLoading = false;
  String? _error;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all groups
  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _groupService.getGroups();
      _error = null;
    } catch (e) {
      _error = 'Failed to load groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new group
  Future<Group?> createGroup({
    required String name,
    String? description,
    String type = 'private',
  }) async {
    try {
      final group = await _groupService.createGroup(
        name: name,
        description: description,
        type: type,
      );

      if (group != null) {
        _groups.add(group);
        notifyListeners();
      }

      return group;
    } catch (e) {
      _error = 'Failed to create group: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get group messages
  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    // Check cache first
    if (_groupMessagesCache.containsKey(groupId)) {
      return _groupMessagesCache[groupId]!;
    }

    try {
      final messages = await _groupService.getGroupMessages(groupId);
      _groupMessagesCache[groupId] = messages;
      notifyListeners();
      return messages;
    } catch (e) {
      _error = 'Failed to load group messages: $e';
      notifyListeners();
      return [];
    }
  }

  /// Send message to group
  Future<bool> sendGroupMessage(String groupId, String content) async {
    try {
      final message = await _groupService.sendGroupMessage(
        groupId: groupId,
        content: content,
      );

      if (message != null) {
        // Add to cache
        if (_groupMessagesCache.containsKey(groupId)) {
          _groupMessagesCache[groupId]!.add(message);
        } else {
          _groupMessagesCache[groupId] = [message];
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get group members
  Future<List<User>> getGroupMembers(String groupId) async {
    // Check cache first
    if (_groupMembersCache.containsKey(groupId)) {
      return _groupMembersCache[groupId]!;
    }

    try {
      final members = await _groupService.getGroupMembers(groupId);
      _groupMembersCache[groupId] = members;
      notifyListeners();
      return members;
    } catch (e) {
      _error = 'Failed to load group members: $e';
      notifyListeners();
      return [];
    }
  }

  /// Add member to group
  Future<bool> addMember(String groupId, String userId) async {
    try {
      final success = await _groupService.addMember(groupId, userId);
      if (success) {
        // Clear members cache to force reload
        _groupMembersCache.remove(groupId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to add member: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove member from group
  Future<bool> removeMember(String groupId, String userId) async {
    try {
      final success = await _groupService.removeMember(groupId, userId);
      if (success) {
        // Clear members cache to force reload
        _groupMembersCache.remove(groupId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to remove member: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete group
  Future<bool> deleteGroup(String groupId) async {
    try {
      final success = await _groupService.deleteGroup(groupId);
      if (success) {
        _groups.removeWhere((g) => g.id == groupId);
        _groupMessagesCache.remove(groupId);
        _groupMembersCache.remove(groupId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete group: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _groupMessagesCache.clear();
    _groupMembersCache.clear();
    _groups.clear();
    notifyListeners();
  }
}

