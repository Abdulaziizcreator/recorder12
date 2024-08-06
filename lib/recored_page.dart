import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'audio_chat_controller.dart';
import 'audio_upload-service.dart';

class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioChatController = Get.put(AudioChatController());
    final audioPostService = AudioPostService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Modern Audio Record"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final message = audioChatController.currentMessage.value;
              if (message == null) {
                return Center(child: Text('No recordings yet.'));
              }

              return Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recorded at: ${message.timestamp}'),
                        Obx(() => IconButton(
                              icon: Icon(message.isPlaying.value
                                  ? Icons.stop
                                  : Icons.play_arrow),
                              onPressed: () {
                                if (message.isPlaying.value) {
                                  audioChatController.stopPlaying(message);
                                } else {
                                  audioChatController.playRecording(message);
                                }
                              },
                            )),
                        IconButton(
                          icon: Icon(Icons.upload_file),
                          onPressed: () {
                            audioPostService.uploadFileToWordpress(
                                file: File(message.filePath),
                                message: {
                                  'text': 'Audio uploaded',
                                  'align': 'left',
                                  'audioUrl': message.filePath
                                });
                          },
                        ),
                      ],
                    ),
                    Obx(() => Slider(
                          value: message.currentPosition.value,
                          min: 0.0,
                          max: message.totalDuration.value,
                          onChanged: (value) {
                            if (value <= message.totalDuration.value &&
                                value >= 0.0) {
                              audioChatController.player
                                  .seek(Duration(seconds: value.toInt()));
                            }
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() =>
                            Text(message.currentPosition.value.toString())),
                        Obx(() => Text(message.totalDuration.value.toString()))
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15)),
                        onPressed: audioChatController.isRecording.value
                            ? null
                            : () => audioChatController.startRecording(),
                        child: Text('Record'),
                      ),
                    ),
                    SizedBox(width: 20),
                    Obx(() => Icon(
                          audioChatController.isRecording.value
                              ? Icons.mic
                              : Icons.mic_none,
                          size: 100,
                          color: audioChatController.isRecording.value
                              ? Colors.red
                              : Colors.blue,
                        )),
                    SizedBox(width: 20),
                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15)),
                          onPressed: audioChatController.isRecording.value
                              ? audioChatController.stopRecording
                              : null,
                          child: Text('Stop'),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
