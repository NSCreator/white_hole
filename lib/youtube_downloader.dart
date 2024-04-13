import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class YoutubeDownloader extends StatefulWidget {


  @override
  _YoutubeDownloaderState createState() => _YoutubeDownloaderState();
}

class _YoutubeDownloaderState extends State<YoutubeDownloader> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = "https://youtube.com/shorts/vZFew6e6M1Q?si=HR2akWYTherBKMpD";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Insert the video id or url',
            ),
            TextField(controller: textController),
            ElevatedButton(
              child: const Text('Download'),
              onPressed: () async {
                final yt = YoutubeExplode();
                final id = "vZFew6e6M1Q";
                final video = await yt.videos.get(id);

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                        'Title: ${video.title}, Duration: ${video.duration}',
                      ),
                    );
                  },
                );

                await Permission.storage.request();
                final ffmpeg = FlutterFFmpeg();

                final manifest = await yt.videos.streamsClient.getManifest(id);
                final videoStream = manifest.muxed.bestQuality;
                final audioStream = manifest.audioOnly.last;

                final downloadsDirectory =Directory('/storage/emulated/0/Download');
                final videoFilePath = '${downloadsDirectory!.path}/${video.id}720.${videoStream.container.name}';
                final audioFilePath = '${downloadsDirectory.path}/${video.id}.${audioStream.container.name}';
                final outputFilePath = '${downloadsDirectory.path}/${video.id}1.mp4';

                final dio = Dio();

                await Future.wait([
                  dio.download(videoStream.url.toString(), videoFilePath, onReceiveProgress: (received, total) {
                    if (total != -1) {
                      print("Video: ${(received / total * 100).toStringAsFixed(0)}%");
                    }
                  }),
                  dio.download(audioStream.url.toString(), audioFilePath, onReceiveProgress: (received, total) {
                    if (total != -1) {
                      print("Audio: ${(received / total * 100).toStringAsFixed(0)}%");
                    }
                  }),
                ]);
                // log('combineVideoAndAudio');
                // // this function will combine the video and audio and play the combined video
                // // then we will play the combined video
                //
                // // now we will combine the video and audio using ffmpeg
                //
                //
                //   final String command = '-i ${videoFilePath} -i ${audioFilePath} -c:v copy -c:a aac -strict experimental $outputFilePath';
                //   log("Running the command");
                //   // now we will combine the video and audio
                //   ffmpeg.execute(command).then((result) {
                //     // now we will play the combined video
                //     log("Command done!");
                //
                //   });

                // final arguments = '-i $videoFilePath -i $audioFilePath -c:v copy -c:a aac -strict experimental $outputFilePath';
                // final resultCode = await ffmpeg.execute(arguments);
                //
                // if (resultCode == 0) {
                //   // File(videoFilePath).deleteSync();
                //   // File(audioFilePath).deleteSync();
                //
                //   showDialog(
                //     context: context,
                //     builder: (context) {
                //       return AlertDialog(
                //         content: Text('Download completed and saved to: $outputFilePath'),
                //       );
                //     },
                //   );
                // } else {
                //   showDialog(
                //     context: context,
                //     builder: (context) {
                //       return AlertDialog(
                //         content: Text('Download failed.'),
                //       );
                //     },
                //   );
                // }

              },
            ),
          ],
        ),
      ),
    );
  }
}
