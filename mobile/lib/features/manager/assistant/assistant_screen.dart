import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'models/assistant_message.dart';
import 'assistant_voice_service.dart';
import 'providers/assistant_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// قالب مارک‌داون — با bodyMedium صریح (محیط‌هایی که قلم پیش‌فرض null دارند)
final _markdownTheme = ThemeData.dark().copyWith(
  textTheme: ThemeData.dark().textTheme.merge(
    const TextTheme(bodyMedium: TextStyle(fontSize: 13, color: Colors.white)),
  ),
);

/// دستیار هوش مصنوعی مدیر — پرسش/گزارش‌گیری از دیتابیس با استریم زنده
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  AssistantVoiceService? _voice;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // اگر صفحه بسته شد و میکروفون هنوز روشن است → لغو فوری بدون نتیجه
    _voice?.cancel();
    _inputCtrl.dispose();
    super.dispose();
  }

  AssistantVoiceService get _voiceService {
    final existing = _voice;
    if (existing != null) return existing;
    final created = ref.read(assistantVoiceServiceProvider);
    _voice = created;
    return created;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _red));
  }

  Future<void> _startRecording() async {
    if (_recording) return; // دبل‌لانگ‌پرس → دوبار شروع نشود
    final voice = _voiceService;
    final ok = await voice.initialize(
      onError: (error) {
        // خطای دائمی وسط ضبط → بنر ضبط بسته شود
        if (mounted && error != null && _recording) {
          setState(() => _recording = false);
        }
      },
    );
    if (!mounted) {
      if (ok) await voice.cancel(); // صفحه بسته شده ولی init موفق شده
      return;
    }
    if (!ok) {
      _snack('سرویس گفتار این دستگاه در دسترس نیست؛ از صفحه‌کلید استفاده کنید');
      return;
    }
    setState(() => _recording = true);
    HapticFeedback.mediumImpact();
    final existing = _inputCtrl.text; // متن تایپ‌شده از بین نرود
    await voice.start(
      onResult: (text) {
        if (!mounted) return;
        _inputCtrl.text = text.isEmpty
            ? existing
            : (existing.isEmpty ? text : '$existing $text');
        _inputCtrl.selection = TextSelection.collapsed(
          offset: _inputCtrl.text.length,
        );
        // اگر موتور خودش ضبط را بسته (سقف زمانی/سکوت) → بنر ضبط بسته شود
        if (_recording && !voice.isListening) {
          setState(() => _recording = false);
        }
        // دکمهٔ ارسال بعد از دیکته فعال شود
        setState(() {});
      },
      onError: (msg) {
        if (!mounted) return;
        if (_recording) setState(() => _recording = false);
        _snack(msg ?? 'تشخیص گفتار ناموفق بود؛ دوباره تلاش کنید');
      },
    );
    // اگر listen بلافاصله شکست خورد (فیلد مشغول و…) → بنر برداشته شود
    if (mounted && !voice.isListening) {
      setState(() => _recording = false);
    }
  }

  Future<void> _stopRecording() async {
    final voice = _voiceService;
    if (!_recording) {
      // موتور ممکن است خودش بسته باشد ولی session نیمه‌کاره مانده باشد
      await voice.cancel();
      return;
    }
    setState(() => _recording = false);
    HapticFeedback.lightImpact();
    await voice.stop(); // نتیجهٔ نهایی از طریق onResult می‌آید
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    FocusScope.of(context).unfocus();
    await ref.read(assistantChatProvider.notifier).send(text);
  }

  void _stop() {
    ref.read(assistantChatProvider.notifier).stop();
  }

  Future<void> _confirmNewChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'چت جدید',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        content: const Text(
          'گفتگوی فعلی پاک شود؟',
          style: TextStyle(color: _textDim, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: _textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('پاک کن', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(assistantChatProvider.notifier).newChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantChatProvider);
    // خطاهای دستیار به‌صورت snackbar نمایش داده می‌شوند (تمیزکاری خودکار توسط Riverpod)
    ref.listen(assistantChatProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        _snack(next.error!);
      }
    });
    final canSend = _inputCtrl.text.trim().isNotEmpty && !state.isStreaming && !_recording;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: _green, size: 22),
            SizedBox(width: 8),
            Text(
              'دستیار',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // چت جدید — گفتگو در صفحه می‌ماند ولی از اینجا می‌توان از نو شروع کرد
          if (state.messages.isNotEmpty || state.streamedText.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.add_comment_rounded,
                color: _textDim,
                size: 22,
              ),
              tooltip: 'چت جدید',
              onPressed: state.isStreaming ? null : _confirmNewChat,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_recording) _recordingBanner(),
          Expanded(child: _chatArea(state)),
          _inputBar(canSend, state.isStreaming),
        ],
      ),
    );
  }

  Widget _recordingBanner() {
    return Container(
      width: double.infinity,
      color: _red.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(vertical: 8),        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, color: _red, size: 16),
            SizedBox(width: 8),
            Text(
              'در حال ضبط... برای پایان، دکمه را رها کنید',
              style: TextStyle(color: _red, fontSize: 12),
            ),
          ],
        ),
    );
  }

  Widget _chatArea(AssistantState state) {
    if (state.messages.isEmpty && state.streamedText.isEmpty) {
      return _emptyState();
    }

    // پیام‌های نمایشی: معکوس برای لیست معکوس (خودکار در پایین می‌ماند)
    final items = <Widget>[];
    for (final m in state.messages.reversed) {
      items.add(_bubble(m));
      items.add(const SizedBox(height: 10));
    }
    if (state.isStreaming ||
        state.streamedText.isNotEmpty ||
        state.status.isNotEmpty) {
      items.insert(0, _streamingBubble(state.streamedText, state.status));
      items.insert(1, const SizedBox(height: 10));
    }

    return ListView(
      reverse: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      children: items,
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: _green,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'از دستیار بپرس',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'مثلاً: «گزارش موجودی امروز انبارها» یا «خلاصهٔ سفارش‌های این هفته»',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textDim, fontSize: 12.5, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(AssistantMessage m) {
    final isUser = m.role == 'user';
    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          const Icon(Icons.smart_toy_rounded, color: _green, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isUser ? _green : _surfaceAlt,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
              border: isUser ? null : Border.all(color: _border),
            ),
            child: isUser
                ? Text(
                    m.content,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: MarkdownBody(
                      data: m.content,
                      styleSheet: MarkdownStyleSheet.fromTheme(_markdownTheme)
                          .copyWith(
                            p: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.6,
                            ),
                            h1: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            h2: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                            tableBorder: const TableBorder(
                              horizontalInside: BorderSide(color: _border),
                              verticalInside: BorderSide(color: _border),
                              top: BorderSide(color: _border),
                              bottom: BorderSide(color: _border),
                              left: BorderSide(color: _border),
                              right: BorderSide(color: _border),
                            ),
                            // جدول‌های پهن فشرده نمی‌شوند — فقط خود جدول به‌صورت افقی
                            // اسکرول می‌شود (flutter_markdown این را خودش اضافه می‌کند)
                            tableColumnWidth: const IntrinsicColumnWidth(),
                            tableScrollbarThumbVisibility: true,
                            tableHead: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            tableBody: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _streamingBubble(String text, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.smart_toy_rounded, color: _green, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _surfaceAlt,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: _green.withValues(alpha: 0.4)),
            ),
            child: text.isEmpty
                ? (status.isEmpty
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _green,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'در حال تحلیل...',
                              style: TextStyle(color: _textDim, fontSize: 12.5),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: _textDim,
                                  fontSize: 12.5,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: _BlinkingCaret(color: _green),
                            ),
                          ],
                        ))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: _BlinkingCaret(color: _green),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _inputBar(bool canSend, bool isStreaming) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(color: _surface),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // میکروفون — نگه‌داشتن = ضبط، رها کردن = تبدیل به متن
            GestureDetector(
              onLongPressStart: isStreaming ? null : (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onLongPressCancel: () => _stopRecording(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _recording
                      ? _red.withValues(alpha: 0.15)
                      : _surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: _recording ? _red : _border),
                ),
                child: Icon(
                  _recording ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _recording ? _red : _textDim,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                enabled: !isStreaming,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isStreaming
                      ? 'در حال دریافت پاسخ...'
                      : 'سوال یا دستور خود را بنویسید...',
                  hintStyle: const TextStyle(color: _textDim, fontSize: 13),
                  filled: true,
                  fillColor: _surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _green),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // دکمه ارسال یا توقف
            isStreaming
                ? _stopButton()
                : Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: canSend ? _green : _surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: canSend ? _send : null,
                      icon: Icon(
                        Icons.send_rounded,
                        color: canSend ? Colors.black : _textDim,
                        size: 20,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _stopButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.4)),
      ),
      child: IconButton(
        onPressed: _stop,
        icon: const Icon(Icons.stop_rounded, color: _red, size: 22),
        tooltip: 'توقف',
      ),
    );
  }
}

/// مکان‌نمای چشمک‌زن انتهای متن در حال تایپ — حس «زنده نوشتن» مدل
class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({required this.color});

  final Color color;

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.15).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: Text(
        '▍',
        style: TextStyle(color: widget.color, fontSize: 13, height: 1.4),
      ),
    );
  }
}
