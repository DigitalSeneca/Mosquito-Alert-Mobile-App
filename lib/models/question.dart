
class Question {
  String question_id;
  String question;
  String answer_id;
  String answer;
  String answer_value;

  Question(
      {this.question_id,
      this.question,
      this.answer_id,
      this.answer,
      this.answer_value});

  Question.fromJson(Map<String, dynamic> json) {
    question_id = json['question_id'];
    question = json['question'];
    answer_id = json['answer_id'];
    answer = json['answer'];
    answer_value = json['answer_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_id'] = this.question_id;
    data['question'] = this.question;
    data['answer_id'] = this.answer_id;
    data['answer'] = this.answer;
    data['answer_value'] = this.answer_value;
    return data;
  }
}
