import 'package:ai_assistant/chat_box.dart';
import 'package:ai_assistant/openai_service.dart';
import 'package:ai_assistant/pallet.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechToText speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String words = '';
  bool speechEnabled = false;
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
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
      words = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
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
        title: BounceInDown(child: const Text('AI Assistant')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
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
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
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
                    generatedContent == null ? greeting : generatedContent!,
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      fontSize: generatedContent == null ? 25 : 18,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
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
              ),
            ),
            Column(
              children: [
                SlideInLeft(
                  delay: Duration(microseconds: start),
                  child: const ChatBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText:
                        'A mordern way to stay organized and well informed with ChatGPT',
                  ),
                ),
                SlideInLeft(
                  delay: Duration(microseconds: start + delay),
                  child: const ChatBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText:
                        'Be inspired and always stay creative with this app powered by Dall-E',
                  ),
                ),
                SlideInLeft(
                  delay: Duration(microseconds: start + 2 * delay),
                  child: const ChatBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Smart Voice Assistant',
                    descriptionText:
                        'Use only your voice to to control the assistant powered by Dall-E and ChatGPT',
                  ),
                )
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          isShowSendButton = true;
                        });
                      } else {
                        setState(() {
                          isShowSendButton = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Pallete.firstSuggestionBoxColor,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    right: 2,
                    left: 2,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Pallete.secondSuggestionBoxColor,
                    radius: 25,
                    child: GestureDetector(
                      child: Icon(
                        isShowSendButton
                            ? Icons.send
                            : speechToText.isListening
                                ? Icons.stop
                                : Icons.mic,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        if (isShowSendButton) {
                          final speech = await openAIService.isArtPromptAPI(
                            _messageController.text.trim(),
                          );
                          if (speech.contains('https')) {
                            generatedImageUrl = speech;
                            generatedContent = null;
                            setState(() {});
                          } else {
                            generatedImageUrl = null;
                            generatedContent = speech;
                            setState(() {});
                            await systemSpeak(speech);
                          }
                        } else {
                          if (await speechToText.hasPermission &&
                              speechToText.isNotListening) {
                            await startListening();
                          } else if (speechToText.isListening) {
                            final speech =
                                await openAIService.isArtPromptAPI(words);
                            if (speech.contains('https')) {
                              generatedImageUrl = speech;
                              generatedContent = null;
                              setState(() {});
                            } else {
                              generatedImageUrl = null;
                              generatedContent = speech;
                              setState(() {});
                              await systemSpeak(speech);
                            }

                            await stopListening();
                          } else {
                            initializeSpeechToText();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int currentTime() {
    var time = DateTime.now().hour;
    return time;
  }
}
