import 'package:ai_assistant/chat_box.dart';
import 'package:ai_assistant/openai_service.dart';
import 'package:ai_assistant/pallet.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechToText speechToText = SpeechToText();
  String speech = '';
  bool speechEnabled = false;
  final OpenAIService openAIService = OpenAIService();
  @override
  void initState() {
    super.initState();
    initializeSpeechToText();
  }

  Future<void> initializeSpeechToText() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();

    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      speech = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    var greeting = '';
    if (currentTime() >= 0 && currentTime() < 12) {
      greeting = 'Good Morning, what task can I do for you?';
    }
    if (currentTime() >= 12 && currentTime() <= 7) {
      greeting = 'Good Afternoon, what task can I do for you?';
    } else {
      greeting = 'Good Night, what task can I do for you?';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 164, 208, 215),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 125,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/vAssis.png'),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                top: 30,
              ),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 107, 107, 107),
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  )),
              child: Text(
                greeting,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  fontSize: 25,
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 10,
                left: 21,
              ),
              child: const Text(
                'Here are a few features',
                style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Column(
              children: [
                ChatBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: 'ChatGPT',
                  descriptionText:
                      'A mordern way to stay organized and well informed with ChatGPT',
                ),
                ChatBox(
                  color: Pallete.secondSuggestionBoxColor,
                  headerText: 'Dall-E',
                  descriptionText:
                      'Be inspired and always stay creative with this app powered by Dall-E',
                ),
                ChatBox(
                  color: Pallete.thirdSuggestionBoxColor,
                  headerText: 'Smart Voice Assistant',
                  descriptionText:
                      'Use only your voice to to control the assistant powered by Dall-E and ChatGPT',
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            await openAIService.isArtPromptAPI(speech);
            await stopListening();
          } else {
            initializeSpeechToText();
          }
        },
        child: const Icon(Icons.mic),
      ),
    );
  }

  int currentTime() {
    var time = DateTime.now().hour;
    return time;
  }
}
