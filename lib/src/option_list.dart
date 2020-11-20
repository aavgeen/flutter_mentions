part of flutter_mentions;

class OptionList extends StatelessWidget {
  OptionList({
    this.data,
    this.onTap,
    this.suggestionListHeight,
    this.suggestionListWidth,
    this.suggestionBuilder,
    this.suggestionListDecoration,
  });

  final Widget Function(Map<String, dynamic>) suggestionBuilder;

  final List<Map<String, dynamic>> data;

  final Function(Map<String, dynamic>) onTap;

  final double suggestionListHeight;

  final double suggestionListWidth;

  final BoxDecoration suggestionListDecoration;

  @override
  Widget build(BuildContext context) {
    final _data = List<Map<String, dynamic>>.from(data);
    _data.removeWhere((element) => element['previous'] ?? false);
    return _data.isNotEmpty
        ? Container(
            decoration:
                suggestionListDecoration ?? BoxDecoration(color: Colors.white),
            constraints: BoxConstraints(
              maxHeight: suggestionListHeight,
              minHeight: 0,
              minWidth: 0,
              maxWidth: suggestionListWidth,
            ),
            child: ListView.builder(
              itemCount: _data.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTap(_data[index]);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: suggestionBuilder != null
                      ? suggestionBuilder(_data[index])
                      : Container(
                          color: Colors.blue,
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            _data[index]['display'],
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                );
              },
            ),
          )
        : Container();
  }
}
