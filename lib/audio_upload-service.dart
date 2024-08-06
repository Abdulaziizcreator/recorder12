import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AudioPostService {
  Future<void> uploadFileToWordpress({required File file, required Map<String, String> message}) async {
    try {
      FormData data = FormData.fromMap({
        "audio": await MultipartFile.fromFile(file.path, filename: "audio.aac"),
      });
      Logger().e(file.path);

      Dio dio = Dio();
      var response = await dio.post('http://192.168.23.194:8000/main/audio-question/', data: data);
      var textAnswer = response.data['text_answer'];
      var audioAnswer = 'http://192.168.23.194:8000/${response.data['audio_answer']}';

      if (response.statusCode == 201 || response.statusCode == 200) {
        message = {
          'text': textAnswer,
          'align': 'left',
          'audioUrl': audioAnswer,
        };
        print("--------////////////----//////-/-/-/-/-/-/-/-/- $message");
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}
