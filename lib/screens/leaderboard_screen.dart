import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _topUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> users = await _authService.getTopUsers();

    if (mounted) {
      setState(() {
        _topUsers = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _authService.currentUser?.uid ?? "";

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Liderlik Tablosu 🏆",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              color: AppColors.gradientMid,
              child: _topUsers.isEmpty
                  ? const Center(
                      child: Text("Henüz veri yok",
                          style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _topUsers.length,
                      itemBuilder: (context, index) {
                        final user = _topUsers[index];
                        final bool isMe = user['id'] == currentUserId;
                        final int rank = index + 1;

                        // İlk 3 için özel ikon/renk
                        Color? medalColor;
                        IconData? rankIcon;
                        if (rank == 1) {
                          medalColor = const Color(0xFFFFD700); // Altın
                          rankIcon = Icons.emoji_events;
                        } else if (rank == 2) {
                          medalColor = const Color(0xFFC0C0C0); // Gümüş
                          rankIcon = Icons.military_tech;
                        } else if (rank == 3) {
                          medalColor = const Color(0xFFCD7F32); // Bronz
                          rankIcon = Icons.military_tech;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColors.gradientMid
                                    .withOpacity(0.9) // Kendisi için vurgu
                                : AppColors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: isMe
                                ? Border.all(color: Colors.amber, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: rankIcon != null
                                  ? Icon(rankIcon, color: medalColor, size: 32)
                                  : Text(
                                      "#$rank",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isMe
                                            ? Colors.white
                                            : AppColors.textDark,
                                      ),
                                    ),
                            ),
                            title: Text(
                              user['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isMe ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.white.withOpacity(0.2)
                                    : AppColors.gradientLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${user['score']} P",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMe
                                      ? Colors.white
                                      : AppColors.gradientDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
