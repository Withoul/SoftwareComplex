class Question {
  final int id;
  final String enunciado;
  final List<String> opciones;
  final String respuestaCorrecta;

  Question({
    required this.id,
    required this.enunciado,
    required this.opciones,
    required this.respuestaCorrecta,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      enunciado: json['enunciado'] as String,
      opciones: List<String>.from(json['opciones'] as List),
      respuestaCorrecta: json['respuestaCorrecta'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enunciado': enunciado,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
    };
  }
}
