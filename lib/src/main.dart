part of flutter_mentions;

enum SuggestionPosition { Top, Bottom }

class LengthMap {
  LengthMap({this.start, this.end, this.str});

  String str;
  int start;
  int end;
}

class Annotation {
  Annotation({
    this.style,
    this.id,
    this.display,
    this.trigger,
    this.disableMarkup,
  });

  TextStyle style;
  String id;
  String display;
  String trigger;
  bool disableMarkup;
}

class FlutterMentions extends StatefulWidget {
  FlutterMentions({
    this.mentions,
    this.suggestionPosition = SuggestionPosition.Bottom,
    this.suggestionListHeight = 300.0,
    this.onMarkupChanged,
  });

  final List<Mention> mentions;
  final SuggestionPosition suggestionPosition;
  final double suggestionListHeight;
  final Function(String) onMarkupChanged;

  @override
  _FlutterMentionsState createState() => _FlutterMentionsState();
}

class _FlutterMentionsState extends State<FlutterMentions> {
  AnnotationEditingController _controller;
  final LayerLink layerLink = LayerLink();
  bool showSuggestions = false;
  LengthMap selectedMention;
  String pattern = "";

  @override
  void initState() {
    final Map<String, Annotation> data = Map<String, Annotation>();

    widget.mentions.forEach((element) {
      if (element.matchAll)
        data["${element.trigger}([A-Za-z0-9])*"] = Annotation(
          style: element.style,
          id: null,
          display: null,
          trigger: element.trigger,
          disableMarkup: element.disableMarkup,
        );

      element.data?.forEach(
        (e) => data["${element.trigger}${e['display']}"] = e["style"] != null
            ? Annotation(
                style: e["style"],
                id: e["id"],
                display: e["display"],
                trigger: element.trigger,
                disableMarkup: element.disableMarkup,
              )
            : Annotation(
                style: element.style,
                id: e["id"],
                display: e["display"],
                trigger: element.trigger,
                disableMarkup: element.disableMarkup,
              ),
      );
    });

    _controller = AnnotationEditingController(data);

    _controller.addListener(() {
      final cursorPos = _controller.selection.baseOffset - 1;
      if (cursorPos > 0) {
        int _pos = 0;

        final lengthMap = List<LengthMap>();

        _controller.value.text.split(" ").forEach((element) {
          lengthMap.add(
              LengthMap(str: element, start: _pos, end: _pos + element.length));

          _pos = _pos + element.length + 1;
        });

        final val = lengthMap.indexWhere((element) {
          final newPos = _controller.selection.baseOffset;
          pattern = widget.mentions.map((e) => e.trigger).join("|");

          return element.end == newPos &&
              element.str.toLowerCase().contains(RegExp(pattern));
        });

        setState(() {
          showSuggestions = val != -1;
          selectedMention = val == -1 ? null : lengthMap[val];
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = selectedMention != null
        ? widget.mentions.firstWhere(
            (element) => selectedMention.str.contains(element.trigger))
        : widget.mentions[0];
    return Container(
      child: PortalEntry(
        portalAnchor: widget.suggestionPosition == SuggestionPosition.Bottom
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        childAnchor: widget.suggestionPosition == SuggestionPosition.Bottom
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        portal: showSuggestions
            ? OptionList(
                suggestionListHeight: widget.suggestionListHeight,
                suggestionBuilder: list.suggestionBuilder,
                data: list.data.where((element) {
                  final ele = element["display"].toLowerCase();
                  final str = selectedMention.str
                      .toLowerCase()
                      .replaceAll(RegExp(pattern), "");

                  return ele == str ? false : ele.contains(str);
                }).toList(),
                onTap: (value) {
                  _controller.text = _controller.value.text.replaceRange(
                    selectedMention.start,
                    selectedMention.end,
                    "${list.trigger}$value",
                  );

                  setState(() {
                    showSuggestions = false;
                  });
                },
              )
            : Container(),
        child: TextField(
          maxLines: 5,
          minLines: 1,
          controller: _controller,
          onChanged: (text) {
            print("text: $text");
            if (widget.onMarkupChanged != null)
              widget.onMarkupChanged(_controller.markupText);
          },
        ),
      ),
    );
  }
}