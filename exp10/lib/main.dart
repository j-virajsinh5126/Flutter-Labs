
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChatWaveApp());
}

// =====================================================
// MAIN APPLICATION
// =====================================================

class ChatWaveApp extends StatelessWidget {
  const ChatWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatWave',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F3FA),
      ),

      home: const AuthGate(),
    );
  }
}

// =====================================================
// AUTHENTICATION GATE
// =====================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  late Future<UserCredential> authFuture;

  @override
  void initState() {
    super.initState();

    authFuture = FirebaseAuth.instance.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserCredential>(
      future: authFuture,

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    const Text('Firebase Authentication Failed'),
                    const SizedBox(height: 10),
                    Text('${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          authFuture =
                              FirebaseAuth.instance.signInAnonymously();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to authenticate'),
            ),
          );
        }

        return const ChatHomePage();
      },
    );
  }
}

// =====================================================
// CHAT ROOM MODEL
// =====================================================

class ChatRoom {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// =====================================================
// CHAT ROOMS DATA
// =====================================================

const List<ChatRoom> chatRooms = [
  ChatRoom(
    id: 'general',
    name: 'General Chat',
    icon: Icons.forum,
    color: Colors.deepPurple,
  ),

  ChatRoom(
    id: 'technology',
    name: 'Technology',
    icon: Icons.computer,
    color: Colors.blue,
  ),

  ChatRoom(
    id: 'programming',
    name: 'Programming',
    icon: Icons.code,
    color: Colors.green,
  ),

  ChatRoom(
    id: 'college',
    name: 'College Discussion',
    icon: Icons.school,
    color: Colors.orange,
  ),
];

// =====================================================
// FIRESTORE SERVICE
// =====================================================

class ChatService {

  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> messages(
    String roomId,
  ) {
    return firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages');
  }

  // SEND MESSAGE
  static Future<void> sendMessage({
    required String roomId,
    required String text,
    required String senderName,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await messages(roomId).add({
      'text': text.trim(),
      'senderId': user.uid,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
      'editedAt': null,
    });
  }

  // GET REAL-TIME MESSAGES
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String roomId,
  ) {
    return messages(roomId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // EDIT MESSAGE
  static Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {

    await messages(roomId).doc(messageId).update({
      'text': newText.trim(),
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE MESSAGE
  static Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {

    await messages(roomId).doc(messageId).delete();
  }
}

// =====================================================
// HOME SCREEN
// =====================================================

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {

  final TextEditingController messageController =
      TextEditingController();

  final TextEditingController searchController =
      TextEditingController();

  String selectedRoomId = 'general';

  String searchQuery = '';

  String userName = 'Student';

  bool isSending = false;

  User get currentUser => FirebaseAuth.instance.currentUser!;

  ChatRoom get selectedRoom {
    return chatRooms.firstWhere(
      (room) => room.id == selectedRoomId,
    );
  }

  // SEND MESSAGE
  Future<void> sendMessage() async {

    final text = messageController.text.trim();

    if (text.isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      await ChatService.sendMessage(
        roomId: selectedRoomId,
        text: text,
        senderName: userName,
      );

      messageController.clear();
    } catch (e) {
      if (mounted) {
        showMessage('Failed to send message: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // SHOW SNACKBAR
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // EDIT MESSAGE DIALOG
  Future<void> showEditDialog(
    String messageId,
    String oldText,
  ) async {

    final controller = TextEditingController(text: oldText);

    final result = await showDialog<String>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Message'),

          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter new message',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(
                    context,
                    controller.text.trim(),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    try {
      await ChatService.editMessage(
        roomId: selectedRoomId,
        messageId: messageId,
        newText: result,
      );

      if (mounted) {
        showMessage('Message updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Unable to edit message: $e');
      }
    }
  }

  // DELETE MESSAGE
  Future<void> deleteMessage(String messageId) async {

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Message?'),

          content: const Text(
            'Are you sure you want to delete this message?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ChatService.deleteMessage(
        roomId: selectedRoomId,
        messageId: messageId,
      );

      if (mounted) {
        showMessage('Message deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Unable to delete message: $e');
      }
    }
  }

  // CHANGE USER NAME
  Future<void> changeUserName() async {

    final controller = TextEditingController(text: userName);

    final result = await showDialog<String>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Change Display Name'),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(
                    context,
                    controller.text.trim(),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    try {
      await currentUser.updateDisplayName(result);

      if (!mounted) return;

      setState(() {
        userName = result;
      });

      showMessage('Display name updated');
    } catch (e) {
      if (mounted) {
        showMessage('Unable to update display name');
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // =========================================
      // APP BAR
      // =========================================

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        title: const Text(
          'ChatWave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: changeUserName,
            icon: const Icon(Icons.person),
            tooltip: 'Change Display Name',
          ),
        ],
      ),

      // =========================================
      // DRAWER
      // =========================================

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.chat,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'ChatWave',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const ListTile(
              leading: Icon(Icons.chat),
              title: Text('Real-Time Chat'),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Name'),
              onTap: () {
                Navigator.pop(context);
                changeUserName();
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthGate(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // =========================================
      // BODY
      // =========================================

      body: Column(
        children: [

          // ROOM SELECTOR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),

            color: Colors.white,

            child: Row(
              children: [

                const Icon(
                  Icons.meeting_room,
                  color: Colors.deepPurple,
                ),

                const SizedBox(width: 12),

                const Text(
                  'Chat Room:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedRoomId,
                    isExpanded: true,

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),

                    items: chatRooms.map((room) {
                      return DropdownMenuItem<String>(
                        value: room.id,
                        child: Text(
                          room.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRoomId = value;
                          searchQuery = '';
                          searchController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12, 12, 12, 5,
            ),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ROOM INFORMATION
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: Row(
              children: [

                Icon(
                  selectedRoom.icon,
                  color: selectedRoom.color,
                ),

                const SizedBox(width: 8),

                Text(
                  selectedRoom.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 9,
                ),

                const SizedBox(width: 5),

                const Text(
                  'Connected',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // =========================================
          // STREAM BUILDER
          // =========================================

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: ChatService.getMessages(selectedRoomId),

              builder: (context, snapshot) {

                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 55,
                          ),

                          const SizedBox(height: 12),

                          const Text('Unable to load messages'),

                          const SizedBox(height: 8),

                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // EMPTY RESPONSE
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 65,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No messages yet!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),

                        Text(
                          'Send the first message.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allMessages = snapshot.data!.docs;

                // SEARCH FILTER
                final filteredMessages = allMessages.where((doc) {
                  final data = doc.data();

                  final text = (data['text'] ?? '')
                      .toString()
                      .toLowerCase();

                  final sender = (data['senderName'] ?? '')
                      .toString()
                      .toLowerCase();

                  return text.contains(searchQuery) ||
                      sender.contains(searchQuery);
                }).toList();

                if (filteredMessages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching messages found.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // DISPLAY MESSAGES
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),

                  itemCount: filteredMessages.length,

                  itemBuilder: (context, index) {

                    final doc = filteredMessages[index];

                    final data = doc.data();

                    final isMe =
                        data['senderId'] == currentUser.uid;

                    final timestamp =
                        data['createdAt'] as Timestamp?;

                    return MessageBubble(
                      messageId: doc.id,
                      roomId: selectedRoomId,
                      text: data['text'] ?? '',
                      senderName: data['senderName'] ?? 'Student',
                      timestamp: timestamp,
                      isMe: isMe,

                      onEdit: () {
                        showEditDialog(
                          doc.id,
                          data['text'] ?? '',
                        );
                      },

                      onDelete: () {
                        deleteMessage(doc.id);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // =========================================
          // MESSAGE INPUT
          // =========================================

          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 4,

                    textCapitalization:
                        TextCapitalization.sentences,

                    decoration: InputDecoration(
                      hintText: 'Type your message...',

                      filled: true,
                      fillColor: const Color(0xFFF2F0F7),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),

                    onSubmitted: (_) => sendMessage(),
                  ),
                ),

                const SizedBox(width: 10),

                // SEND BUTTON
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.deepPurple,

                  child: IconButton(
                    onPressed: isSending ? null : sendMessage,

                    icon: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MESSAGE BUBBLE
// =====================================================

class MessageBubble extends StatelessWidget {
  final String messageId;
  final String roomId;
  final String text;
  final String senderName;
  final Timestamp? timestamp;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MessageBubble({
    super.key,
    required this.messageId,
    required this.roomId,
    required this.text,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final time = timestamp == null
        ? 'Sending...'
        : TimeOfDay.fromDateTime(
            timestamp!.toDate(),
          ).format(context);

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: GestureDetector(
        onLongPress: isMe
            ? () {
                showModalBottomSheet(
                  context: context,

                  builder: (context) {
                    return SafeArea(
                      child: Wrap(
                        children: [

                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit Message'),
                            onTap: () {
                              Navigator.pop(context);
                              onEdit();
                            },
                          ),

                          ListTile(
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: const Text('Delete Message'),
                            onTap: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            : null,

        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),

          margin: const EdgeInsets.only(bottom: 12),

          padding: const EdgeInsets.all(13),

          decoration: BoxDecoration(
            color: isMe
                ? Colors.deepPurple
                : Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    senderName,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 7),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    time,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white70
                          : Colors.grey,
                      fontSize: 10,
                    ),
                  ),

                  if (isMe) ...[
                    const SizedBox(width: 6),

                    const Icon(
                      Icons.done_all,
                      color: Colors.white70,
                      size: 13,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
