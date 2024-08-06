import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioMessage {
  final String filePath;
  final DateTime timestamp;
  final RxDouble currentPosition;
  final RxDouble totalDuration;
  final RxBool isPlaying;

  AudioMessage({required this.filePath, required this.timestamp})
      : currentPosition = 0.0.obs,
        totalDuration = 0.0.obs,
        isPlaying = false.obs;
}

class AudioChatController extends GetxController {
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final player = AudioPlayer();
  var currentMessage = Rxn<AudioMessage>();
  var isRecording = false.obs;
  String? recordingFilePath;
  AudioMessage? currentlyPlayingMessage;

  @override
  void onInit() {
    super.onInit();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await recorder.openRecorder();
    await recorder.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  Future<void> startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    recordingFilePath = "${directory.path}/$fileName";

    try {
      await recorder.startRecorder(
        toFile: recordingFilePath,
        codec: Codec.aacADTS,
      );
      isRecording.value = true;
    } catch (e) {
      print('Error starting recorder: ${e.toString()}');
    }
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    isRecording.value = false;

    if (recordingFilePath != null) {
      // Oldingi audio faylni o'chirish
      if (currentMessage.value != null) {
        File(currentMessage.value!.filePath).deleteSync();
      }

      final newMessage = AudioMessage(
        filePath: recordingFilePath!,
        timestamp: DateTime.now(),
      );

      currentMessage.value = newMessage;
    }
  }

  Future<void> playRecording(AudioMessage message) async {
    if (currentlyPlayingMessage != null && currentlyPlayingMessage != message) {
      await stopPlaying(currentlyPlayingMessage!);
    }

    if (message.isPlaying.value) {
      await player.stop();
      message.isPlaying.value = false;
      currentlyPlayingMessage = null;
    } else {
      await player.setFilePath(message.filePath);
      message.totalDuration.value = player.duration?.inSeconds.toDouble() ?? 0;

      player.positionStream.listen((position) {
        message.currentPosition.value = position.inSeconds.toDouble();
      });

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          message.isPlaying.value = false;
          currentlyPlayingMessage = null;
        }
      });

      message.isPlaying.value = true;
      currentlyPlayingMessage = message;
      await player.play();
    }
  }

  Future<void> stopPlaying(AudioMessage message) async {
    await player.stop();
    message.isPlaying.value = false;
    currentlyPlayingMessage = null;
  }
}
