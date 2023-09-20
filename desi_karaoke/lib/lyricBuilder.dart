import 'dart:collection';
import 'dart:convert';

class Karaoke {
  String title1;
  String title2;
  String music;
  String writer;
  String singer;
  String latintitle1;
  String latintitle2;
  String latinmusic;
  String latinwriter;
  String latinsinger;

  SplayTreeMap timedTextMap = SplayTreeMap<int, KaraokeTimedText>();
  SplayTreeMap countdownTimes = SplayTreeMap<int, String>();
}

class KaraokeTimedText {
  List<KaraokeLine> lines = List<KaraokeLine>();
  LyricHighlightEvent lyricHighlightEvent = LyricHighlightEvent();

  KaraokeTimedText([this.lines, this.lyricHighlightEvent]);
}

class LyricHighlightEvent {
  KaraokeLine line;
  int wordnumber;

  LyricHighlightEvent([this.line, this.wordnumber]);
}

class KaraokeLine {
  int startTime;
  int endTime;
  bool hasCountdown = false;
  List<String> words;
  List<int> durations;
  bool isCountdown;
  int showTime;

  KaraokeLine({int startTime, int endTime}) {
    this.startTime = startTime;
    this.endTime = endTime;
  }

  @override
  String toString() {
    return "Line (show: $showTime, start: $startTime, end: $endTime, "
        "countdown: $hasCountdown, words: $words, times: $durations)";
  }
}

List<KaraokeLine> karaokeLines;
int totalLines;
List<List<KaraokeLine>> interludeGroups;
SplayTreeMap<int, LyricPair> timedLines;

class LyricPair extends Object with IterableMixin<KaraokeLine> {
  KaraokeLine firstLine;
  KaraokeLine secondLine;

  LyricPair([this.firstLine, this.secondLine]);

  @override
  Iterator<KaraokeLine> get iterator => toArray().iterator;

  @override
  toString() => "first: $firstLine, second: $secondLine";

  toArray() => [firstLine, secondLine];
}

Future<Karaoke> buildLyric(String kscFile) async {
  karaokeLines = List();
  interludeGroups = List();
  timedLines = SplayTreeMap();
  final Karaoke karaoke = Karaoke();
  categorize(kscFile, karaoke);
  markCountDownLines();
  addEmptyLinesBeforeCountDown();
  makeCountdownMap(karaoke);
  correctEndTimes();
  removeOverlaps();
  setShowTimes();
  groupInterludes();
  makeTimedLines();
  makeTimedTexts(karaoke);

  return karaoke;
}

makeTimedTexts(Karaoke karaoke) {
  timedLines.forEach((time, pair) {
    karaoke.timedTextMap[time] = KaraokeTimedText(
        pair.toArray(), LyricHighlightEvent(pair.firstLine, -1));
  });

  karaokeLines.forEach((line) {
    int time = timedLines.lastKeyBefore(line.endTime);
    LyricPair pair = timedLines[time];
    var timeShift = line.startTime;
    line.durations?.asMap()?.forEach((wordNum, duration) {
      karaoke.timedTextMap[timeShift] =
          KaraokeTimedText(pair.toArray(), LyricHighlightEvent(line, wordNum));
      timeShift += duration;
    });
  });
}

makeTimedLines() {
  timedLines[0] = LyricPair();
  for (var interlude in interludeGroups) {
    final pair = LyricPair();
    int timeCode;
    final interludeStartsAt = interlude[0].startTime - 5000;
    var interludeEndAt = interludeStartsAt;

    interlude.asMap().forEach((index, line) {
      if (index % 2 == 0) {
        if (pair.firstLine == null) {
          pair.firstLine = line;
          timeCode = interludeStartsAt;
        } else {
          timeCode = pair.firstLine?.endTime;
          pair.firstLine = line;
        }
      } else {
        if (pair.secondLine == null) {
          pair.secondLine = line;
          timeCode = interludeStartsAt;
        } else {
          timeCode = pair.secondLine?.endTime;
          pair.secondLine = line;
        }
      }
      interludeEndAt = line.endTime;
      timedLines[timeCode] = LyricPair(pair.firstLine, pair.secondLine);
    });
    timedLines[interludeEndAt] = LyricPair();
  }
}

groupInterludes() {
  List<KaraokeLine> group = List();
  for (var karaokeLine in karaokeLines) {
    if (karaokeLine.hasCountdown) {
      if (group.isNotEmpty) {
        interludeGroups.add(group);
        group = List();
      }
    }
    group.add(karaokeLine);
  }
  interludeGroups.add(group);
}

setShowTimes() {
  karaokeLines.forEach((it) {
    if (it.hasCountdown) {
      final secAgo = it.startTime - 5000;
      if (secAgo >= 0)
        it.showTime = secAgo;
      else
        it.showTime = 0;
    } else
      it.showTime = it.startTime;
  });
}

removeOverlaps() {
  karaokeLines.asMap().forEach((index, karaokeLine) {
    if (index < totalLines - 1) {
      final nextLine = karaokeLines[index + 1];
      if (nextLine.startTime < karaokeLine.endTime) {
        karaokeLine.endTime = nextLine.startTime;
        print("Overlap Found");
      }
    }
  });
}

correctEndTimes() => karaokeLines.forEach((it) => it.endTime =
    it.startTime + ((it.durations?.fold(0, (a, b) => a + b)) ?? 0));

makeCountdownMap(Karaoke karaoke) {
  for (var line in karaokeLines) {
    if (line.hasCountdown) {
      karaoke.countdownTimes[line.startTime] = "";
      for (var i in [4, 3, 2, 1]) {
        karaoke.countdownTimes[line.startTime - i * 1000] = i.toString();
      }
    }
  }
}

void addEmptyLinesBeforeCountDown() {
  var lines = List<KaraokeLine>();

  karaokeLines.asMap().forEach((lineNumber, line) {
    if (line.hasCountdown && lineNumber != 0) {
      final KaraokeLine prevLine = karaokeLines[lineNumber - 1];
      lines.add(KaraokeLine(
          startTime: prevLine.endTime + 1, endTime: prevLine.endTime + 2));
    }
  });

  karaokeLines.addAll(lines);
  karaokeLines.sort((a, b) {
    return a.startTime.compareTo(b.startTime);
  });
}

void markCountDownLines() {
  var prevTime = 0;
  for (KaraokeLine karaokeLine in karaokeLines) {
    if ((karaokeLine.startTime - 10000) >= prevTime || prevTime == 0) {
      karaokeLine.hasCountdown = true;
    }
    prevTime = karaokeLine.endTime;
  }
}

void categorize(String kscFile, Karaoke karaoke) {
  LineSplitter ls = LineSplitter();
  List lines = ls.convert(kscFile);
  for (String line in lines) {
    if (line.startsWith("karaoke.add")) {
      karaokeLines.add(getEventMap(line));
    }
    if (line.startsWith("karaoke.title1")) {
      karaoke.title1 = getValueString(line);
    } else if (line.startsWith("karaoke.title2")) {
      karaoke.title2 = getValueString(line);
    } else if (line.startsWith("karaoke.music")) {
      karaoke.music = getValueString(line);
    } else if (line.startsWith("karaoke.writer")) {
      karaoke.writer = getValueString(line);
    } else if (line.startsWith("karaoke.singer")) {
      karaoke.singer = getValueString(line);
    } else if (line.startsWith("karaoke.latintitle1")) {
      karaoke.latintitle1 = getValueString(line);
    } else if (line.startsWith("karaoke.latintitle2")) {
      karaoke.latintitle2 = getValueString(line);
    } else if (line.startsWith("karaoke.latinmusic")) {
      karaoke.latinmusic = getValueString(line);
    } else if (line.startsWith("karaoke.latinwriter")) {
      karaoke.latinwriter = getValueString(line);
    } else if (line.startsWith("karaoke.latinsinger")) {
      karaoke.latinsinger = getValueString(line);
    }
  }
  totalLines = karaokeLines.length;
}

KaraokeLine getEventMap(String lineString) {
  final KaraokeLine line = KaraokeLine();
  RegExp timePattern = RegExp("\\d\\d:\\d\\d.\\d\\d\\d");
  if (timePattern.hasMatch(lineString)) {
    Iterable<RegExpMatch> allMatches = timePattern.allMatches(lineString);
    line.startTime = timeCodeToMillis(allMatches.first.group(0));
    line.endTime = timeCodeToMillis(allMatches.last.group(0));
  } else
    print("No Match");
  RegExp wordTimePattern = RegExp("(\\[.*\\])*', '([\\d*,]*)'\\);");
  if (wordTimePattern.hasMatch(lineString)) {
    RegExpMatch match = wordTimePattern.firstMatch(lineString);
    getWordMap(match.group(1), match.group(2), line);
  }
  return line;
}

void getWordMap(String squareWords, String commaMillis, KaraokeLine line) {
  List<String> words = List();
  squareWords.substring(1).split(RegExp("[\\[\\]]+")).forEach((s) {
    var trimmed = s.trim();
    if (trimmed.isNotEmpty) {
      words.add(trimmed);
    }
  });

  List<int> times = List();
  commaMillis.split(RegExp("([,* *]+)+")).forEach((s) {
    times.add(int.parse(s));
  });
  if (words.length == times.length) {
    line.words = words;
    line.durations = times;
  } else
    print("Lists don't match");
}

int timeCodeToMillis(String timeCode) {
  int minute = int.parse(timeCode.substring(0, 2));
  double sec = double.parse(timeCode.substring(3));
  return (minute * 60000 + sec * 1000).toInt();
}

String getValueString(String line) {
  RegExp pattern = RegExp("(?<= = ).*");
  var hasMatch = pattern.hasMatch(line);
  if (hasMatch) {
    return pattern.stringMatch(line).toString();
  } else
    return null;
}
