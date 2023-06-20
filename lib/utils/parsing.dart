int parseNotificationId(String data) {
  int sum = 0;

  for (int rune in data.runes) {
    sum += rune;
  }

  return sum;
}
