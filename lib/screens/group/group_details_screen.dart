import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  List<User> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final groupProvider = context.read<GroupProvider>();
    final members = await groupProvider.getGroupMembers(widget.group.id);
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  Future<void> _showAddMemberDialog() async {
    final userProvider = context.read<UserProvider>();
    
    // Load all users if not already loaded
    if (userProvider.users.isEmpty) {
      await userProvider.loadUsers();
    }

    if (!mounted) return;

    // Filter out users who are already members
    final memberIds = _members.map((m) => m.id).toSet();
    final availableUsers = userProvider.users
        .where((user) => !memberIds.contains(user.id))
        .toList();

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All users are already members of this group'),
        ),
      );
      return;
    }

    final selectedUser = await showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableUsers.length,
            itemBuilder: (context, index) {
              final user = availableUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.username),
                subtitle: Text(user.email),
                onTap: () => Navigator.pop(context, user),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedUser != null && mounted) {
      final groupProvider = context.read<GroupProvider>();
      final success = await groupProvider.addMember(
        widget.group.id,
        selectedUser.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedUser.username} added to group'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMembers(); // Reload members
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add member'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeMember(User member) async {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;

    // Check if trying to remove self
    if (member.id == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot remove yourself from the group'),
        ),
      );
      return;
    }

    // Check if current user is the group creator
    if (widget.group.createdBy != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the group creator can remove members'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.username} from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final groupProvider = context.read<GroupProvider>();
      final success = await groupProvider.removeMember(
        widget.group.id,
        member.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.username} removed from group'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMembers(); // Reload members
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove member'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isCreator = widget.group.createdBy == authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.group,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.group.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.group.description ?? 'No description',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Chip(
                                label: Text(widget.group.type.toUpperCase()),
                                backgroundColor: widget.group.type == 'public'
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${_members.length} members'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Members Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Members',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isCreator)
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: _showAddMemberDialog,
                          tooltip: 'Add Member',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Members List
                  if (_members.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No members yet'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        final isMemberCreator =
                            member.id == widget.group.createdBy;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                member.username[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(member.username),
                                if (isMemberCreator) ...[
                                  const SizedBox(width: 8),
                                  const Chip(
                                    label: Text(
                                      'Admin',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(member.email),
                            trailing: isCreator && !isMemberCreator
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeMember(member),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

