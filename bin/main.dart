library simplechat.bin;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:route/server.dart' show Router;
import 'package:simplechat.common/common.dart';

part 'server.dart';

/**
 * Entry point
 */
main() {
  Server server = new Server(ADDRESS, PORT);
  server.bind();
}