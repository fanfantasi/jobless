class CompanySizeModel {
  bool isSelected;
  final String text;

  CompanySizeModel(this.isSelected, this.text);

  Map<String, dynamic> toJson() => {
        'isSelected': isSelected,
        'text': text,
      };
}
