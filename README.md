# Software Complex - Simulador de Exámenes Profesional

**Software Complex** es un simulador interactivo diseñado específicamente para la preparación del **examen complexivo de la carrera de Desarrollo de Software** del **Instituto Universitario Japón**. La aplicación cuenta con un banco de **400 preguntas oficiales** y está desarrollada en **Flutter**.

---

## 🛠️ Ficha Técnica y Tecnologías Utilizadas

La aplicación está construida sobre una arquitectura modular y reactiva, optimizada para rendimiento nativo en dispositivos móviles.

*   **Framework Principal:** [Flutter](https://flutter.dev/) (SDK `>=3.11.5`) con **Dart** como lenguaje de programación.
*   **Gestión de Diseño y Estilos:**
    *   **Paleta de Colores:** Diseñada con tokens personalizados HSL y hexadecimales en `lib/theme/colors.dart` (`#2622BD` como color primario y `#FAC70F` como secundario), logrando una estética visual moderna y limpia.
    *   **Tipografía:** Integración de la fuente **Inter** de Google Fonts para optimizar la legibilidad en textos académicos densos.
    *   **Iconografía:** [Ionicons](https://pub.dev/packages/ionicons) para una interfaz limpia y minimalista.
*   **Persistencia de Datos Local:** [SharedPreferences](https://pub.dev/packages/shared_preferences) configurada como servicio Singleton para el guardado local inmediato de estadísticas de estudio, rachas, imágenes de perfil y el historial detallado de respuestas.
*   **Recordatorios Locales:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) combinado con [timezone](https://pub.dev/packages/timezone) para la programación exacta de alarmas locales en segundo plano sin requerir servidores externos.

---

## 🧠 Lógica y Funcionamiento Interno

### 1. Sistema Inteligente de Notificaciones Diarias
Para maximizar el engagement sin abrumar al estudiante, la aplicación cuenta con un algoritmo de recordatorio inteligente:
*   **Configuración Personalizada:** Desde el botón de campanita del menú principal, el usuario activa/desactiva las alertas y escoge la frecuencia diaria (**de 1 a 5 notificaciones al día**).
*   **Regla de Negocio de Entrada Única:**
    1.  Cuando la app inicia, comprueba la fecha del último ingreso del usuario en el almacén local.
    2.  Si la fecha actual es diferente a la del último ingreso, se registra el día de hoy como "estudiado" y se **cancelan inmediatamente** los recordatorios programados para el resto del día de hoy.
    3.  A continuación, el sistema programa automáticamente un set de notificaciones espaciadas en bloques de tiempo lógicos (por ejemplo, a las 10:00 AM, 2:00 PM y 6:00 PM para una frecuencia de 3 diarias) **exclusivamente a partir del día siguiente y para los próximos 7 días**.
    4.  Esto garantiza que el estudiante **solo recibirá notificaciones los días que no haya abierto la app**.

### 2. Algoritmo del Sistema de Refuerzo (Modo Refuerzo)
El sistema de refuerzo identifica las áreas débiles del estudiante basándose en su historial de respuestas:
*   **Registro Histórico:** Cada vez que el estudiante responde una pregunta en cualquier modo de juego, la aplicación registra el acierto (`true`) o fallo (`false`) en una lista ligada al ID de la pregunta. La app conserva únicamente los **últimos 10 intentos** por pregunta para reflejar el progreso reciente.
*   **Filtrado de Preguntas Críticas:** El **Modo Refuerzo** escanea el historial de las 400 preguntas y extrae aquellas cuya tasa de precisión es **menor al 100%** (es decir, preguntas que han sido contestadas incorrectamente al menos una vez dentro de sus últimos 10 intentos, o preguntas no contestadas aún).
*   **Estudio Focalizado:** El estudiante responde únicamente esta selección depurada de preguntas hasta que logre una racha perfecta en cada una de ellas, promoviendo el aprendizaje adaptativo.

### 3. Base de Datos de Preguntas Estática
La app integra una base de datos local y estática de **400 preguntas académicas** estructuradas en `lib/data/questions.dart`. Cada entrada cuenta con:
*   Un `id` único.
*   Un `enunciado` descriptivo y formal.
*   Una lista de `opciones` de respuesta que se barajan aleatoriamente en tiempo de ejecución.
*   La `respuestaCorrecta` que valida la opción elegida por el usuario.

### 4. Modos de Cuestionario Disponibles
*   **Racha Infinita:** Desafío de supervivencia académica donde respondes preguntas continuas hasta fallar una.
*   **Modo Aleatorio:** Simulacro configurable en número de preguntas que mide la precisión del estudiante y muestra retroalimentación interactiva.
*   **Estudio por Temario:** Permite leer tarjetas conceptuales por bloques temáticos específicos y evaluarse al finalizar.
*   **Cuestionario Fijo:** Estudio secuencial ordenado para un aprendizaje progresivo y lineal.

---

## 📱 Diseño Adaptativo y Usabilidad

*   **Scroll de Tarjetas Interno:** Para evitar truncamientos y desbordamientos en pantallas pequeñas con enunciados extensos (como el caso de la **pregunta 322**), el componente `QuestionCard` (`lib/components/question_card.dart`) encapsula su diseño en un widget `SingleChildScrollView` con física de rebote.
*   **Sin Límites de Texto:** Los textos de las opciones de respuesta no tienen restricción de líneas, lo que permite que las justificaciones extensas se envuelvan y visualicen completamente sin romper la interfaz de usuario.
*   **Estadísticas de Perfil Despejadas:** Cumpliendo los requerimientos de diseño limpio, el perfil de usuario se enfoca puramente en métricas académicas (Aciertos, Errores, Mejor Racha y el Calendario de días de estudio), habiendo removido cualquier control redundante de notificaciones, las cuales se gestionan únicamente desde la campanita del Dashboard.

---

## 🛠️ Instrucciones de Compilación y Ejecución

### Requisitos Previos
*   Flutter SDK instalado y configurado (`flutter doctor` en verde).
*   Un dispositivo físico Android/iOS o emulador activo.

### 1. Obtener Dependencias
Ejecuta en la raíz de `ComplexFlutter`:
```bash
flutter pub get
```

### 2. Generar Recursos Nativos (Iconos de la App)
Para actualizar el launcher icon nativo con el diseño premium `Software logo.png`:
```bash
flutter pub run flutter_launcher_icons
```

### 3. Ejecutar en Modo Desarrollo
```bash
flutter run
```

### 4. Compilar APK de Depuración
Genera el paquete ejecutable `.apk` optimizado:
```bash
flutter build apk --debug
```
El archivo resultante se creará en: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## ⬇️ Descargar

Puedes descargar el archivo APK desde los siguientes enlaces:
*   [Google Drive](https://drive.google.com/file/d/1w3KxjSWFUC1j65G0N-V-N_scAGtDTuaM/view?usp=drive_link)
*   [Mega](https://mega.nz/file/MicXAChK#qpyzqWNpxQQf1dDBsZBqtSJ6-f9wj7wuHpFqKJzrA1U)
*   [MediaFire](https://www.mediafire.com/file/lsmti07qbmk53jl/SoftwareComplex.apk/file)
