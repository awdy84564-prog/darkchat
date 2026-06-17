import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const CrashSyriaApp());
}

class CrashSyriaApp extends StatelessWidget {
  const CrashSyriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كراش سوريا',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Cairo', // يفضل إضافة خط عربي مناسب
      ),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- شاشة القائمة الرئيسية والمشغل الصوتي لـ نينار ---
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  // رابط البث المباشر المحدث لراديو نينار إف إم
  final String ninarStreamUrl = "https://amgradio.net"; 

  @override
  void initState() {
    super.initState();
    _initRadio();
  }

  Future<void> _initRadio() async {
    try {
      await _audioPlayer.setUrl(ninarStreamUrl);
    } catch (e) {
      debugPrint("خطأ في تحميل بث الراديو: $e");
    }
  }

  void _toggleRadio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        _audioPlayer.play();
      } catch (e) {
        _initRadio().then((_) => _audioPlayer.play());
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // بيانات المراحل والمحافظات
  final List<Map<String, dynamic>> provinces = [
    {
      "name": "دمشق",
      "image": "assets/damascus.jpg", // ضع صور المعالم في مجلد assets
      "levels": [
        {"target": "الجامع الأموي", "letters": ["ا", "ل", "ا", "م", "و", "ي"], "hint": "أبرز معالم دمشق القديمة"},
        {"target": "سوق الحميدية", "letters": ["ا", "ل", "ح", "م", "ي", "د", "ي", "ة"], "hint": "أشهر أسواق الشرق المسقوفة"}
      ]
    },
    {
      "name": "حلب",
      "image": "assets/aleppo.jpg",
      "levels": [
        {"target": "قلعة حلب", "letters": ["ا", "ل", "ق", "ل", "ع", "ة"], "hint": "صرح تاريخي عظيم وسط الشهباء"},
        {"target": "الزعتر", "letters": ["ا", "ل", "ز", "ع", "ت", "ر"], "hint": "منتج تشتهر به حلب"}
      ]
    },
    {
      "name": "لاذقية",
      "image": "assets/latakia.jpg",
      "levels": [
        {"target": "أوغاريت", "letters": ["ا", "و", "غ", "ا", "ر", "ي", "ت"], "hint": "مملكة قديمة قدمت أول أبجدية في التاريخ"}
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كراش سوريا 🇸🇾', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.red[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade100, Colors.white, Colors.green.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // شريط راديو نينار إف إم
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radio, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        isPlaying ? "مباشر: نينار إف إم 🎶" : "راديو نينار إف إم مطفأ",
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    color: isPlaying ? Colors.red : Colors.green,
                    iconSize: 36,
                    onPressed: _toggleRadio,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("اختر المحافظة لتبدأ التحدي:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // قائمة المحافظات
            Expanded(
              child: ListView.builder(
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  final prov = provinces[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(prov["name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text("عدد المراحل: ${prov["levels"].length}"),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LevelSelectorScreen(province: prov),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- شاشة اختيار المرحلة داخل المحافظة ---
class LevelSelectorScreen extends StatelessWidget {
  final Map<String, dynamic> province;
  const LevelSelectorScreen({super.key, required this.province});

  @override
  Widget build(BuildContext context) {
    final List levels = province["levels"];
    return Scaffold(
      appBar: AppBar(
        title: Text("مراحل ${province["name"]}"),
        backgroundColor: Colors.green[800],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GamePlayScreen(
                    provinceName: province["name"],
                    levelData: levels[index],
                    levelNumber: index + 1,
                  ),
                ),
              );
            },
            child: Text(
              "مرحلة $theme${index + 1}",
              style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              textAlign: Alignment.center,
            ),
          );
        },
      ),
    );
  }
}

// --- شاشة اللعب (طريقة كراش زيتونة لتجميع الكلمات) ---
class GamePlayScreen extends StatefulWidget {
  final String provinceName;
  final Map<String, dynamic> levelData;
  final int levelNumber;

  const GamePlayScreen({
    super.key,
    required this.provinceName,
    required this.levelData,
    required this.levelNumber,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  List<String> shuffledLetters = [];
  List<String> currentGuess = [];
  String targetWord = "";
  String hint = "";

  @override
  void initState() {
    super.initState();
    targetWord = widget.levelData["target"].toString().replaceAll(" ", ""); // إزالة الفراغات للمطابقة
    hint = widget.levelData["hint"];
    // خلط الأحرف المتاحة للاعب ليقوم بتركيبها
    shuffledLetters = List<String>.from(widget.levelData["letters"])..shuffle();
  }

  void _selectLetter(String letter, int index) {
    setState(() {
      currentGuess.add(letter);
    });
    _checkWin();
  }

  void _clearGuess() {
    setState(() {
      currentGuess.clear();
    });
  }

  void _checkWin() {
    String guessStr = currentGuess.join("");
    if (guessStr == targetWord) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("أحسنت! إجابة صحيحة 🇸🇾🎉"),
          content: Text("لقد عرفت المعلم: ${widget.levelData["target"]}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الحوار
                Navigator.pop(context); // العودة لاختيار المراحل
              },
              child: const Text("التالي"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.provinceName} - مرحلة ${widget.levelNumber}"),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
