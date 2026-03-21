import 'package:athena_tunes/models/thumbnail.dart';

void main() {
  var urls = [
    'https://yt3.ggpht.com/Vx3WzJ1G7eE9xI6lU4rVqk_tG1t5O_3Yn72Z=w60-h60-l90-rj',
    'https://lh3.googleusercontent.com/xxx=w60-h60-l90-rj',
    'https://yt3.ggpht.com/xxx=s68-c-k-c0x00ffffff-no-rj',
    'https://i.ytimg.com/vi/xyz/hqdefault.jpg'
  ];
  for (var url in urls) {
    print("Original: $url");
    print("ExtraHigh: ${Thumbnail(url).extraHigh}");
  }
}
