import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _apiService = ApiService();
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  int? _rank;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getMyRank(),
      ]);

      final profileResponse = results[0];
      final rankResponse = results[1];

      if (profileResponse['success'] == true) {
        setState(() {
          _user = UserModel.fromJson(profileResponse['data']);

          if (rankResponse['success'] == true) {
            _rank = rankResponse['data']['rank'];
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              profileResponse['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditProfileDialog() async {
    final usernameController = TextEditingController(text: _user!.name);
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.lightGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Profil',
            style: AppText.heading.copyWith(
              fontSize: 20,
              color: AppColors.maroon,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username Field
                TextField(
                  controller: usernameController,
                  style: AppText.bodyWhite.copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: AppText.bodyWhite.copyWith(
                      color: AppColors.maroon.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(Icons.person, color: AppColors.maroon),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppColors.maroon.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: AppText.bodyWhite.copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    labelText: 'Password Baru (Opsional)',
                    labelStyle: AppText.bodyWhite.copyWith(
                      color: AppColors.maroon.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppColors.maroon),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.maroon,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppColors.maroon.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  style: AppText.bodyWhite.copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    labelStyle: AppText.bodyWhite.copyWith(
                      color: AppColors.maroon.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.maroon,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.maroon,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppColors.maroon.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.maroon, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kosongkan password jika tidak ingin mengubah',
                  style: AppText.bodyWhite.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: AppText.bodyWhite.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validasi
                if (usernameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username tidak boleh kosong'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }

                if (passwordController.text.isNotEmpty) {
                  if (passwordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password minimal 6 karakter'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password tidak cocok'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                    return;
                  }
                }

                Navigator.pop(context);

                // Ganti bagian TODO dengan:
                try {
                  final result = await _apiService.updateProfile(
                    name: usernameController.text,
                    password: passwordController.text.isEmpty
                        ? null
                        : passwordController.text,
                    passwordConfirmation: confirmPasswordController.text.isEmpty
                        ? null
                        : confirmPasswordController.text,
                  );

                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Reload profile
                    _loadProfile();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Gagal memperbarui profil',
                        ),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profil berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Reload profile
                _loadProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Simpan',
                style: AppText.bodyWhite.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Konfirmasi Logout',
          style: AppText.heading.copyWith(
            fontSize: 20,
            color: AppColors.maroon,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar?',
          style: AppText.bodyWhite.copyWith(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: AppText.bodyWhite.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: AppText.bodyWhite.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authRepository.logout();
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      setState(() {
        _isLoggingOut = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logout: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      );
    }

    if (_errorMessage != null || _user == null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage ?? 'Failed to load profile',
                  textAlign: TextAlign.center,
                  style: AppText.bodyWhite.copyWith(
                    color: AppColors.maroon,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text('Retry', style: AppText.bodyGold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Akun', style: AppText.heading),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.maroon,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Profile Picture with Fixed Border
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(
                    'assets/icons/no_pfp.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.maroon,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Edit Profile Button
              ElevatedButton(
                onPressed: _showEditProfileDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Edit Profil',
                  style: AppText.bodyWhite.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Username
              Text(
                _user!.name,
                style: AppText.heading.copyWith(
                  fontSize: 24,
                  color: AppColors.maroon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _user!.email,
                style: AppText.bodyWhite.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoCard('Username', _user!.name),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      'Peringkat saat ini',
                      _rank != null ? '#$_rank' : 'Belum ada',
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard('Total Coin', _user!.formattedScore),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      'Level Saat Ini',
                      'Level ${_user!.currentLevel}',
                    ),
                    const SizedBox(height: 15),
                    _buildStatRow(),
                    const SizedBox(height: 30),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoggingOut ? null : _handleLogout,
                        icon: _isLoggingOut
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.logout,
                                color: AppColors.white,
                                size: 20,
                              ),
                        label: _isLoggingOut
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Logout',
                                style: AppText.bodyWhite.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          disabledBackgroundColor: AppColors.red.withOpacity(
                            0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Text(
              label,
              style: AppText.bodyWhite.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                value,
                style: AppText.bodyWhite.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('assets/icons/coin.png', '${_user!.coins}', 'Coin'),
          Container(width: 1, height: 50, color: AppColors.gold),
          _buildStatItem(
            'assets/icons/poin.png',
            _user!.formattedScore,
            'Poin',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String iconPath, String value, String label) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.stars, size: 32, color: AppColors.gold);
          },
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppText.bodyGold.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppText.bodyGold.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.maroon,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.gold.withOpacity(0.6),
      selectedLabelStyle: AppText.bodyGold.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
      currentIndex: 3,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold,
          ),
          label: "Main Menu",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold,
          ),
          label: "Papan Peringkat",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: AppColors.gold,
          ),
          label: "Masukan",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: AppColors.gold,
          ),
          label: "Akun",
        ),
      ],
      onTap: (index) async {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            await Navigator.pushNamed(context, '/leaderboard');
            break;
          case 2:
            await Navigator.pushNamed(context, '/feedback');
            break;
          case 3:
            // Already on account
            break;
        }
      },
    );
  }
}
