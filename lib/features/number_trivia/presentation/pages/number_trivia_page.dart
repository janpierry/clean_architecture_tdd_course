import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/widgets/trivia_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: BlocProvider(
        create: (context) {
          return sl<NumberTriviaBloc>();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: mq.size.height / 3,
                    child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                      builder: (context, state) {
                        if (state is Initial) {
                          return const MessageDisplay(
                              message: 'Start searching');
                        }
                        if (state is Loading) {
                          return const LoadingWidget();
                        }
                        if (state is Loaded) {
                          return TriviaDisplay(numberTrivia: state.trivia);
                        }
                        if (state is Error) {
                          return MessageDisplay(message: state.message);
                        }
                        return Container();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bottom half
                  const TriviaControls()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
