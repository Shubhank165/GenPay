import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/bank_provider.dart';
import '../../providers/bill_provider.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/search_bar.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_contacts.dart';
import 'widgets/services_grid.dart';
import 'widgets/offers_carousel.dart';
import 'widgets/promo_banner.dart';
import '../../screens/scan/scan_pay_screen.dart';
import '../../screens/offers/offers_screen.dart';
import '../../screens/passbook/passbook_screen.dart';
import '../../screens/profile/profile_screen.dart';

enum PaymentMode { online, offline }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _promptController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  static const String _upiPin = '165165';
  bool _isPromptLoading = false;
  bool _isOfflineOtpLoading = false;
  bool _isVoiceRecording = false;
  bool _isVoiceTranscribing = false;
  bool _needsConfirmation = false;
  String _promptFeedback = '';
  String _lastPrompt = '';
  String? _lastUpiPin;
  String? _lastPaymentOtpToken;
  PaymentMode _paymentMode = PaymentMode.online;
  List<Map<String, dynamic>> _promptOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<TransactionProvider>().loadTransactions();
    context.read<BankProvider>().loadAccounts();
    context.read<BillProvider>().loadBills();
    context.read<WalletProvider>().loadBalanceFromBackend();
  }

  Future<void> _submitPrompt({bool userConfirmation = false}) async {
    final message = userConfirmation ? _lastPrompt : _promptController.text.trim();
    if (message.isEmpty) {
      return;
    }

    final auth = context.read<AuthProvider>();

    String? upiPin;
    String? paymentOtpToken;
    final paymentMode = _paymentMode == PaymentMode.offline ? 'offline' : 'online';
    if (_isTransactionPrompt(message)) {
      if (_paymentMode == PaymentMode.offline) {
        if (userConfirmation && _lastPaymentOtpToken != null) {
          paymentOtpToken = _lastPaymentOtpToken;
        } else {
          paymentOtpToken = await _verifyOfflinePaymentOtpForCurrentUser();
          if (paymentOtpToken == null) {
            return;
          }
        }
      } else {
        if (userConfirmation && _lastUpiPin != null) {
          upiPin = _lastUpiPin;
        } else {
          upiPin = await _askUpiPin();
          if (upiPin == null) {
            return;
          }
        }
      }
    }

    setState(() {
      _isPromptLoading = true;
      _promptFeedback = '';
      _promptOptions = [];
    });

    try {
      final storedUserId = await LocalStorageService.getUserId();
      final userId = auth.currentUser?.id ?? storedUserId ?? '123';

      final response = await ApiService.queryAgent(
        userId,
        message,
        userConfirmation: userConfirmation,
        upiPin: upiPin,
        paymentMode: paymentMode,
        paymentOtpToken: paymentOtpToken,
      );

      final status = (response['status'] ?? '').toString();
      final messageText = (response['message'] ?? '').toString();
      final reason = (response['reason'] ?? '').toString();
      final options = (response['options'] is List)
          ? (response['options'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
          : <Map<String, dynamic>>[];

      if (status == 'confirmation_required') {
        setState(() {
          _needsConfirmation = true;
          _lastPrompt = message;
          _lastUpiPin = upiPin;
          _lastPaymentOtpToken = paymentOtpToken;
          _promptFeedback = messageText;
          _promptOptions = options;
        });
      } else {
        setState(() {
          _needsConfirmation = false;
          _lastUpiPin = null;
          _lastPaymentOtpToken = null;
          _promptFeedback = reason.isNotEmpty ? '$messageText ($reason)' : messageText;
          _promptOptions = options;
        });
        _loadData();
      }
    } catch (e) {
      setState(() {
        _needsConfirmation = false;
        _lastUpiPin = null;
        _lastPaymentOtpToken = null;
        _promptFeedback = 'Prompt execution failed: $e';
        _promptOptions = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isPromptLoading = false);
      }
    }
  }

  bool _isTransactionPrompt(String message) {
    final text = message.toLowerCase();
    return text.contains('send') ||
        text.contains('pay') ||
        text.contains('transfer') ||
        text.contains('recharge');
  }

  Future<String?> _askUpiPin() async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter UPI PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(hintText: '6-digit UPI PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (pin == null) {
      return null;
    }
    if (pin != _upiPin) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid UPI PIN'), backgroundColor: AppColors.errorRed),
      );
      return null;
    }
    return pin;
  }

  Future<String?> _resolveCurrentUserPhone() async {
    final auth = context.read<AuthProvider>();
    final profilePhone = auth.currentUser?.phone.trim();
    if (profilePhone != null && profilePhone.isNotEmpty) {
      return profilePhone;
    }
    final storedPhone = await LocalStorageService.getPhoneNumber();
    if (storedPhone != null && storedPhone.trim().isNotEmpty) {
      return storedPhone.trim();
    }
    return null;
  }

  Future<String?> _askOfflinePaymentOtp({String? debugOtp}) async {
    final controller = TextEditingController();
    final otp = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Offline Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter OTP received on call to authorize offline payment.'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(hintText: '6-digit OTP'),
            ),
            if (debugOtp != null && debugOtp.isNotEmpty)
              Text(
                'Debug OTP: $debugOtp',
                style: const TextStyle(color: AppColors.warningYellow, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    return otp;
  }

  Future<String?> _verifyOfflinePaymentOtpForCurrentUser() async {
    final phone = await _resolveCurrentUserPhone();
    if (phone == null) {
      if (!mounted) return null;
      setState(() {
        _promptFeedback = 'Phone number not found for offline OTP verification';
      });
      return null;
    }

    setState(() {
      _isOfflineOtpLoading = true;
      _promptFeedback = 'Requesting offline payment OTP call...';
    });

    try {
      final request = await ApiService.requestOfflinePaymentOtp(phone);
      final otp = await _askOfflinePaymentOtp(debugOtp: request['debug_otp']?.toString());
      if (otp == null || otp.length != 6) {
        return null;
      }

      final verify = await ApiService.verifyOfflinePaymentOtp(phone, otp);
      final token = (verify['payment_otp_token'] ?? '').toString();
      if (token.isEmpty) {
        return null;
      }

      if (!mounted) return token;
      setState(() {
        _promptFeedback = 'Offline OTP verified. Processing payment...';
      });
      return token;
    } catch (e) {
      if (!mounted) return null;
      setState(() {
        _promptFeedback = 'Offline payment OTP failed: $e';
      });
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isOfflineOtpLoading = false;
        });
      }
    }
  }

  Future<void> _setPaymentMode(PaymentMode mode) async {
    if (_isPromptLoading || _isVoiceTranscribing || _isOfflineOtpLoading) {
      return;
    }

    setState(() {
      _paymentMode = mode;
      _lastPaymentOtpToken = null;
      if (mode == PaymentMode.offline) {
        _promptFeedback = 'Offline mode selected. OTP call will start after you press Run.';
      } else {
        _promptFeedback = 'Online payment mode enabled';
      }
    });
  }

  Future<void> _toggleVoicePromptInput() async {
    if (_isVoiceTranscribing || _isPromptLoading) {
      return;
    }

    if (_isVoiceRecording) {
      final path = await _audioRecorder.stop();
      if (!mounted) return;

      setState(() {
        _isVoiceRecording = false;
      });

      if (path == null || path.isEmpty) {
        setState(() {
          _promptFeedback = 'Voice capture failed. Please try again.';
        });
        return;
      }

      setState(() {
        _isVoiceTranscribing = true;
        _promptFeedback = 'Transcribing voice input...';
      });

      try {
        final text = await ApiService.transcribePromptAudio(path);
        if (!mounted) return;

        setState(() {
          final current = _promptController.text.trim();
          _promptController.text = current.isEmpty ? text : '$current $text';
          _promptController.selection = TextSelection.fromPosition(
            TextPosition(offset: _promptController.text.length),
          );
          _promptFeedback = 'Voice input added to prompt';
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _promptFeedback = 'Voice transcription failed: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isVoiceTranscribing = false;
          });
        }
      }
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      setState(() {
        _promptFeedback = 'Microphone permission is required for voice input';
      });
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/genpay_prompt_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    if (!mounted) return;
    setState(() {
      _isVoiceRecording = true;
      _promptFeedback = 'Listening... Tap mic again to stop';
    });
  }

  Widget _getBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const ScanPayScreen();
      case 2:
        return const OffersScreen();
      case 3:
        return const PassbookScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primaryBlue,
      child: CustomScrollView(
        slivers: [
          // App Bar with search
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      // Top row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'GenPay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          _buildAppBarIcon(Icons.qr_code_scanner_rounded, () {
                            setState(() => _currentNavIndex = 1);
                          }),
                          const SizedBox(width: 8),
                          _buildAppBarIcon(Icons.notifications_outlined, () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          }),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _currentNavIndex = 4),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search bar
                      AppSearchBar(
                        readOnly: true,
                        onTap: () {
                          // TODO: navigate to search
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: (_isPromptLoading || _isOfflineOtpLoading)
                                        ? null
                                        : () => _setPaymentMode(PaymentMode.online),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: _paymentMode == PaymentMode.online ? Colors.white : Colors.white70,
                                      ),
                                      backgroundColor: _paymentMode == PaymentMode.online
                                          ? Colors.white.withOpacity(0.22)
                                          : Colors.transparent,
                                    ),
                                    icon: const Icon(Icons.wifi_rounded, size: 18),
                                    label: const Text('Online'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: (_isPromptLoading || _isOfflineOtpLoading)
                                        ? null
                                        : () => _setPaymentMode(PaymentMode.offline),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: _paymentMode == PaymentMode.offline ? Colors.white : Colors.white70,
                                      ),
                                      backgroundColor: _paymentMode == PaymentMode.offline
                                          ? Colors.white.withOpacity(0.22)
                                          : Colors.transparent,
                                    ),
                                    icon: _isOfflineOtpLoading
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.phone_forwarded_rounded, size: 18),
                                    label: const Text('Offline'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _promptController,
                                    style: const TextStyle(color: Colors.white),
                                    minLines: 1,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: 'Ask GenPay: Pay Rahul 500',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: (_isPromptLoading || _isVoiceTranscribing || _isOfflineOtpLoading)
                                        ? null
                                        : _toggleVoicePromptInput,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isVoiceRecording ? AppColors.errorRed : Colors.white,
                                      foregroundColor: _isVoiceRecording ? Colors.white : AppColors.darkBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: _isVoiceTranscribing
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Icon(_isVoiceRecording ? Icons.stop_rounded : Icons.mic_rounded),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: (_isPromptLoading ||
                                            _isVoiceRecording ||
                                            _isVoiceTranscribing ||
                                            _isOfflineOtpLoading)
                                        ? null
                                        : () => _submitPrompt(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.darkBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: _isPromptLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Run', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                            if (_needsConfirmation) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isPromptLoading ? null : () => _submitPrompt(userConfirmation: true),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Confirm Action'),
                                ),
                              ),
                            ],
                            if (_promptFeedback.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _promptFeedback,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            if (_promptOptions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  height: 132,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _promptOptions.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final option = _promptOptions[index];
                                      final title = (option['title'] ?? 'Option').toString();
                                      final subtitle = (option['subtitle'] ?? '').toString();
                                      final meta = (option['meta'] ?? '').toString();
                                      final type = (option['type'] ?? '').toString();
                                      final price = option['price'];
                                      final priceText = price is num ? 'Rs ${price.toStringAsFixed(0)}' : '';

                                      return Container(
                                        width: 190,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (priceText.isNotEmpty)
                                              Text(
                                                priceText,
                                                style: const TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            if (meta.isNotEmpty)
                                              Text(
                                                meta,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            if (type.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  type.replaceAll('_', ' ').toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.textTertiary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Balance Card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: BalanceCard(),
            ),
          ),

          // Quick Actions
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: QuickActions(),
            ),
          ),

          // Recent Contacts
          const SliverToBoxAdapter(
            child: RecentContacts(),
          ),

          // Promo Banner
          const SliverToBoxAdapter(
            child: PromoBanner(),
          ),

          // Services Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recharge & Pay Bills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.billCategories),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const ServicesGrid(),
                ],
              ),
            ),
          ),

          // Offers Carousel
          const SliverToBoxAdapter(
            child: OffersCarousel(),
          ),

          // Travel Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Travel & Entertainment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTravelCard(Icons.flight, 'Flights', AppColors.primaryBlue, () {
                        Navigator.pushNamed(context, AppRoutes.flightBooking);
                      }),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.train, 'Trains', AppColors.successGreen, () {}),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.directions_bus, 'Buses', AppColors.orangeCTA, () {
                        Navigator.pushNamed(context, AppRoutes.busBooking);
                      }),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.hotel, 'Hotels', AppColors.broadbandColor, () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Financial Services
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFinanceRow(),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTravelCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFinanceCard('Digital\nGold', Icons.monetization_on, AppColors.goldColor, () {
            Navigator.pushNamed(context, AppRoutes.gold);
          }),
          _buildFinanceCard('Mutual\nFunds', Icons.show_chart, AppColors.successGreen, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Insurance', Icons.shield, AppColors.primaryBlue, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Loans', Icons.account_balance, AppColors.loanColor, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Credit\nScore', Icons.speed, AppColors.orangeCTA, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
