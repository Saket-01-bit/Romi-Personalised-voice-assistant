import 'package:flutter/material.dart';
import 'package:romeo/feature_box.dart';
import 'package:romeo/groq_services.dart';
import 'package:romeo/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  final GroqServices openaiServices = GroqServices();

  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();

    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });

    flutterTts.setCancelHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  Future<void> _stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      await flutterTts.speak(content);
      setState(() => isSpeaking = true);
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Romi"),
        centerTitle: true,
        leading: const Icon(Icons.menu),
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
                    decoration: BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image:
                      AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                  border: Border.all(color: Pallete.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    generatedContent ??
                        'Hello! What can I do for you?',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: generatedContent == null ? 25 : 18,
                    ),
                  ),
                ),
              ),
            ),

            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),

            Visibility(
              visible: generatedContent == null &&
                  generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10, left: 38),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Here are a few agents:',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Visibility(
              visible: generatedContent == null &&
                  generatedImageUrl == null,
              child: Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'Chat',
                    descriptionText:
                    'A smarter way to stay organized and informed.',
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Voice',
                    descriptionText:
                    'Talk naturally with your AI assistant.',
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Romi',
                    descriptionText:
                    'Smart voice assistant powered by Groq.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (isSpeaking) {
            await flutterTts.stop();
            setState(() => isSpeaking = false);
            return;
          }

          if (await speechToText.hasPermission &&
              speechToText.isNotListening) {
            await _startListening();
          } else if (speechToText.isListening) {
            final speech =
            await openaiServices.isArtPrompt(lastWords);

            generatedImageUrl = null;
            generatedContent = speech;
            setState(() {});

            await systemSpeak(speech);
            await _stopListening();
          }
        },
        child: Icon(
          isSpeaking
              ? Icons.volume_off
              : speechToText.isListening
              ? Icons.stop
              : Icons.mic,
        ),
      ),
    );
  }
}
