import 'dart:io';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

void main() async {
  final ai = Genkit(plugins: [googleAI()]);

  Future<List<DocumentData>> dummyRetrieve(String query) async {
    final facts = [
      "Dog is man's best friend",
      'Dogs have evolved and were domesticated from wolves',
    ];
    return facts.map((t) => DocumentData(content: [TextPart(text: t)])).toList();
  }

  final qaFlow = ai.defineFlow(
    name: 'qaFlow',
    fn: (query, context) async {
      final factDocs = await dummyRetrieve(query as String);

      final response = await ai.generate(
        model: googleAI.gemini('gemini-2.5-flash'),
        prompt: 'Answer this question with the given context: $query\nContext: ${factDocs.map((d) => d.content.first.text).join('\n')}',
      );
      return response.text ?? '';
    },
  );

  // Define evaluator from docs
  final customEvaluator = ai.defineEvaluator(
    name: 'custom',
    description: 'Custom evaluator',
    fn: (input, context) async {
      return [
        ...input.dataset.map(
          (d) => EvalFnResponse(
            testCaseId: d.testCaseId!,
            evaluation: EvalFnResponseEvaluation.score(
              Score(
                score: ScoreScore.bool(true),
                status: EvalStatusEnum.PASS,
                details: {'reasoning': 'something, something, something....'},
              ),
            ),
          ),
        ),
      ];
    },
  );

  print('Starting Genkit app for evaluation test...');
  print('App is running. Press enter to exit.');
  stdin.readLineSync();
}
