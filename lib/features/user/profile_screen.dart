import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _wardController;
  late TextEditingController _houseController;
  String? _selectedPhotoUrl;

  final List<Map<String, String>> _predefinedAvatars = [
    {
      'name': 'Tree Planter',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=planter&backgroundColor=b6e3f4'
    },
    {
      'name': 'Recycling Champ',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=recycler&backgroundColor=d1f4ff'
    },
    {
      'name': 'Energy Saver',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=energy&backgroundColor=ffd5dc'
    },
    {
      'name': 'Water Guardian',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=water&backgroundColor=c0aede'
    },
    {
      'name': 'Eco Warrior',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=warrior&backgroundColor=ffdfad'
    },
    {
      'name': 'Nature Lover',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=nature&backgroundColor=b6ffd4'
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _wardController = TextEditingController(text: user?.wardNo ?? '');
    _houseController = TextEditingController(text: user?.houseNo ?? '');
    _selectedPhotoUrl = user?.profilePhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _wardController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  ImageProvider? _getAvatarImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      final base64Str = photoUrl.split(',').last;
      try {
        return MemoryImage(base64.decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = 'data:image/png;base64,${base64.encode(bytes)}';
        setState(() {
          _selectedPhotoUrl = base64Image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHANGE PROFILE PHOTO',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                    icon: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                    label: Text(
                      'GALLERY',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              const Text(
                'OR SELECT ECO AVATAR',
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _predefinedAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _predefinedAvatars[index];
                  final isSelected = _selectedPhotoUrl == avatar['url'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPhotoUrl = avatar['url'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          avatar['url']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white10,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      wardNo: _wardController.text.trim(),
      houseNo: _houseController.text.trim(),
      profilePhoto: _selectedPhotoUrl,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Update failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (user == null) return const SizedBox.shrink();

    if (!_isEditing) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _addressController.text = user.address ?? '';
      _wardController.text = user.wardNo ?? '';
      _houseController.text = user.houseNo ?? '';
      _selectedPhotoUrl = user.profilePhoto;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    backgroundImage: _getAvatarImage(_selectedPhotoUrl),
                    child: _selectedPhotoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 60)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black, size: 16),
                          onPressed: _showAvatarPicker,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (!_isEditing) ...[
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(user.email, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60)),
                const SizedBox(height: 32),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESIDENTIAL DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.home_rounded, 'House No.', user.houseNo ?? 'Not Set'),
                      const Divider(color: Colors.white10, height: 24),
                      _buildDetailRow(Icons.domain_rounded, 'Ward No.', user.wardNo ?? 'Not Set'),
                      const Divider(color: Colors.white10, height: 24),
                      _buildDetailRow(Icons.location_on_rounded, 'Address', user.address ?? 'Not Set'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.03),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.credit_card, color: primaryColor),
                    title: const Text('RFID Tag ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.rfid, style: const TextStyle(fontFamily: 'monospace')),
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('EDIT PROFILE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthProvider>().logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                        label: const Text('LOGOUT', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'FULL NAME', Icons.person_rounded),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'EMAIL ADDRESS', Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_houseController, 'HOUSE NUMBER', Icons.home_rounded),
                const SizedBox(height: 16),
                _buildTextField(_wardController, 'WARD NUMBER', Icons.domain_rounded),
                const SizedBox(height: 16),
                _buildTextField(_addressController, 'COMPLETE ADDRESS', Icons.location_on_rounded, maxLines: 2),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('CANCEL', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }
}
