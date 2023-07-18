import 'package:flutter_test/flutter_test.dart';
import 'package:ha_assist/hawebsocketapi.dart';

void main() {
  group("websocket tests", () {
    test("ping", () async {
      HAWebsocketAPI haws = HAWebsocketAPI("192.168.20.98", "8123",
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI4ZDcwMTQ5OWI0ZTE0MjRjYTAwMTgyM2M0NzhmYTM4ZSIsImlhdCI6MTY4Nzc0ODkzMCwiZXhwIjoyMDAzMTA4OTMwfQ.DysYrHswdLD9pyR9D1xJzNMY2LXxoyXyf4tgVsKVjE0");
      await haws.ping();
    });
  });
}
