import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(
    () {
      mockInternetConnectionChecker = MockInternetConnectionChecker();
      networkInfo = NetworkInfoImpl(mockInternetConnectionChecker);
    },
  );

  group('isConnected', () {
    test(
      'should forward the call to InternetConnectionChecker.hasConnection when there is connection',
      () async {
        // arrange
        when(mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) async => true);
        // act
        final result = await networkInfo.isConnected;
        // assert
        verify(mockInternetConnectionChecker.hasConnection);
        expect(result, true);
      },
    );

    test(
      'should forward the call to InternetConnectionChecker.hasConnection when there is not connection',
      () async {
        // arrange
        when(mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) async => false);
        // act
        final result = await networkInfo.isConnected;
        // assert
        verify(mockInternetConnectionChecker.hasConnection);
        expect(result, false);
      },
    );
  });
}
