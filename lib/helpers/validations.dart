class Validations {
  static bool emailValidation(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  static bool nameValidation(String value) {
    RegExp regex = RegExp('[a-zA-Z]');
    return regex.hasMatch(value);
  }

  static bool isKatakana(String inputString) {
    RegExp katakanaPattern = RegExp(r'^[\u30A0-\u30FFー・\s]+$');
    return katakanaPattern.hasMatch(inputString);
  }


  static bool isValidURL(String url) {
    // Regex pattern to validate URL format
    final RegExp urlRegex = RegExp(
      r'^(?:http|https):\/\/(?:www\.)?[^\s\.]+\.[^\s]{2,}$',
      caseSensitive: false,
      multiLine: false,
    );

    // Check if the URL matches the regex pattern
    return urlRegex.hasMatch(url);
  }
}
