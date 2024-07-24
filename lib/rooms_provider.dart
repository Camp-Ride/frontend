import 'package:campride/room.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomsProvider = StateProvider<List<Room>>((ref) => [
      Room(
        id: 1,
        name: "provider준행님",
        date: "2024-07-25 07:00",
        title: "상록 예비군 출발하실 분 구해요",
        rideType: "왕복",
        departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
        arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
        currentParticipants: 4,
        maxParticipants: 4,
        unreadMessages: 129,
        createdAt: '2024-07-25',
      ),
    ]);
