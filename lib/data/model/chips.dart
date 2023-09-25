class ChipsModel {
  bool isSelected;
  final String options;
  final String text;

  ChipsModel(this.isSelected, this.options, this.text);

  Map<String, dynamic> toJson() => {
        'text': text,
        'selected': isSelected,
        'options': options,
      };
}
