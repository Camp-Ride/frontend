import 'package:campride/Constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final stompClientProvider = Provider<StompClient>((ref) {
  final stompClient = StompClient(
    config: StompConfig.sockJS(
      url: Constants.PROD_WS,
      onConnect: (frame) {
        print('Connected to STOMP server');
      },
      onDisconnect: (frame) {
        print('Disconnected from STOMP server');
      },
      onWebSocketError: (error) => print('WebSocket error: $error'),
      onStompError: (frame) => print('STOMP error: ${frame.body}'),
    ),
  );
  stompClient.activate();
  return stompClient;
});
