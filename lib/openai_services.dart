import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:romeo/secrets.dart';

class OpenaiServices {
  final List<Map<String,String>> messages=[];

  Future<String> isArtPrompt(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-5.2",
          "messages": [
            {
              'role': 'developer',
              "content": "Does this message want to genenrate AI picture, image, art or anything similar?$prompt . SImply asnwer with yes or no.",
            },
          ],
        }),
      );
      print(res.body);
      if(res.statusCode==200){
        String content =jsonDecode(res.body)['choices'][0]['message']['content'];
        content=content.trim();

        switch(content){
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
          case 'YES':
            final res= await dalleAPI(prompt);
            return res;
          default:
            final res= await ChatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> ChatGPTAPI(String prompt) async {
    messages.add({
      'role':'user',
      'content':prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-5.2",
          "messages": messages
        }),
      );

      if(res.statusCode==200){
        String content =jsonDecode(res.body)['choices'][0]['message']['content'];
        content=content.trim();
        messages.add({
          'role':'assistant',
          'content':content,
        });
        return content;
      }
      return 'An internal error occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dalleAPI(String prompt) async {
    messages.add({
    'role': 'user',
    'content': prompt,
  });
  try {
  final res = await http.post(
  Uri.parse('https://api.openai.com/v1/images/generations'),
  headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $openAIAPIKEY',
  },
  body: jsonEncode({
  'prompt': prompt,
  'n': 1,
  }),
  );

  if (res.statusCode == 200) {
  String imageUrl = jsonDecode(res.body)['data'][0]['url'];
  imageUrl = imageUrl.trim();

  messages.add({
  'role': 'assistant',
  'content': imageUrl,
  });
  return imageUrl;
  }
  return 'An internal error occurred';
  } catch (e) {
  return e.toString();
  }
}
}
