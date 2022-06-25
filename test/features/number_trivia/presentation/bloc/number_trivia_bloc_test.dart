import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(
    () {
      mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
      mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
      mockInputConverter = MockInputConverter();

      bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );
    },
  );

  test('initialState should be Empty', () {
    // assert
    expect(bloc.state, Initial());
  });

  group(
    'GetTriviaForConcreteNumber',
    () {
      const tNumberString = '1';
      const tNumberParsed = 1;
      const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

      void setUpMockInputConverterSuccess() =>
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(const Right(tNumberParsed));

      void setUpMockGetConcreteNumberTriviaSuccess() =>
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));

      test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
          // assert
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        },
      );

      test(
        'should emit [ERROR] when the input is invalid',
        () async {
          // arrange
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Left(InvalidInputFailure()));
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
          // assert later
          final expected = [
            const Error(message: INVALID_INPUT_FAILURE_MESSAGE)
          ];
          expectLater(
            bloc.stream,
            emitsInOrder(expected),
          );
        },
      );

      test(
        'should get data from the concrete use case',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockGetConcreteNumberTrivia(any));
          // assert
          verify(
              mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaSuccess();
          // assert later
          final expected = [
            Loading(),
            const Loaded(trivia: tNumberTrivia),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          // assert later
          final expected = [
            Loading(),
            const Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          // assert later
          final expected = [
            Loading(),
            const Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
      );
    },
  );

  group(
    'GetTriviaForRandomNumber',
    () {
      const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

      void setUpMockGetRandomNumberTriviaSuccess() =>
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));

      test(
        'should get data from the random use case',
        () async {
          // arrange
          setUpMockGetRandomNumberTriviaSuccess();
          // act
          bloc.add(GetTriviaForRandomNumber());
          await untilCalled(mockGetRandomNumberTrivia(any));
          // assert
          verify(mockGetRandomNumberTrivia(NoParams()));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
        () async {
          // arrange
          setUpMockGetRandomNumberTriviaSuccess();
          // assert later
          final expected = [
            Loading(),
            const Loaded(trivia: tNumberTrivia),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          // assert later
          final expected = [
            Loading(),
            const Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          // assert later
          final expected = [
            Loading(),
            const Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );
    },
  );
}
