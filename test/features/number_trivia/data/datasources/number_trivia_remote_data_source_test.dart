import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl datasource;
  late MockClient mockHttpClient;

  const tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  setUp(
    () {
      mockHttpClient = MockClient();
      datasource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    },
  );

  group('getConcreteNumberTrivia', () {
    test(
      '''should perform a GET request on a URL with number being the endpoint
       and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        datasource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://numberapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await datasource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = datasource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group(
    'getRandomNumberTrivia',
    () {
      test(
        '''should perform a GET request on a URL with number being the endpoint
       and with application/json header''',
        () {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          datasource.getRandomNumberTrivia();
          // assert
          verify(mockHttpClient.get(
            Uri.parse('http://numberapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ));
        },
      );

      test(
        'should return NumberTrivia when the response code is 200 (success)',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          final result = await datasource.getRandomNumberTrivia();
          // assert
          expect(result, equals(tNumberTriviaModel));
        },
      );

      test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockHttpClientFailure404();
          // act
          final call = datasource.getRandomNumberTrivia;
          // assert
          expect(() => call(), throwsA(isA<ServerException>()));
        },
      );
    },
  );
}
