int pantalla=0;
int edad,año,mes,dia,hora,minutos,horas_uso,i=0,puntos=0;
String dia_semana,franja,nombre="";
String temporal="",clasificacion="";
String mensajeError = "";
int numeroEscrito = 0;   // número que se va armando dígito por dígito mientras se escribe (sin convertir texto)

int num_dia=1;

String  mensaje_nombre = "Ingresa tu nombre";
String  mensaje_edad = "Ingresa tu edad";
String  mensaje_año = "Ingrese el año";
String  mensaje_mes = "Ingrese el numero del mes";
String  mensaje_dia = "Ingrese el numero del dia";
String  mensaje_dia_semana = "Ingrese el dia de la semana";
String  mensaje_hora = "Ingrese la hora";
String  mensaje_minutos = "Ingrese los minutos";
String  mensaje_franja = "Ingrese la franja horaria AM/PM ";
String  mensaje_horas_uso = "Ingrese la cantidad de horas que utilizará las redes sociales";



int botonSeleccionado = 0;

int campoActivo = 0; // 0 para el primer texto, 1 para el segundo
String primerContenido = "";
String segundoContenido = "";

boolean avanzarPantalla = true;

// Control de opciones del Chatbot gráfico
String respuestaBot = "¡Hola! Selecciona una opción de abajo para conversar.";

int modoPriv = 0;

// Configuración de privacidad (pantalla 17). Empiezan en la opción menos segura
// para que el jugador aprenda a protegerse cambiándolas.
boolean perfilPrivado = false;       // false = público, true = privado
boolean mostrarUbicacion = true;     // true = muestra la ubicación en sus publicaciones
boolean mensajesSoloAmigos = false;  // false = cualquiera le puede escribir
boolean dosPasos = false;            // verificación en dos pasos
String msgPriv = "";
String hora_salida = "Pendiente de calcular";
String hora_entrada = "";

int nivelElegido = 1;
int decisionesCorrectas = 0;
int decisionesIncorrectas = 0;


String mensajeBisiesto = "";

// ======================= VARIABLES NUEVAS (SOLO VISUALES) =======================
PFont fuenteTitulo;      // letra gruesa para títulos
PFont fuenteTexto;       // letra normal
PFont fuenteMono;        // letra tipo "consola"

int feedbackPuntos = 0;      // puntos de la última respuesta (0, 1 o 2)
int feedbackFrame = -1000;   // frame en el que se respondió

boolean manitoActiva = false;  // true si el cursor ya está en forma de mano

// ======================= REGISTRO DIARIO Y ESTADÍSTICAS DE LA SEMANA =======================
// Antes de los días 2 a 7 el jugador ingresa: hora de conexión, minutos, AM/PM,
// horas de uso de ese día y 2 contenidos (pantallas 23 a 27).
int horasTotales = 0;          // suma de las horas de uso de los 7 días
int horasPrimerDia = 0;        // horas de uso del día 1 (para ver si mejoró)

int partidasJugadas = 1;       // contador de partidas (aumenta con "Jugar de nuevo")

// Estadísticas por día
int puntosInicioDia = 0;       // puntos que se llevaban al empezar el día (para sacar los puntos del día)
String ingresoHoy = "";        // hora de ingreso del día actual en los 2 formatos
String salidaHoy = "";         // hora de salida del día actual en los 2 formatos

// Datos básicos de la semana: la semana digital empieza con el ingreso del Día 1
// y termina con la salida del Día 7
String fechaDia1 = "";         // fecha del Día 1
String ingresoDia1 = "";       // hora de ingreso del Día 1 (2 formatos)
String fechaDia7 = "";         // fecha del Día 7
String salidaDia7 = "";        // hora de salida del Día 7 (2 formatos)

// Ranking personal: se conserva entre partidas (no se borra al jugar de nuevo)
int mejorPuntaje = -1;         // menor puntaje de riesgo logrado (-1 = todavía no hay)
int partidaMejor = 0;          // en qué partida se logró
int puntajeAnterior = -1;      // puntaje de la partida anterior (-1 = no hay)
boolean nuevoRecord = false;   // true si esta partida mejoró el récord

PImage fondoEspacio;         // nebulosa fija (azul + magenta + bordes oscuros) en UNA sola imagen
PImage nebulosaViva;         // gas neón animado (cambia de forma en tiempo real)


void setup() {
  fullScreen();
  // Suavizado nivel 2: los bordes se siguen viendo suaves, pero las imágenes del fondo
  // se agrandan con un método más rápido (bilineal). Con el nivel 3 (el normal) cada
  // cuadro tardaba mucho en dibujarse y el juego iba lento.
  smooth(2);

  fuenteTitulo = createFont("SansSerif.bold", 64, true);
  fuenteTexto  = createFont("SansSerif", 32, true);
  fuenteMono   = createFont("Monospaced.bold", 32, true);

  // =====================================================================
  //   NEBULOSA: se calcula UNA sola vez aquí y se guarda como imagen.
  //   Cada punto se pinta con set(x, y, color), función de dibujo de Processing.
  //   Todas las capas fijas se mezclan aquí en UNA imagen sin transparencia (RGB):
  //   pintarla en draw() es muy rápido, por eso el juego corre fluido.
  //   Se genera a 1/3 del tamaño de la pantalla y luego se agranda
  //   (al agrandarla se suaviza, como el gas real).
  // =====================================================================
  int nw = width / 3;
  int nh = height / 3;
  fondoEspacio = createImage(nw, nh, RGB);

  noiseSeed(7);              // misma nebulosa cada vez que se abre el juego
  noiseDetail(6, 0.55);      // 6 capas de ruido = detalle fino tipo humo


  for (int y = 0; y < nh; y++) {
    for (int x = 0; x < nw; x++) {
      float u = x / (float) nw;          // 0 a 1 de izquierda a derecha
      float v = y / (float) nh;          // 0 a 1 de arriba a abajo
      float sx = u * 4.0;
      float sy = v * 4.0 * nh / nw;

      // 1) "Domain warping": el ruido se usa para torcer otro ruido.
      //    Eso crea formas de humo y filamentos en lugar de manchas redondas.
      float qx = noise(sx, sy);
      float qy = noise(sx + 5.2, sy + 1.3);
      float n  = noise(sx + 4.0 * qx, sy + 4.0 * qy);

      // 2) Banda diagonal donde se concentra el gas (como la Vía Láctea)
      float banda = constrain(1.0 - abs(v - (0.1 + 0.75 * u)) * 1.8, 0, 1);

      // 3) Densidad del gas: nubes suaves + filamentos brillantes
      float nube = constrain(map(n, 0.30, 0.75, 0, 1), 0, 1);
      float filamento = pow(1.0 - abs(n * 2.0 - 1.0), 6);
      float dens = (nube * nube * 0.7 + filamento * 0.6 * nube) * (0.2 + 0.8 * banda);

      // 4) Polvo oscuro que tapa partes del gas
      float m = noise(sx * 2.5 + 30, sy * 2.5 + 30 + qx);
      float polvo = constrain(map(m, 0.5, 0.68, 0, 1), 0, 1);
      dens = constrain(dens * (1.0 - 0.8 * polvo), 0, 1);

      // Color neón del gas: violeta profundo -> magenta neón -> núcleo rosado casi blanco
      color cg = lerpColor(color(45, 0, 95), color(255, 30, 200), constrain(dens * 1.7, 0, 1));
      cg = lerpColor(cg, color(255, 205, 250), constrain((dens - 0.5) * 2.0, 0, 1) * 0.75);
      float aGas = constrain(dens * 1.5, 0, 1) * 0.9;            // qué tan opaco es el gas

      // Capa azul: otra forma de gas, más suave, debajo del violeta
      float n2 = noise(sx * 0.8 + 50 + 2.0 * qy, sy * 0.8 + 50 + 2.0 * qx);
      float d2 = constrain(map(n2, 0.33, 0.68, 0, 1), 0, 1);
      d2 = d2 * d2 * (0.3 + 0.7 * banda) * (1.0 - 0.4 * polvo);
      color ca = lerpColor(color(0, 25, 90), color(0, 225, 255), constrain(d2 * 1.4, 0, 1));   // cian neón
      float aAzul = constrain(d2 * 1.5, 0, 1) * 0.78;

      // Viñeta: más oscuro mientras más lejos del centro
      float dc = dist(u, v, 0.5, 0.5) / 0.7071;
      float aVineta = constrain(map(dc, 0.4, 1.0, 0, 0.86), 0, 0.86);

      // Mezcla de capas (de atrás hacia adelante): fondo -> azul -> magenta -> viñeta
      color mezclaFinal = color(3, 4, 14);
      mezclaFinal = lerpColor(mezclaFinal, ca, aAzul);
      mezclaFinal = lerpColor(mezclaFinal, cg, aGas);
      mezclaFinal = lerpColor(mezclaFinal, color(2, 3, 10), aVineta);
      fondoEspacio.set(x, y, mezclaFinal);
    }
  }


  // Se agranda un 8% más que la pantalla para poder moverla sin que se vean los bordes
  fondoEspacio.resize((int) (width * 1.08), (int) (height * 1.08));

  // Capa animada: pequeña (1/12 de la pantalla) para que se pueda recalcular rápido en draw()
  nebulosaViva = createImage(width / 12, height / 12, ARGB);
  File archivoRanking = new File(dataPath("ranking.txt"));
if (archivoRanking.exists()) {
    String[] rank = loadStrings(dataPath("ranking.txt"));
    if (rank.length > 0) {
        String[] partes = split(rank[0], ';');
        if (partes.length == 4) {
            mejorPuntaje = int(partes[0]);
            partidaMejor = int(partes[1]);
            partidasJugadas = int(partes[2]) + 1;
            puntajeAnterior = int(partes[3]);
        }
    }
}
}

void draw() {

  // ---------- Variables de apoyo para dibujar ----------
  boolean manito = false;                 // true si el mouse está sobre algo clickeable
  float px, py, pw, ph;                   // posición y tamaño de un panel
  color pc;                               // color del panel
  float bx, by, bw, bh, btam;             // posición, tamaño y letra de un botón
  color bc;                               // color del botón
  String btxt;                            // texto del botón
  boolean hov;                            // mouse encima del botón

  String cursorTxt;                       // cursor que parpadea al escribir
  if ((frameCount / 30) % 2 == 0) {
      cursorTxt = "_";
  }
  else {
      cursorTxt = " ";
  }

  // Color y tema de cada día
  color cd = color(0, 220, 255);
  String tema = "";
  switch (num_dia) {
    case 1: cd = color(0, 220, 255);   tema = "USO DE REDES"; break;
    case 2: cd = color(255, 140, 40);  tema = "NOTICIAS FALSAS"; break;
    case 3: cd = color(170, 110, 255); tema = "PRIVACIDAD DIGITAL"; break;
    case 4: cd = color(255, 210, 60);  tema = "TIEMPO DE PANTALLA"; break;
    case 5: cd = color(255, 80, 100);  tema = "MENSAJES SOSPECHOSOS"; break;
    case 6: cd = color(0, 220, 130);   tema = "BIENESTAR DIGITAL"; break;
    case 7: cd = color(212, 175, 55);  tema = "EVALUACIÓN FINAL"; break;
  }

  // ==========================================
  // CLASIFICACIÓN SEGÚN EL PUNTAJE DIGITAL (tabla del PDF)
  // Se calcula en cada frame para que el HUD, el chat y el final siempre estén al día.
  // ==========================================
  if (puntos < 5) {
      clasificacion = "Ciudadano Digital Ejemplar";
  }
  else {
      if (puntos <= 13) {
          clasificacion = "Usuario Digital Responsable";
      }
      else {
          if (puntos <= 20) {
              clasificacion = "Usuario en Riesgo";
          }
          else {
              clasificacion = "Dependencia Digital Alta";
          }
      }
  }

  // ==========================================
  // FONDO ESPACIAL (NEBULOSA + ESTRELLAS)
  // ==========================================
  // Tiempo real en segundos: así la nebulosa va a la misma velocidad en cualquier computador
  // (con frameCount, un computador lento la movería más despacio).
  float segundos = millis() / 1000.0;

  // Nebulosa fija: se desliza (no necesita background() porque cubre toda la pantalla)
  float tN = segundos * 0.25;                    // velocidad del deslizamiento (más alto = más rápido)
  float movX = sin(tN) * width * 0.03;
  float movY = cos(tN * 0.7) * height * 0.03;
  // Se dibuja en coordenadas enteras (int): así Processing solo copia la imagen
  // y no tiene que recalcular cada punto, lo que hace el dibujo mucho más rápido.
  image(fondoEspacio, (int) (-width * 0.04 + movX), (int) (-height * 0.04 + movY));

  // Gas neón animado: se recalcula cada 2 frames con ruido que cambia en el tiempo.
  // Es pequeño y al agrandarlo a toda la pantalla queda suave, como un brillo neón.
  if (frameCount % 2 == 0 || frameCount < 3) {
    int vw = nebulosaViva.width;
    int vh = nebulosaViva.height;
    float tV = segundos * 0.35;                    // velocidad con que el gas cambia de forma (más alto = más rápido)
    float flujo = segundos * 0.25;                 // velocidad con que el gas viaja por la pantalla (más alto = más rápido)
    noiseDetail(3, 0.5);                           // 3 capas de ruido: suficiente porque se ve difuminado
    for (int y = 0; y < vh; y++) {
      for (int x = 0; x < vw; x++) {
        float u = x / (float) vw;
        float v = y / (float) vh;
        // + flujo: el gas se desplaza continuamente de derecha a izquierda
        float sx = u * 3.0 + flujo;
        float sy = v * 3.0 * vh / vw + flujo * 0.3;
        // domain warping con tiempo: el gas se retuerce y fluye
        float qx = noise(sx, sy, tV);
        float qy = noise(sx + 5.2, sy + 1.3, tV * 1.3);
        float n  = noise(sx + 3.0 * qx, sy + 3.0 * qy, tV * 0.5 + 10);
        float banda = constrain(1.0 - abs(v - (0.1 + 0.75 * u)) * 1.6, 0, 1);
        float dens = constrain(map(n, 0.38, 0.68, 0, 1), 0, 1);
        dens = dens * dens * (0.2 + 0.8 * banda);
        // el color también se mueve: magenta neón <-> violeta eléctrico <-> cian neón
        float mezcla = constrain(map(noise(sx * 0.6 + 20, sy * 0.6 + 20, tV * 0.3), 0.35, 0.65, 0, 1), 0, 1);
        color cv = lerpColor(color(255, 30, 190), color(0, 220, 255), mezcla);
        cv = lerpColor(cv, color(150, 70, 255), (1.0 - abs(mezcla - 0.5) * 2.0) * 0.6);
        nebulosaViva.set(x, y, color(red(cv), green(cv), blue(cv), constrain(dens * 1.4, 0, 1) * 225));
      }
    }
  }
  image(nebulosaViva, 0, 0, width, height);

  // Estrellas: las cercanas son más grandes, brillantes y se mueven más rápido (profundidad)
  randomSeed(2026);   // misma semilla cada frame: las estrellas no "saltan"
  noStroke();
  for (int k = 0; k < 160; k++) {
    float prof = random(1);                                   // 0 = lejos, 1 = cerca
    float sx = random(width) - frameCount * (0.03 + prof * 0.25);
    sx = ((sx % width) + width) % width;                      // al salir por la izquierda entra por la derecha
    float sy = random(height);
    float tam = 0.6 + prof * 2.0;
    float vel = random(0.02, 0.08);
    float tipo = random(1);
    float brillo = (90 + prof * 165) * (0.7 + 0.3 * sin(frameCount * vel + k));
    if (tipo < 0.15) {
        fill(255, 220, 180, brillo);          // estrella cálida
    }
    else {
        if (tipo < 0.35) {
            fill(180, 210, 255, brillo);      // estrella azulada
        }
        else {
            fill(255, brillo);                // estrella blanca
        }
    }
    ellipse(sx, sy, tam, tam);
  }

  // Estrellas brillantes con halo y destello en cruz (como en fotos de telescopio)
  for (int k = 0; k < 5; k++) {
    float ex = 0;
    float ey = 0;
    float tamE = 1;
    color ce = color(255);
    switch (k) {
      case 0: ex = width * 0.18; ey = height * 0.28; tamE = 1.0; ce = color(200, 220, 255); break;
      case 1: ex = width * 0.74; ey = height * 0.20; tamE = 1.3; ce = color(255, 255, 255); break;
      case 2: ex = width * 0.88; ey = height * 0.70; tamE = 0.9; ce = color(255, 190, 240); break;
      case 3: ex = width * 0.33; ey = height * 0.84; tamE = 0.8; ce = color(255, 225, 190); break;
      case 4: ex = width * 0.55; ey = height * 0.48; tamE = 0.7; ce = color(170, 230, 255); break;
    }
    float pulsoE = 0.75 + 0.25 * sin(frameCount * 0.03 + k * 1.7);
    noStroke();
    fill(ce, 18 * pulsoE);
    ellipse(ex, ey, 60 * tamE, 60 * tamE);
    fill(ce, 45 * pulsoE);
    ellipse(ex, ey, 22 * tamE, 22 * tamE);
    fill(255, 240 * pulsoE);
    ellipse(ex, ey, 4 * tamE, 4 * tamE);
    float largo = 38 * tamE * pulsoE;
    strokeWeight(1.2);
    stroke(ce, 150 * pulsoE);
    line(ex - largo, ey, ex + largo, ey);
    line(ex, ey - largo, ex, ey + largo);
    stroke(ce, 60 * pulsoE);
    line(ex - largo * 0.4, ey - largo * 0.4, ex + largo * 0.4, ey + largo * 0.4);
    line(ex - largo * 0.4, ey + largo * 0.4, ex + largo * 0.4, ey - largo * 0.4);
    strokeWeight(1);
    noStroke();
  }


  // ==========================================
  // PISO NEÓN (inicio, registro y final)
  // ==========================================
  if (pantalla <= 12 || pantalla >= 19) {
    float horizonte = height * 0.78;
    noStroke();
    for (int k = 1; k <= 6; k++) {
      fill(255, 0, 180, 9);
      rect(0, horizonte - k * 10, width, k * 10);
    }
    float avance = (frameCount * 0.02) % 1.0;
    for (int k = 0; k < 12; k++) {
      float t = (k + avance) / 12.0;
      float y = horizonte + (height - horizonte) * t * t;
      stroke(255, 0, 200, 40 + 140 * t);
      line(0, y, width, y);
    }
    for (int k = -14; k <= 14; k++) {
      stroke(0, 220, 255, 70);
      line(width / 2 + k * 25, horizonte, width / 2 + k * 260, height);
    }
    stroke(255, 0, 200, 200);
    strokeWeight(2);
    line(0, horizonte, width, horizonte);
    strokeWeight(1);
    noStroke();
  }

  // ==========================================
  // MENÚ LATERAL (pantallas 13 a 18)
  // ==========================================
  if (pantalla >= 13 && pantalla <= 18) {
    noStroke();
    fill(10, 14, 32, 238);
    rect(0, 0, 220, height);
    stroke(0, 220, 255, 120);
    line(220, 0, 220, height);
    noStroke();

    textFont(fuenteTitulo);
    textAlign(CENTER, CENTER);
    fill(0, 220, 255);
    textSize(24);
    text("MI DÍA", 110, 42);
    fill(255, 0, 200);
    textSize(15);
    text("D I G I T A L", 110, 70);

    // Los 6 botones: y = 100, 160, 220, 280, 340, 400 (igual que en mousePressed)
    for (int k = 1; k <= 6; k++) {
      float my = 40 + k * 60;
      String mt = "";
      color mc = color(255);
      switch (k) {
        case 1: mt = "Publicaciones"; mc = color(0, 220, 130);  break;
        case 2: mt = "Ver videos";    mc = color(255, 70, 90);  break;
        case 3: mt = "Chatear";       mc = color(0, 170, 255);  break;
        case 4: mt = "Privacidad";    mc = color(180, 100, 255); break;
        case 5: mt = "Mi estado";     mc = color(255, 200, 60); break;
        case 6: mt = "Salir";         mc = color(255, 80, 80);  break;
      }
      boolean activo = (botonSeleccionado == k);
      hov = mouseX >= 15 && mouseX <= 205 && mouseY >= my && mouseY <= my + 45;
      if (hov) {
          manito = true;
      }

      noStroke();
      if (activo) {
          fill(mc, 40);
          rect(10, my - 5, 200, 55, 12);
          fill(lerpColor(color(28, 34, 58), mc, 0.45));
      }
      else {
          if (hov) {
              fill(42, 50, 80);
          }
          else {
              fill(28, 34, 58);
          }
      }
      if (activo || hov) {
          stroke(mc);
      }
      else {
          stroke(mc, 90);
      }
      rect(15, my, 190, 45, 10);
      noStroke();

      fill(mc);
      ellipse(42, my + 22.5, 26, 26);
      fill(10, 14, 32);
      textFont(fuenteTitulo);
      textSize(14);
      textAlign(CENTER, CENTER);
      text(k, 42, my + 21);

      fill(255);
      textFont(fuenteTexto);
      textSize(16);
      textAlign(LEFT, CENTER);
      text(mt, 66, my + 21);
    }

    textFont(fuenteMono);
    textSize(12);
    fill(110, 120, 150);
    textAlign(CENTER, CENTER);
    text("FERIA GAMER 2026", 110, height - 30);
  }

  // ==========================================
  // PANEL DE FONDO + BOTÓN VOLVER (pantallas 14 a 18)
  // ==========================================
  if (pantalla >= 14 && pantalla <= 18) {
    pc = color(0, 220, 130);
    switch (pantalla) {
      case 14: pc = color(0, 220, 130);  break;
      case 15: pc = color(255, 60, 80);  break;
      case 16: pc = color(0, 170, 255);  break;
      case 17: pc = color(180, 100, 255); break;
      case 18: pc = color(255, 200, 60); break;
    }
    px = 240; py = 20; pw = width - 260; ph = height - 40;
    noStroke();
    fill(pc, 16);
    rect(px - 6, py - 6, pw + 12, ph + 12, 20);
    fill(12, 16, 36, 228);
    stroke(pc, 140);
    strokeWeight(1.5);
    rect(px, py, pw, ph, 16);
    stroke(pc);
    strokeWeight(3);
    for (int e = 0; e < 4; e++) {               // esquinas tipo videojuego
      float ex = px + 8;
      float dx = 1;
      if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
      float ey = py + 8;
      float dy = 1;
      if (e >= 2) { ey = py + ph - 8; dy = -1; }
      line(ex, ey, ex + 22 * dx, ey);
      line(ex, ey, ex, ey + 22 * dy);
    }
    strokeWeight(1);
    noStroke();

    // Botón VOLVER (misma posición que detecta mousePressed)
    bx = width - 300; by = height - 200; bw = 150; bh = 50;
    bc = color(0, 220, 255); btxt = "VOLVER"; btam = 18;
    hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
    if (hov) {
        manito = true;
        noStroke();
        for (int g = 3; g >= 1; g--) {
            fill(bc, 22);
            rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
        }
        fill(lerpColor(color(28, 34, 58), bc, 0.40));
        stroke(bc);
    }
    else {
        fill(28, 34, 58, 235);
        stroke(bc, 150);
    }
    strokeWeight(2);
    rect(bx, by, bw, bh, 10);
    strokeWeight(1);
    noStroke();
    fill(255, 18);
    rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
    fill(255);
    textFont(fuenteTitulo);
    textSize(btam);
    textAlign(CENTER, CENTER);
    text(btxt, bx + bw / 2, by + bh / 2 - 2);
  }

  textFont(fuenteTexto);
  textSize(20);
  fill(255);

  switch(pantalla){

    // =================================================================
    //                    PANTALLA 0: BIENVENIDA
    // =================================================================
    case 0: {
      float bob = sin(frameCount * 0.04) * 6;

      textFont(fuenteTexto);
      textSize(22);
      fill(0, 220, 255);
      textAlign(CENTER, CENTER);
      text("B I E N V E N I D O   A", width / 2, height * 0.11 + bob);

      // Título neón
      String tt = "MI DÍA DIGITAL";
      float tx = width / 2;
      float ty = height * 0.19 + bob;
      color tc = color(255, 0, 200);
      textFont(fuenteTitulo);
      textSize(76);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      String texto1 = "El jugador representa a un estudiante de Ciudad Digital que utiliza las redes sociales durante un día.\n\n"
                    + "Durante su sesión digital encontrará publicaciones, videos, mensajes y diferentes tipos de contenido. "
                    + "Cada decisión sobre lo que consume, revisa o comparte tendrá consecuencias positivas o negativas en su Puntaje Digital.\n\n"
                    + "Al finalizar, el sistema analizará el tiempo de uso, el horario de conexión, el contenido consumido "
                    + "y las decisiones tomadas para entregar un diagnóstico final.";

      // Panel
      pc = color(0, 220, 255);
      pw = min(1000, width - 120); px = (width - pw) / 2; py = height * 0.29; ph = 320;
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      textFont(fuenteTexto);
      textSize(20);
      fill(225, 230, 245);
      textAlign(CENTER, TOP);
      text(texto1, px + 50, py + 40, pw - 100, 260);
      break;
    }

    // =================================================================
    //                    PANTALLA 1: TEMÁTICA
    // =================================================================
    case 1: {
      textFont(fuenteTexto);
      textSize(20);
      fill(255, 140, 40);
      textAlign(CENTER, CENTER);
      text("T E M Á T I C A   D E   L A   M I S I Ó N", width / 2, height * 0.11);

      String tt = "CAZADOR DE NOTICIAS FALSAS";
      float tx = width / 2;
      float ty = height * 0.19;
      color tc = color(255, 140, 40);
      textFont(fuenteTitulo);
      textSize(58);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      String texto2 = "En esta misión, el jugador debe identificar noticias verdaderas, falsas o engañosas antes de compartirlas.\n\n"
                    + "Deberá revisar la fuente, la fecha y la información de cada publicación antes de creerla o difundirla.\n\n"
                    + "Verificar información ayuda a proteger a otras personas de la desinformación. "
                    + "Compartir contenido sin verificar aumenta el riesgo digital.";

      pc = color(255, 140, 40);
      pw = min(1000, width - 120); px = (width - pw) / 2; py = height * 0.29; ph = 330;
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      textFont(fuenteTexto);
      textSize(20);
      fill(225, 230, 245);
      textAlign(CENTER, TOP);
      text(texto2, px + 50, py + 35, pw - 100, 200);

      fill(255, 140, 40, 35);
      noStroke();
      rect(px + 50, py + 225, pw - 100, 50, 10);
      textFont(fuenteTitulo);
      textSize(17);
      fill(255, 190, 120);
      textAlign(CENTER, CENTER);
      text("OBJETIVO: promover el pensamiento crítico y el consumo responsable de información.", px + pw / 2, py + 250);

      textFont(fuenteTexto);
      textSize(18);
      fill(212, 175, 55);
      text("Tus decisiones digitales construyen tu futuro.", px + pw / 2, py + 300);
      break;
    }

    // =================================================================
    //     PANTALLAS 2 A 11: REGISTRO DEL JUGADOR (una sola vez)
    //     PANTALLAS 23 A 26: REGISTRO DIARIO (antes de los días 2 a 7)
    // =================================================================
    case 2: case 3: case 4: case 5: case 6:
    case 7: case 8: case 9: case 10: case 11:
    case 23: case 24: case 25: case 26: {
      int paso;
      int totalPasos;
      if (pantalla <= 11) {
          paso = pantalla - 1;          // registro inicial: 10 pasos
          totalPasos = 10;
      }
      else {
          paso = pantalla - 22;         // registro diario: 5 pasos (el quinto son los contenidos)
          totalPasos = 5;
      }
      String pregunta = "";
      String ayuda = "";
      switch (pantalla) {
        case 2:  pregunta = mensaje_nombre;     ayuda = "Solo letras, mínimo 2."; break;
        case 3:  pregunta = mensaje_edad;       ayuda = "Número entre 1 y 120."; break;
        case 4:  pregunta = mensaje_año;        ayuda = "Número entre 1900 y 2100."; break;
        case 5:  pregunta = mensaje_mes;        ayuda = "Número entre 1 y 12."; break;
        case 6:  pregunta = mensaje_dia;        ayuda = "Depende del mes (28, 29, 30 o 31 días)."; break;
        case 7:  pregunta = mensaje_dia_semana; ayuda = "Escribe: lunes, martes, miércoles, jueves, viernes, sábado o domingo."; break;
        case 8:  pregunta = mensaje_hora;       ayuda = "Formato de 12 horas: 1 a 12."; break;
        case 9:  pregunta = mensaje_minutos;    ayuda = "Número entre 0 y 59."; break;
        case 10: pregunta = mensaje_franja;     ayuda = "Haz clic en AM o en PM."; break;
        case 11: pregunta = mensaje_horas_uso;  ayuda = ""; break;      // la ayuda se calcula abajo
        case 23: pregunta = "¿A qué hora te conectaste hoy a las redes sociales?"; ayuda = "Formato de 12 horas: 1 a 12."; break;
        case 24: pregunta = "¿En qué minuto te conectaste?";                      ayuda = "Número entre 0 y 59."; break;
        case 25: pregunta = "¿Fue en la mañana (AM) o en la tarde/noche (PM)?";   ayuda = "Haz clic en AM o en PM."; break;
        case 26: pregunta = "¿Cuántas horas usarás hoy las redes sociales?"; ayuda = ""; break;
      }

      // Ayuda de las horas de uso: el máximo depende de la hora de ingreso,
      // porque la salida no puede pasar de las 11:59 PM (el juego va día por día).
      if (pantalla == 11 || pantalla == 26) {
          int hEntAyuda = hora % 12;
          if (franja != null && franja.equals("PM")) {
              hEntAyuda = hEntAyuda + 12;
          }
          if (23 - hEntAyuda == 1) {
              ayuda = "Máximo 1 hora: la salida no puede pasar de las 11:59 PM.";
          }
          else {
              ayuda = "Máximo " + (23 - hEntAyuda) + " horas: la salida no puede pasar de las 11:59 PM.";
          }
      }

      pc = color(0, 220, 255);
      pw = min(1000, width - 120); px = (width - pw) / 2; py = height * 0.18; ph = 380;

      // Título neón
      String tt;
      if (pantalla <= 11) {
          tt = "CREA TU JUGADOR";
      }
      else {
          tt = "PREPARA EL DÍA " + num_dia;
      }
      float tx = width / 2;
      float ty = py - 55;
      color tc = color(255, 0, 200);
      textFont(fuenteTitulo);
      textSize(44);
      textAlign(CENTER, CENTER);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      // Panel
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      // Paso y barra de progreso
      textFont(fuenteMono);
      textSize(16);
      fill(150, 160, 185);
      textAlign(LEFT, CENTER);
      text("PASO " + paso + " DE " + totalPasos, px + 50, py + 42);

      float sw = (pw - 100 - (totalPasos - 1) * 6) / (float) totalPasos;
      noStroke();
      for (int k = 0; k < totalPasos; k++) {
          if (k < paso) {
              fill(pc);
          }
          else {
              fill(255, 30);
          }
          rect(px + 50 + k * (sw + 6), py + 62, sw, 8, 4);
      }

      // Insignia de año bisiesto
      if (!mensajeBisiesto.equals("") && pantalla >= 5) {
          textFont(fuenteTitulo);
          textSize(15);
          float anchoB = textWidth(mensajeBisiesto) + 30;
          fill(212, 175, 55, 50);
          stroke(212, 175, 55);
          rect(px + pw - 50 - anchoB, py + 28, anchoB, 28, 14);
          noStroke();
          fill(255, 225, 140);
          textAlign(CENTER, CENTER);
          text(mensajeBisiesto, px + pw - 50 - anchoB / 2, py + 41);
      }

      // Fecha del día (solo en el registro diario): se calcula sola sumando un día
      if (pantalla >= 23) {
          String txtDiaF = "" + dia;
          if (dia < 10) {
              txtDiaF = "0" + dia;
          }
          String txtMesF = "" + mes;
          if (mes < 10) {
              txtMesF = "0" + mes;
          }
          String fechaDia = dia_semana + "  " + txtDiaF + "/" + txtMesF + "/" + año;
          textFont(fuenteTitulo);
          textSize(15);
          float anchoF = textWidth(fechaDia) + 30;
          fill(0, 220, 255, 40);
          stroke(0, 220, 255);
          rect(px + pw - 50 - anchoF, py + 28, anchoF, 28, 14);
          noStroke();
          fill(200, 245, 255);
          textAlign(CENTER, CENTER);
          text(fechaDia, px + pw - 50 - anchoF / 2, py + 41);
      }

      // Pregunta
      textFont(fuenteTitulo);
      textSize(28);
      fill(255);
      textAlign(LEFT, TOP);
      text(pregunta, px + 50, py + 95, pw - 100, 80);

      float cy = py + 185;

      if (pantalla == 10 || pantalla == 25) {
          // Franja horaria: 2 botones, AM y PM (mismas medidas que en mousePressed)
          for (int k = 0; k < 2; k++) {
            bw = 220; bh = 70; by = cy - 3; bc = pc; btam = 30;
            if (k == 0) {
                bx = px + pw / 2 - 240; btxt = "AM";
            }
            else {
                bx = px + pw / 2 + 20; btxt = "PM";
            }
            hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
            if (hov) {
                manito = true;
                noStroke();
                for (int g = 3; g >= 1; g--) {
                    fill(bc, 22);
                    rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
                }
                fill(lerpColor(color(28, 34, 58), bc, 0.40));
                stroke(bc);
            }
            else {
                fill(28, 34, 58, 235);
                stroke(bc, 150);
            }
            strokeWeight(2);
            rect(bx, by, bw, bh, 10);
            strokeWeight(1);
            noStroke();
            fill(255, 18);
            rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
            fill(255);
            textFont(fuenteTitulo);
            textSize(btam);
            textAlign(CENTER, CENTER);
            text(btxt, bx + bw / 2, by + bh / 2 - 2);
          }

          // Ayuda
          textFont(fuenteTexto);
          textSize(16);
          fill(150, 160, 185);
          textAlign(LEFT, CENTER);
          text(ayuda, px + 50, cy + 92);
      }
      else {
          // Caja de texto
          fill(5, 8, 22, 230);
          stroke(pc);
          strokeWeight(2);
          rect(px + 50, cy, pw - 100, 64, 12);
          strokeWeight(1);
          noStroke();
          textFont(fuenteMono);
          textSize(30);
          fill(0, 255, 128);
          textAlign(LEFT, CENTER);
          text(temporal + cursorTxt, px + 75, cy + 31);

          // Ayuda
          textFont(fuenteTexto);
          textSize(16);
          fill(150, 160, 185);
          textAlign(LEFT, CENTER);
          text(ayuda, px + 50, cy + 92);
          textAlign(RIGHT, CENTER);
          text("ENTER para continuar", px + pw - 50, cy + 92);
      }

      // Error
      if (!mensajeError.equals("")) {
          fill(255, 70, 90, 40);
          rect(px + 50, cy + 112, pw - 100, 40, 8);
          fill(255, 70, 90);
          triangle(px + 72, cy + 122, px + 62, cy + 142, px + 82, cy + 142);
          fill(255, 120, 130);
          textFont(fuenteTitulo);
          textSize(17);
          textAlign(LEFT, CENTER);
          text(mensajeError, px + 95, cy + 132);
      }
      break;
    }

    // =================================================================
    //             PANTALLA 12: CONTENIDOS QUE CONSUME
    // =================================================================
    case 12: case 27: {
      String tt;
      if (pantalla == 12) {
          tt = "¿QUÉ CONTENIDO CONSUMES?";
      }
      else {
          tt = "¿QUÉ CONTENIDO CONSUMES HOY?";
      }
      float tx = width / 2;
      float ty = 70;
      color tc = color(0, 220, 130);
      textFont(fuenteTitulo);
      textSize(46);
      textAlign(CENTER, CENTER);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      // Instrucción
      textFont(fuenteTexto);
      textSize(21);
      fill(200, 210, 230);
      textAlign(CENTER, CENTER);
      if (pantalla == 12) {
          text("Haz clic sobre uno de los botones para elegir el contenido que consumes", width / 2, 118);
      }
      else {
          text("Día " + num_dia + "  -  Paso 5 de 5  -  Haz clic sobre uno de los botones", width / 2, 118);
      }

      // Panel central (mismas medidas que en mousePressed)
      pc = color(0, 220, 255);
      pw = min(760, width - 120); px = (width - pw) / 2; py = 150; ph = 85 + 7 * 58 + 20;
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      // Encabezado del panel: cuál elección va
      textFont(fuenteTitulo);
      textSize(19);
      fill(0, 220, 255);
      textAlign(LEFT, CENTER);
      text("CATÁLOGO DE CONTENIDO", px + 40, py + 42);
      textAlign(RIGHT, CENTER);
      fill(0, 255, 128, 170 + sin(frameCount * 0.12) * 85);
      if (campoActivo == 0) {
          text("Elige el primero  (1 de 2)", px + pw - 40, py + 42);
      }
      else {
          text("Elige el segundo  (2 de 2)", px + pw - 40, py + 42);
      }

      // 7 botones de contenido
      float iw = pw - 80;
      float ix = px + 40;
      for (int k = 0; k < 7; k++) {
        String item = "";
        switch (k) {
          case 0: item = "contenido educativo"; break;
          case 1: item = "noticias verificadas"; break;
          case 2: item = "contenido cultural"; break;
          case 3: item = "entretenimiento"; break;
          case 4: item = "noticias falsas"; break;
          case 5: item = "contenido violento"; break;
          case 6: item = "informacion engañosa"; break;
        }
        float iy = py + 85 + k * 58;           // mismas medidas que en mousePressed
        boolean elegido = item.equals(primerContenido);
        hov = !elegido && mouseX >= ix && mouseX <= ix + iw && mouseY >= iy && mouseY <= iy + 48;

        if (elegido) {
            // Ya elegido: queda desactivado (no se puede volver a seleccionar)
            fill(0, 220, 130, 30);
            stroke(0, 220, 130, 120);
        }
        else {
            if (hov) {
                manito = true;
                noStroke();
                fill(0, 220, 255, 30);
                rect(ix - 6, iy - 6, iw + 12, 60, 16);
                fill(lerpColor(color(28, 34, 58), color(0, 220, 255), 0.35));
                stroke(0, 220, 255);
            }
            else {
                fill(28, 34, 58, 235);
                stroke(0, 220, 255, 110);
            }
        }
        strokeWeight(2);
        rect(ix, iy, iw, 48, 12);
        strokeWeight(1);
        noStroke();

        if (elegido) {
            // ícono de check
            fill(0, 220, 130);
            ellipse(ix + 28, iy + 24, 26, 26);
            stroke(10, 14, 32);
            strokeWeight(3);
            line(ix + 22, iy + 24, ix + 26, iy + 29);
            line(ix + 26, iy + 29, ix + 34, iy + 19);
            strokeWeight(1);
            noStroke();
            // etiqueta ELEGIDO
            textFont(fuenteTitulo);
            textSize(14);
            fill(0, 220, 130);
            textAlign(RIGHT, CENTER);
            text("ELEGIDO", ix + iw - 20, iy + 23);
        }
        else {
            fill(0, 220, 255);
            ellipse(ix + 28, iy + 24, 10, 10);
        }
        textFont(fuenteMono);
        textSize(22);
        if (elegido) {
            fill(140, 150, 175);
        }
        else {
            fill(255);
        }
        textAlign(LEFT, CENTER);
        text(item, ix + 55, iy + 23);
      }
      break;
    }

    // =================================================================
    //                PANTALLA 13: EL JUEGO (HUD + SITUACIÓN)
    // =================================================================
    case 13: {

      // ---------------- BARRA SUPERIOR (HUD) ----------------
      pc = cd;
      px = 240; py = 15; pw = width - 260; ph = 215;
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      // DÍA Y TEMA
      textFont(fuenteTitulo);
      textAlign(LEFT, BASELINE);
      textSize(44);
      fill(cd);
      float wd = textWidth("DÍA " + num_dia);
      text("DÍA " + num_dia, 275, 75);
      textSize(20);
      fill(150, 160, 185);
      text("/ 7", 275 + wd + 10, 75);
      textFont(fuenteTexto);
      textSize(17);
      fill(255);
      text(tema, 275, 103);

      // NIVEL
      String txtNivelNombre;
      if (nivelElegido == 1) {
          txtNivelNombre = "Nivel 1: Principiante Digital";
      } else {
          if (nivelElegido == 2) {
              txtNivelNombre = "Nivel 2: Usuario Frecuente";
          } else {
              txtNivelNombre = "Nivel 3: Experto Digital";
          }
      }
      textFont(fuenteTitulo);
      textSize(14);
      float wb = textWidth(txtNivelNombre) + 30;
      fill(cd, 50);
      stroke(cd);
      rect(275, 118, wb, 28, 14);
      noStroke();
      fill(255);
      textAlign(LEFT, CENTER);
      text(txtNivelNombre, 290, 131);

      // CLASIFICACIÓN
      textFont(fuenteTexto);
      textSize(15);
      fill(212, 175, 55);
      textAlign(LEFT, BASELINE);
      text(clasificacion, 275, 172);

      // PROGRESO
      float anchoBarra = 420;
      int situacionesHechas = (num_dia - 1) * 5 + i;
      float anchoProgresoDia = situacionesHechas * anchoBarra / 35;
      noStroke();
      fill(255, 25);
      rect(275, 196, anchoBarra, 14, 7);
      fill(cd);
      rect(275, 196, anchoProgresoDia, 14, 7);
      stroke(255, 60);
      for (int k = 1; k < 7; k++) {
          float mx = 275 + anchoBarra * k * 5 / 35.0;
          line(mx, 194, mx, 212);
      }
      // Divisiones de los niveles: fin del día 2 (10 de 35) y fin del día 5 (25 de 35)
      stroke(212, 175, 55);
      strokeWeight(2);
      line(275 + anchoBarra * 10 / 35.0, 190, 275 + anchoBarra * 10 / 35.0, 216);
      line(275 + anchoBarra * 25 / 35.0, 190, 275 + anchoBarra * 25 / 35.0, 216);
      strokeWeight(1);
      noStroke();
      textFont(fuenteMono);
      textSize(13);
      fill(255);
      textAlign(LEFT, CENTER);
      text(situacionesHechas + "/35", 275 + anchoBarra + 12, 202);

      // RIESGO
      float xm = px + pw * 0.47;
      float nivelRiesgo = constrain(puntos / 40.0, 0, 1);
      color cr = lerpColor(color(0, 220, 130), color(255, 60, 60), nivelRiesgo);
      textFont(fuenteTexto);
      textSize(14);
      fill(150, 160, 185);
      textAlign(LEFT, BASELINE);
      text("PUNTAJE DE RIESGO", xm, 48);
      textFont(fuenteTitulo);
      textSize(40);
      fill(cr);
      text(puntos + "", xm, 92);
      float wpts = textWidth(puntos + "");
      textFont(fuenteTexto);
      textSize(16);
      fill(150, 160, 185);
      text("pts", xm + wpts + 8, 92);
      for (int k = 0; k < 20; k++) {
          if (k < nivelRiesgo * 20) {
              fill(lerpColor(color(0, 220, 130), color(255, 60, 60), k / 19.0));
          }
          else {
              fill(255, 25);
          }
          rect(xm + k * 16, 106, 12, 14, 3);
      }

      // ACIERTOS (check verde) y ERRORES (X roja)
      fill(0, 220, 130);
      ellipse(xm + 11, 158, 22, 22);
      fill(255, 70, 90);
      ellipse(xm + 11, 194, 22, 22);
      stroke(10, 14, 32);
      strokeWeight(3);
      line(xm + 6, 158, xm + 10, 162);
      line(xm + 10, 162, xm + 17, 154);
      line(xm + 7, 190, xm + 15, 198);
      line(xm + 15, 190, xm + 7, 198);
      strokeWeight(1);
      noStroke();
      textFont(fuenteTitulo);
      textSize(17);
      fill(255);
      textAlign(LEFT, CENTER);
      text("Aciertos: " + decisionesCorrectas, xm + 32, 157);
      text("Errores: " + decisionesIncorrectas, xm + 32, 193);

      // PERFIL: círculo de color con la silueta de una persona
      float ax = width - 200;
      float ay = 40;
      noFill();
      stroke(cd, 70);
      strokeWeight(8);
      ellipse(ax + 40, ay + 40, 100, 100);
      stroke(cd);
      strokeWeight(3);
      ellipse(ax + 40, ay + 40, 92, 92);
      strokeWeight(1);
      noStroke();
      fill(cd);
      ellipse(ax + 40, ay + 40, 80, 80);
      fill(10, 14, 32);
      ellipse(ax + 40, ay + 30, 26, 26);                    // cabeza
      arc(ax + 40, ay + 66, 48, 42, PI, TWO_PI);            // hombros
      textFont(fuenteTitulo);
      textSize(18);
      fill(255);
      textAlign(CENTER, CENTER);
      text(nombre, ax + 40, ay + 120);
      textFont(fuenteMono);
      textSize(12);
      fill(150, 160, 185);
      text("JUGADOR", ax + 40, ay + 145);

      // ---------------- TEXTOS DE CADA SITUACIÓN ----------------
      String sitTitulo = "";
      String sitPregunta = "";
      String op1 = "", op2 = "", op3 = "";

      switch(num_dia){
          case 1:
               switch(i){
                 case 0:
                   if (nivelElegido == 1) {
                       sitTitulo = "DÍA 1 - USO DE REDES (Principiante Digital)";
                   }
                   else {
                       if (nivelElegido == 2) {
                           sitTitulo = "DÍA 1 - USO DE REDES (Usuario Frecuente)";
                       }
                       else {
                           sitTitulo = "DÍA 1 - USO DE REDES (Experto Digital)";
                       }
                   }
                   if(nivelElegido==1) sitPregunta = "Te despiertas con 25 notificaciones. Que haces primero?";
                   else {
                       if(nivelElegido==2) sitPregunta = "Te llegan hartos mensajes de grupos mientras desayunas. Que haces?";
                       else sitPregunta = "A las 6am te llegan notificaciones del trabajo y de la U. Que haces?";
                   }
                   if (nivelElegido == 3) {
                       op1 = "Colapsar";
                   }
                   else {
                       op1 = "Scrollear";
                   }
                   op2 = "Comer"; op3 = "Responder";
                   break;
                 case 1: sitTitulo = "DÍA 1 - USO DE REDES"; sitPregunta = "Estas en clase y un amigo te manda un tiktok. Que haces?"; op1 = "Verlo"; op2 = "Silenciar"; op3 = "Contestar"; break;
                 case 2: sitTitulo = "DÍA 1 - USO DE REDES"; sitPregunta = "Te etiquetan en una foto rara sin preguntarte."; op1 = "Conversar"; op2 = "Ignorar"; op3 = "Insultar"; break;
                 case 3: sitTitulo = "DÍA 1 - USO DE REDES"; sitPregunta = "Ves vidas perfectas en redes y te sientes mal."; op1 = "Aparentar"; op2 = "Compararte"; op3 = "Desconectarte"; break;
                 case 4: sitTitulo = "DÍA 1 - USO DE REDES"; sitPregunta = "Son las 11:30 pm y mañana hay examen."; op1 = "Scrollear"; op2 = "Dormir"; op3 = "Posponer"; break;
               }
             break;
          case 2: // fake news
             switch(i){
                 case 0: sitTitulo = "DÍA 2 - NOTICIAS FALSAS"; sitPregunta = "Cadena del grupo familiar: 'el limon caliente cura todo'. Que haces?"; op1 = "Reenviar"; op2 = "Callar"; op3 = "Verificar"; break;
                 case 1: sitTitulo = "DÍA 2 - NOTICIAS FALSAS"; sitPregunta = "Una cuenta sin verificar asegura que mañana no hay clases."; op1 = "Verificar"; op2 = "Compartir"; op3 = "Preguntar"; break;
                 case 2: sitTitulo = "DÍA 2 - NOTICIAS FALSAS"; sitPregunta = "Sale un video viral de un politico, pero se ve raro (deepfake?)."; op1 = "Compartir"; op2 = "Investigar"; op3 = "Comentar"; break;
                 case 3: sitTitulo = "DÍA 2 - NOTICIAS FALSAS"; sitPregunta = "Un influencer habla de un estudio pero no deja ningun link."; op1 = "Creerle"; op2 = "Buscarlo"; op3 = "Guardarlo"; break;
                 case 4: sitTitulo = "DÍA 2 - NOTICIAS FALSAS"; sitPregunta = "Te llega una alerta de un desastre, pero la fecha es de hace 5 años."; op1 = "Avisar"; op2 = "Compartir"; op3 = "Reaccionar"; break;
             }
             break;
          case 3: // privacidad
             switch(i){
                 case 0: sitTitulo = "DÍA 3 - PRIVACIDAD DIGITAL"; sitPregunta = "Estas creando una cuenta nueva. Como dejas el perfil?"; op1 = "Pública"; op2 = "Privada"; op3 = "Mixta"; break;
                 case 1: sitTitulo = "DÍA 3 - PRIVACIDAD DIGITAL"; sitPregunta = "Estas de viaje. Cuando subes fotos con la ubicacion?"; op1 = "Ahora"; op2 = "Después"; op3 = "Pronto"; break;
                 case 2: sitTitulo = "DÍA 3 - PRIVACIDAD DIGITAL"; sitPregunta = "Un conocido te pide la contraseña 'por emergencia'."; op1 = "Prestarla"; op2 = "Negarte"; op3 = "Posponer"; break;
                 case 3: sitTitulo = "DÍA 3 - PRIVACIDAD DIGITAL"; sitPregunta = "Un juego gratis pide acceso a contactos y a la galeria."; op1 = "Aceptar"; op2 = "Revisar"; op3 = "Ignorar"; break;
                 case 4: sitTitulo = "DÍA 3 - PRIVACIDAD DIGITAL"; sitPregunta = "Usaste un pc de la U. Al terminar que haces?"; op1 = "Irte"; op2 = "Desloguear"; op3 = "Apagarlo"; break;
             }
             break;
          case 4: // tiempo de pantalla
             switch(i){
                 case 0: sitTitulo = "DÍA 4 - TIEMPO DE PANTALLA"; sitPregunta = "El celular te dice que llevas 7 horas diarias en redes."; op1 = "Ignorar"; op2 = "Limitar"; op3 = "Prometer"; break;
                 case 1: sitTitulo = "DÍA 4 - TIEMPO DE PANTALLA"; sitPregunta = "Tienes 3 horas libres en la tarde. Como las usas?"; op1 = "Scrollear"; op2 = "Equilibrar"; op3 = "Multitarea"; break;
                 case 2: sitTitulo = "DÍA 4 - TIEMPO DE PANTALLA"; sitPregunta = "En el almuerzo familiar todos estan en el celular."; op1 = "Revisar"; op2 = "Guardarlos"; op3 = "Chatear"; break;
                 case 3: sitTitulo = "DÍA 4 - TIEMPO DE PANTALLA"; sitPregunta = "Notas que abres tiktok cada 5 minutos sin darte cuenta."; op1 = "Seguir"; op2 = "Configurar"; op3 = "Prometer"; break;
                 case 4: sitTitulo = "DÍA 4 - TIEMPO DE PANTALLA"; sitPregunta = "Es domingo y pensabas estar 10 horas en pantallas."; op1 = "Maratón"; op2 = "Pausas"; op3 = "Reducir"; break;
             }
             break;
          case 5: // mensajes raros
             switch(i){
                 case 0: sitTitulo = "DÍA 5 - MENSAJES SOSPECHOSOS"; sitPregunta = "Sms del 'banco': su cuenta se bloquea hoy, entre a este link."; op1 = "Clic"; op2 = "Borrar"; op3 = "Responder"; break;
                 case 1: sitTitulo = "DÍA 5 - MENSAJES SOSPECHOSOS"; sitPregunta = "Un desconocido: hola vi tus fotos y te quiero contratar de modelo."; op1 = "Enviar"; op2 = "Bloquear"; op3 = "Conversar"; break;
                 case 2: sitTitulo = "DÍA 5 - MENSAJES SOSPECHOSOS"; sitPregunta = "'Hola soy tu familiar, cambie de numero, prestame plata urgente'."; op1 = "Transferir"; op2 = "Llamarlo"; op3 = "Preguntar"; break;
                 case 3: sitTitulo = "DÍA 5 - MENSAJES SOSPECHOSOS"; sitPregunta = "Correo: ganaste un celular, paga solo el envio."; op1 = "Pagar"; op2 = "Spam"; op3 = "Abrirlo"; break;
                 case 4: sitTitulo = "DÍA 5 - MENSAJES SOSPECHOSOS"; sitPregunta = "Alguien te pide el codigo de whatsapp."; op1 = "Darlo"; op2 = "Negarte"; op3 = "Preguntar"; break;
             }
             break;
          case 6: // bienestar
             switch(i){
                 case 0: sitTitulo = "DÍA 6 - BIENESTAR DIGITAL"; sitPregunta = "Hay cuentas que te hacen comparar y te ponen mal."; op1 = "Seguirlos"; op2 = "Silenciarlos"; op3 = "Dejarlos"; break;
                 case 1: sitTitulo = "DÍA 6 - BIENESTAR DIGITAL"; sitPregunta = "Te dejan comentarios feos en una foto."; op1 = "Insultar"; op2 = "Bloquear"; op3 = "Callar"; break;
                 case 2: sitTitulo = "DÍA 6 - BIENESTAR DIGITAL"; sitPregunta = "En el grupo de estudio se burlan de un compañero."; op1 = "Reenviar"; op2 = "Reportar"; op3 = "Salirte"; break;
                 case 3: sitTitulo = "DÍA 6 - BIENESTAR DIGITAL"; sitPregunta = "Tu ultima foto casi no tuvo likes."; op1 = "Obsesionarte"; op2 = "Relajarte"; op3 = "Preguntar"; break;
                 case 4: sitTitulo = "DÍA 6 - BIENESTAR DIGITAL"; sitPregunta = "Llevas semanas durmiendo poco por el celular de noche."; op1 = "Seguir"; op2 = "Desconectar"; op3 = "Café"; break;
             }
             break;
          case 7: // evaluacion
             switch(i){
                 case 0: sitTitulo = "DÍA 7 - EVALUACIÓN FINAL"; sitPregunta = "Una pagina de noticias te pide la contraseña para leer un articulo."; op1 = "Ingresar"; op2 = "Verificar"; op3 = "Compartir"; break;
                 case 1: sitTitulo = "DÍA 7 - EVALUACIÓN FINAL"; sitPregunta = "Tus amigos te tiran a un reto viral peligroso."; op1 = "Hacerlo"; op2 = "Negarte"; op3 = "Supervisado"; break;
                 case 2: sitTitulo = "DÍA 7 - EVALUACIÓN FINAL"; sitPregunta = "Un compañero sube algo privado tuyo 'de broma'."; op1 = "Reírte"; op2 = "Borrarlo"; op3 = "Taparlo"; break;
                 case 3: sitTitulo = "DÍA 7 - EVALUACIÓN FINAL"; sitPregunta = "Vas a estudiar 4 horas. Donde dejas el celular?"; op1 = "Cerca"; op2 = "Lejos"; op3 = "Silenciado"; break;
                 case 4: sitTitulo = "DÍA 7 - EVALUACIÓN FINAL"; sitPregunta = "Que es lo mas importante para no volverse loco con el celular?"; op1 = "Popularidad"; op2 = "Intención"; op3 = "Suerte"; break;
             }
             break;
      }

      // Centro del espacio libre: a la derecha del menú (x > 220) y debajo del HUD (y > 245).
      // mousePressed usa estas mismas fórmulas.
      float cx = 220 + (width - 220) / 2.0;
      float cy = (245 + height) / 2.0;
      float yTarjeta;                       // borde superior de la tarjeta (para el mensaje de respuesta)

      if (i < 5) {
        // ---------------- TARJETA DE LA SITUACIÓN ----------------
        pc = cd;
        px = cx - 450; pw = 900; ph = 290; py = cy - ph / 2;
        yTarjeta = py;
        float oy = py - 255;                // cuánto se movió la tarjeta respecto a la versión anterior
        noStroke();
        fill(pc, 16);
        rect(px - 6, py - 6, pw + 12, ph + 12, 20);
        fill(12, 16, 36, 228);
        stroke(pc, 140);
        strokeWeight(1.5);
        rect(px, py, pw, ph, 16);
        stroke(pc);
        strokeWeight(3);
        for (int e = 0; e < 4; e++) {
          float ex = px + 8;
          float dx = 1;
          if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
          float ey = py + 8;
          float dy = 1;
          if (e >= 2) { ey = py + ph - 8; dy = -1; }
          line(ex, ey, ex + 22 * dx, ey);
          line(ex, ey, ex, ey + 22 * dy);
        }
        strokeWeight(1);
        noStroke();

        // Encabezado
        textFont(fuenteTitulo);
        textSize(18);
        textAlign(LEFT, CENTER);
        fill(cd);
        text(sitTitulo, cx - 410, 288 + oy);
        textFont(fuenteMono);
        textSize(15);
        textAlign(RIGHT, CENTER);
        fill(150, 160, 185);
        text("SITUACIÓN " + (i + 1) + " / 5", cx + 410, 288 + oy);
        stroke(cd, 80);
        line(cx - 410, 310 + oy, cx + 410, 310 + oy);
        noStroke();

        // Notificación con la pregunta
        fill(255, 255, 255, 14);
        stroke(255, 45);
        rect(cx - 410, 325 + oy, 820, 85, 14);
        noStroke();
        fill(cd);
        ellipse(cx - 365, 367 + oy, 46, 46);
        fill(10, 14, 32);
        textFont(fuenteTitulo);
        textSize(28);
        textAlign(CENTER, CENTER);
        text("!", cx - 365, 365 + oy);

        textFont(fuenteTexto);
        textSize(21);
        fill(255);
        textAlign(LEFT, CENTER);
        text(sitPregunta, cx - 325, 330 + oy, 715, 75);

        textFont(fuenteTitulo);
        textSize(13);
        fill(150, 160, 185);
        textAlign(CENTER, CENTER);
        text("¿ Q U É   H A C E S ?", cx, 437 + oy);

        // Los 3 botones de respuesta (mismas medidas que en mousePressed)
        for (int k = 0; k < 3; k++) {
          bw = 180; bh = 50; by = 460 + oy; bc = cd; btam = 18;
          if (k == 0) { bx = cx - 280; btxt = op1; }
          else {
              if (k == 1) { bx = cx - 90; btxt = op2; }
              else { bx = cx + 100; btxt = op3; }
          }
          hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
          if (hov) {
              manito = true;
              noStroke();
              for (int g = 3; g >= 1; g--) {
                  fill(bc, 22);
                  rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
              }
              fill(lerpColor(color(28, 34, 58), bc, 0.40));
              stroke(bc);
          }
          else {
              fill(28, 34, 58, 235);
              stroke(bc, 150);
          }
          strokeWeight(2);
          rect(bx, by, bw, bh, 10);
          strokeWeight(1);
          noStroke();
          fill(255, 18);
          rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
          fill(255);
          textFont(fuenteTitulo);
          textSize(btam);
          textAlign(CENTER, CENTER);
          text(btxt, bx + bw / 2, by + bh / 2 - 2);
        }
      }
      else {
        // ---------------- RESUMEN DEL DÍA (estadísticas por día) ----------------
        boolean esFinal = (num_dia == 7);

        // Puntos y clasificación SOLO de este día (tabla del PDF)
        int puntosDia = puntos - puntosInicioDia;
        String clasifDia;
        color cClasif;
        if (puntosDia < 5) {
            clasifDia = "Ciudadano Digital Ejemplar";
            cClasif = color(0, 220, 130);
        }
        else {
            if (puntosDia <= 13) {
                clasifDia = "Usuario Digital Responsable";
                cClasif = color(0, 200, 255);
            }
            else {
                if (puntosDia <= 20) {
                    clasifDia = "Usuario en Riesgo";
                    cClasif = color(255, 200, 60);
                }
                else {
                    clasifDia = "Dependencia Digital Alta";
                    cClasif = color(255, 70, 90);
                }
            }
        }

        pc = cd;
        px = cx - 450; pw = 900; ph = 360; py = cy - ph / 2;
        yTarjeta = py;
        noStroke();
        fill(pc, 16);
        rect(px - 6, py - 6, pw + 12, ph + 12, 20);
        fill(12, 16, 36, 228);
        stroke(pc, 140);
        strokeWeight(1.5);
        rect(px, py, pw, ph, 16);
        stroke(pc);
        strokeWeight(3);
        for (int e = 0; e < 4; e++) {
          float ex = px + 8;
          float dx = 1;
          if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
          float ey = py + 8;
          float dy = 1;
          if (e >= 2) { ey = py + ph - 8; dy = -1; }
          line(ex, ey, ex + 22 * dx, ey);
          line(ex, ey, ex, ey + 22 * dy);
        }
        strokeWeight(1);
        noStroke();

        // Título
        String tt = "RESUMEN DEL DÍA " + num_dia;
        textFont(fuenteTitulo);
        textSize(30);
        textAlign(CENTER, CENTER);
        fill(cd, 40);
        text(tt, cx - 2, py + 38); text(tt, cx + 2, py + 38);
        fill(lerpColor(cd, color(255), 0.55));
        text(tt, cx, py + 38);
        stroke(cd, 80);
        line(px + 45, py + 68, px + pw - 45, py + 68);
        noStroke();

        // Datos del día en dos columnas (etiqueta en gris, valor en blanco)
        float colI = px + 45;
        float colD = px + pw / 2 + 15;
        for (int k = 0; k < 6; k++) {
          String etiqueta = "";
          String valor = "";
          float xd = colI;
          float yd = py + 100;
          switch (k) {
            case 0: etiqueta = "Ingreso: ";        valor = ingresoHoy;          xd = colI; yd = py + 100; break;
            case 1: etiqueta = "Salida: ";         valor = salidaHoy;           xd = colI; yd = py + 135; break;
            case 2: etiqueta = "Horas de uso: ";   valor = horas_uso + " h";    xd = colI; yd = py + 170; break;
            case 3: etiqueta = "Contenido 1: ";    valor = primerContenido;     xd = colD; yd = py + 100; break;
            case 4: etiqueta = "Contenido 2: ";    valor = segundoContenido;    xd = colD; yd = py + 135; break;
            case 5: etiqueta = "Puntos del día: "; valor = puntosDia + "";      xd = colD; yd = py + 170; break;
          }
          textFont(fuenteTexto);
          textSize(19);
          textAlign(LEFT, CENTER);
          fill(160, 170, 195);
          text(etiqueta, xd, yd);
          float anchoEtiqueta = textWidth(etiqueta);
          textFont(fuenteTitulo);
          textSize(19);
          fill(255);
          text(valor, xd + anchoEtiqueta, yd);
        }

        // Clasificación del día
        fill(cClasif, 35);
        stroke(cClasif);
        strokeWeight(2);
        rect(px + 45, py + 200, pw - 90, 46, 23);
        strokeWeight(1);
        noStroke();
        textFont(fuenteTitulo);
        textSize(22);
        fill(255);
        textAlign(CENTER, CENTER);
        text("Clasificación del día: " + clasifDia, cx, py + 222);

        // Botón creciente (mismo tamaño y posición que detecta mousePressed)
        float escala = 1.0 + sin(frameCount * 0.1) * 0.03;
        float anchoActual = 400 * escala;
        float altoActual = 72 * escala;
        float xCentroBoton = cx;
        float yCentroBoton = py + 301;
        hov = mouseX >= xCentroBoton - anchoActual / 2 && mouseX <= xCentroBoton + anchoActual / 2 &&
              mouseY >= yCentroBoton - altoActual / 2 && mouseY <= yCentroBoton + altoActual / 2;
        if (hov) {
            manito = true;
        }
        color cb = cd;
        if (esFinal) {
            cb = color(0, 220, 130);
        }
        rectMode(CENTER);
        noStroke();
        if (hov) {
            fill(cb, 70);
        }
        else {
            fill(cb, 35);
        }
        rect(xCentroBoton, yCentroBoton, anchoActual + 24, altoActual + 24, 20);
        if (hov) {
            fill(lerpColor(color(28, 34, 58), cb, 0.75));
        }
        else {
            fill(lerpColor(color(28, 34, 58), cb, 0.5));
        }
        stroke(cb);
        strokeWeight(2);
        rect(xCentroBoton, yCentroBoton, anchoActual, altoActual, 14);
        strokeWeight(1);
        noStroke();
        rectMode(CORNER);

        String textoBoton;
        if (esFinal) {
            textoBoton = "VER REPORTE";
        }
        else {
            textoBoton = "SIGUIENTE DIA";
        }
        fill(255);
        textFont(fuenteTitulo);
        textSize(26);
        textAlign(CENTER, CENTER);
        text(textoBoton, xCentroBoton - 12, yCentroBoton - 2);
        float twb = textWidth(textoBoton);
        triangle(xCentroBoton + twb / 2, yCentroBoton - 10, xCentroBoton + twb / 2, yCentroBoton + 10, xCentroBoton + twb / 2 + 14, yCentroBoton);
      }

      // ---------------- MENSAJE AL RESPONDER ----------------
      int pasado = frameCount - feedbackFrame;
      if (pasado < 100) {
          String feedbackTexto;
          color feedbackColor;
          if (feedbackPuntos == 0) {
              feedbackTexto = "¡DECISIÓN CORRECTA!   +0 riesgo";
              feedbackColor = color(0, 220, 130);
          }
          else {
              if (feedbackPuntos == 1) {
                  feedbackTexto = "DECISIÓN REGULAR   +1 riesgo";
                  feedbackColor = color(255, 200, 60);
              }
              else {
                  feedbackTexto = "DECISIÓN RIESGOSA   +2 riesgo";
                  feedbackColor = color(255, 70, 90);
              }
          }
          float a = 255;
          if (pasado > 70) {
              a = map(pasado, 70, 100, 255, 0);
          }
          float sube = map(min(pasado, 12), 0, 12, 20, 0);
          float yf = yTarjeta + ph + 20 + sube;   // justo debajo de la tarjeta

          fill(feedbackColor, a * 0.25);
          stroke(feedbackColor, a);
          strokeWeight(2);
          rect(cx - 260, yf, 520, 48, 24);
          strokeWeight(1);
          noStroke();
          fill(255, a);
          textFont(fuenteTitulo);
          textSize(19);
          textAlign(CENTER, CENTER);
          text(feedbackTexto, cx, yf + 23);

          // destello en el borde de la pantalla
          if (pasado < 20) {
              noFill();
              stroke(feedbackColor, map(pasado, 0, 20, 200, 0));
              strokeWeight(10);
              rect(5, 5, width - 10, height - 10);
              strokeWeight(1);
              noStroke();
          }
      }
      break;
    }

    // =================================================================
    //                PANTALLA 14: REVISAR PUBLICACIONES
    // =================================================================
    case 14: {
      color verde = color(0, 220, 130);
      float anchoTarjeta = width - 520;

      textAlign(LEFT, CENTER);
      textFont(fuenteTitulo);
      fill(255);
      textSize(34);
      text("PUBLICACIONES REVISADAS", 300, 100);
      textFont(fuenteTexto);
      fill(150, 160, 185);
      textSize(18);
      text("Contenido que consumiste durante tu sesión", 300, 140);
      noStroke();
      fill(verde);
      rect(300, 165, 140, 5, 3);

      // Dos tarjetas: primer y segundo contenido
      for (int k = 0; k < 2; k++) {
        float ty = 210 + k * 160;
        color tc;
        String etiqueta;
        String valor;
        if (k == 0) {
            tc = verde;
            etiqueta = "PRIMER CONTENIDO REVISADO";
            valor = primerContenido;
        }
        else {
            tc = color(0, 150, 255);
            etiqueta = "SEGUNDO CONTENIDO REVISADO";
            valor = segundoContenido;
        }
        strokeWeight(2);
        stroke(tc);
        fill(20, 26, 50, 235);
        rect(300, ty, anchoTarjeta, 130, 18);
        strokeWeight(1);
        noStroke();
        fill(tc, 50);
        ellipse(370, ty + 65, 86, 86);
        fill(tc);
        ellipse(370, ty + 65, 70, 70);
        fill(24, 29, 43);
        textAlign(CENTER, CENTER);
        textFont(fuenteTitulo);
        textSize(34);
        text(k + 1, 370, ty + 63);
        textAlign(LEFT, CENTER);
        textFont(fuenteTexto);
        fill(150, 160, 185);
        textSize(16);
        text(etiqueta, 430, ty + 40);
        fill(255);
        textFont(fuenteTitulo);
        textSize(30);
        text(valor, 430, ty + 82);
      }

      textFont(fuenteTexto);
      fill(212, 175, 55);
      textSize(16);
      textAlign(LEFT, CENTER);
      text("Recuerda: verifica la fuente antes de compartir.", 300, 540);
      break;
    }

    // =================================================================
    //                     PANTALLA 15: VER VIDEOS
    // =================================================================
    case 15: {
      color rojo = color(255, 60, 80);

      textAlign(LEFT, CENTER);
      textFont(fuenteTitulo);
      fill(255);
      textSize(34);
      text("VER VIDEOS", 300, 100);
      noStroke();
      fill(rojo);
      rect(300, 135, 140, 5, 3);

      float cx = width * 0.5;
      float cy = height * 0.5;

      // Tarjeta tipo reproductor
      fill(20, 26, 50, 235);
      stroke(rojo);
      strokeWeight(2);
      rect(cx - 260, cy - 170, 620, 240, 18);
      strokeWeight(1);
      noStroke();

      // Botón de play que late
      float latido = 1.0 + sin(frameCount * 0.1) * 0.06;
      fill(rojo, 60);
      ellipse(cx - 150, cy - 50, 150 * latido, 150 * latido);
      fill(rojo);
      ellipse(cx - 150, cy - 50, 110 * latido, 110 * latido);
      fill(255);
      triangle(cx - 168, cy - 75, cx - 168, cy - 25, cx - 125, cy - 50);

      fill(255);
      textFont(fuenteTitulo);
      textSize(24);
      textAlign(LEFT, CENTER);
      text("REPRODUCTOR DE VIDEO", cx, cy - 135);
      fill(200, 205, 220);
      textFont(fuenteTexto);
      textSize(16);
      textAlign(LEFT, TOP);
      text("Si quieres ver videos, haz click sobre el enlace de abajo.", cx, cy - 105, 340, 60);
      fill(150, 160, 185);
      textSize(14);
      textAlign(LEFT, CENTER);
      text("Se abrirá en una pestaña nueva de tu navegador.", cx, cy + 40);

      // ENLACE: se dibuja de último para que el clic en mousePressed
      // mida el texto con esta misma letra y tamaño.
      textFont(fuenteTexto);
      textAlign(LEFT, BASELINE);
      textSize(20);
      if (mouseX >= width*0.5 && mouseX <= width*0.5 + textWidth("https://www.youtube.com") && mouseY >= height*0.5 - 20 && mouseY <= height*0.5) {
          manito = true;
          fill(0, 170, 255);
          text("https://www.youtube.com", width*0.5, height*0.5);
          stroke(0, 170, 255);
          line(width*0.5, height*0.5 + 3, width*0.5 + textWidth("https://www.youtube.com"), height*0.5 + 3);
          noStroke();
      }
      else {
          fill(255);
          text("https://www.youtube.com", width*0.5, height*0.5);
      }
      break;
    }

    // =================================================================
    //                       PANTALLA 16: CHATEAR
    // =================================================================
    case 16: {
      color azul = color(0, 170, 255);

      float anchoChat = 750;
      float altoChat = 420;
      float xChat = (width - anchoChat) / 2;
      float yChat = (height - altoChat) / 2;

      // --- VENTANA PRINCIPAL ---
      fill(14, 18, 40, 245);
      stroke(azul);
      strokeWeight(2);
      rect(xChat, yChat, anchoChat, altoChat, 20);
      strokeWeight(1);
      noStroke();

      // --- ROBOT ---
      float rbx = xChat + 65;
      float rby = yChat + 42;
      fill(azul);
      rect(rbx - 22, rby - 16, 44, 34, 10);
      stroke(azul);
      strokeWeight(3);
      line(rbx, rby - 16, rbx, rby - 26);
      strokeWeight(1);
      noStroke();
      ellipse(rbx, rby - 28, 9, 9);
      fill(10, 14, 32);
      ellipse(rbx - 9, rby, 9, 9);
      ellipse(rbx + 9, rby, 9, 9);
      rect(rbx - 8, rby + 9, 16, 3, 2);

      // --- ENCABEZADO ---
      fill(255);
      textFont(fuenteTitulo);
      textSize(19);
      textAlign(LEFT, CENTER);
      text("Asistente Virtual de Bienestar Digital", xChat + 105, yChat + 32);
      fill(0, 220, 130);
      ellipse(xChat + 111, yChat + 56, 9, 9);
      textFont(fuenteTexto);
      textSize(13);
      text("en línea", xChat + 122, yChat + 55);

      stroke(255, 40);
      line(xChat + 40, yChat + 78, xChat + anchoChat - 40, yChat + 78);
      noStroke();

      // --- BURBUJA DEL BOT ---
      fill(azul, 45);
      stroke(azul, 140);
      rect(xChat + 40, yChat + 95, anchoChat - 80, 80, 14);
      noStroke();
      fill(255);
      textFont(fuenteTexto);
      textSize(16);
      textAlign(LEFT, CENTER);
      text("Bot: " + respuestaBot, xChat + 60, yChat + 100, anchoChat - 120, 70);

      // --- 4 BOTONES (mismas posiciones que en mousePressed) ---
      float anchoBoton = 320;
      float altoBoton = 45;
      float xBoton1 = xChat + 40;
      float xBoton2 = xChat + anchoChat - anchoBoton - 40;

      for (int k = 0; k < 4; k++) {
        bw = anchoBoton; bh = altoBoton; btam = 15; bc = azul;
        bx = xBoton1; by = yChat + 200; btxt = "";
        switch (k) {
          case 0: bx = xBoton1; by = yChat + 200; btxt = "1. Pedir un consejo"; break;
          case 1: bx = xBoton2; by = yChat + 200; btxt = "2. Ver mi estado"; break;
          case 2: bx = xBoton1; by = yChat + 260; btxt = "3. Consultar tiempo en redes"; break;
          case 3: bx = xBoton2; by = yChat + 260; btxt = "4. Salir del chat"; bc = color(255, 70, 90); break;
        }
        hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
        if (hov) {
            manito = true;
            noStroke();
            for (int g = 3; g >= 1; g--) {
                fill(bc, 22);
                rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
            }
            fill(lerpColor(color(28, 34, 58), bc, 0.40));
            stroke(bc);
        }
        else {
            fill(28, 34, 58, 235);
            stroke(bc, 150);
        }
        strokeWeight(2);
        rect(bx, by, bw, bh, 10);
        strokeWeight(1);
        noStroke();
        fill(255, 18);
        rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
        fill(255);
        textFont(fuenteTitulo);
        textSize(btam);
        textAlign(CENTER, CENTER);
        text(btxt, bx + bw / 2, by + bh / 2 - 2);
      }

      textFont(fuenteTexto);
      textSize(14);
      fill(150, 160, 185);
      textAlign(CENTER, CENTER);
      text("Elige una opción para conversar con el asistente", xChat + anchoChat / 2, yChat + 360);
      textAlign(LEFT, BASELINE);
      break;
    }

    // =================================================================
    //                PANTALLA 17: CONFIGURAR PRIVACIDAD
    // =================================================================
    case 17: {
      color morado = color(180, 100, 255);

      textAlign(LEFT, BASELINE);
      textFont(fuenteTitulo);
      fill(255);
      textSize(32);
      text("CONFIGURAR PRIVACIDAD", 300, 100);
      noStroke();
      fill(morado);
      rect(300, 118, 140, 5, 3);

      if(modoPriv == 0){

          // ---------------- DATOS DEL PERFIL ----------------
          fill(20, 26, 50, 235);
          stroke(morado, 120);
          rect(300, 140, 700, 95, 12);
          noStroke();
          textFont(fuenteTexto);
          textSize(20);
          fill(150, 160, 185);
          text("Nombre en el sistema:", 325, 178);
          text("Edad en el sistema:", 325, 213);
          fill(255);
          textFont(fuenteTitulo);
          textSize(20);           // textFont() reinicia el tamaño, por eso se vuelve a poner
          text(nombre, 560, 178);
          text(edad + " años", 560, 213);

          // 2 botones: x = 300 y 540 (igual que en mousePressed)
          for (int k = 0; k < 2; k++) {
            bx = 300 + k * 240; by = 250; bw = 220; bh = 50; bc = morado; btam = 17;
            if (k == 0) {
                btxt = "Cambiar nombre";
            }
            else {
                btxt = "Cambiar edad";
            }
            hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
            if (hov) {
                manito = true;
                noStroke();
                for (int g = 3; g >= 1; g--) {
                    fill(bc, 22);
                    rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
                }
                fill(lerpColor(color(28, 34, 58), bc, 0.40));
                stroke(bc);
            }
            else {
                fill(28, 34, 58, 235);
                stroke(bc, 150);
            }
            strokeWeight(2);
            rect(bx, by, bw, bh, 10);
            strokeWeight(1);
            noStroke();
            fill(255, 18);
            rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
            fill(255);
            textFont(fuenteTitulo);
            textSize(btam);
            textAlign(CENTER, CENTER);
            text(btxt, bx + bw / 2, by + bh / 2 - 2);
          }

          // Mensaje de confirmación
          textAlign(LEFT, CENTER);
          textFont(fuenteTitulo);
          textSize(18);
          fill(0, 220, 130);
          text(msgPriv, 300, 328);

          // ---------------- CONFIGURACIÓN DE PRIVACIDAD ----------------
          textFont(fuenteTitulo);
          textSize(20);
          fill(morado);
          textAlign(LEFT, CENTER);
          text("CONFIGURACIÓN DE PRIVACIDAD", 300, 362);

          // 4 opciones, cada una con 2 botones: x = 640 y 800, y = 385 + k * 48 (igual que en mousePressed)
          // El botón de la derecha (B) siempre es la opción más segura.
          int opcionesSeguras = 0;                 // contador para el nivel de privacidad
          for (int k = 0; k < 4; k++) {
            String nombreOpcion = "";
            String textoA = "";
            String textoB = "";
            boolean eligioB = false;
            switch (k) {
              case 0: nombreOpcion = "Tipo de perfil";            textoA = "Público";     textoB = "Privado";     eligioB = perfilPrivado;      break;
              case 1: nombreOpcion = "Mostrar mi ubicación";      textoA = "Sí";          textoB = "No";          eligioB = !mostrarUbicacion;  break;
              case 2: nombreOpcion = "Quién me puede escribir";   textoA = "Todos";       textoB = "Solo amigos"; eligioB = mensajesSoloAmigos; break;
              case 3: nombreOpcion = "Verificación en dos pasos"; textoA = "Desactivada"; textoB = "Activada";    eligioB = dosPasos;           break;
            }
            if (eligioB) {
                opcionesSeguras = opcionesSeguras + 1;
            }
            float oyFila = 385 + k * 48;

            noStroke();
            fill(255, 10);
            rect(300, oyFila - 2, 670, 42, 8);
            textFont(fuenteTexto);
            textSize(20);
            fill(220, 225, 240);
            textAlign(LEFT, CENTER);
            text(nombreOpcion, 315, oyFila + 18);

            for (int b = 0; b < 2; b++) {
              float ox = 640 + b * 160;
              boolean seleccionado = (b == 1 && eligioB) || (b == 0 && !eligioB);
              color co = color(255, 120, 90);          // opción A (menos segura)
              String to = textoA;
              if (b == 1) {
                  co = color(0, 220, 130);             // opción B (más segura)
                  to = textoB;
              }
              hov = mouseX >= ox && mouseX <= ox + 150 && mouseY >= oyFila && mouseY <= oyFila + 38;
              if (hov) {
                  manito = true;
              }
              if (seleccionado) {
                  fill(lerpColor(color(28, 34, 58), co, 0.55));
                  stroke(co);
              }
              else {
                  if (hov) {
                      fill(42, 50, 80);
                  }
                  else {
                      fill(28, 34, 58, 235);
                  }
                  stroke(co, 90);
              }
              strokeWeight(2);
              rect(ox, oyFila, 150, 38, 10);
              strokeWeight(1);
              noStroke();
              textFont(fuenteTitulo);
              textSize(17);
              if (seleccionado) {
                  fill(255);
              }
              else {
                  fill(160, 170, 195);
              }
              textAlign(CENTER, CENTER);
              text(to, ox + 75, oyFila + 18);
            }
          }

          // ---------------- NIVEL DE PRIVACIDAD ----------------
          String nivelPriv;
          color cNivel;
          if (opcionesSeguras == 4) {
              nivelPriv = "ALTO";
              cNivel = color(0, 220, 130);
          }
          else {
              if (opcionesSeguras >= 2) {
                  nivelPriv = "MEDIO";
                  cNivel = color(255, 200, 60);
              }
              else {
                  nivelPriv = "BAJO";
                  cNivel = color(255, 70, 90);
              }
          }
          float nx = 1000;
          fill(20, 26, 50, 235);
          stroke(cNivel, 160);
          strokeWeight(2);
          rect(nx, 383, 240, 136, 14);
          strokeWeight(1);
          noStroke();
          textFont(fuenteTexto);
          textSize(16);
          fill(150, 160, 185);
          textAlign(CENTER, CENTER);
          text("NIVEL DE PRIVACIDAD", nx + 120, 405);
          textFont(fuenteTitulo);
          textSize(34);
          fill(cNivel);
          text(nivelPriv, nx + 120, 445);
          for (int k = 0; k < 4; k++) {
              if (k < opcionesSeguras) {
                  fill(cNivel);
              }
              else {
                  fill(255, 30);
              }
              rect(nx + 30 + k * 47, 478, 39, 14, 4);
          }
          textFont(fuenteTexto);
          textSize(14);
          fill(170, 180, 205);
          text(opcionesSeguras + " de 4 opciones seguras", nx + 120, 506);
          textAlign(LEFT, BASELINE);
      }
      else{

          textFont(fuenteTexto);
          textSize(22);
          fill(255);
          textAlign(LEFT, BASELINE);
          if(modoPriv == 1){
              text("Ingresa el nuevo nombre:", 300, 170);
          }
          else{
              text("Ingresa la nueva edad (1 a 120):", 300, 170);
          }

          fill(5, 8, 22, 235);
          stroke(morado);
          strokeWeight(2);
          rect(300, 190, 500, 55, 10);
          strokeWeight(1);
          noStroke();
          fill(0, 255, 128);
          textFont(fuenteMono);
          textSize(24);
          text(temporal + cursorTxt, 315, 226);

          textFont(fuenteTexto);
          textSize(16);
          fill(150, 160, 185);
          text("Presiona ENTER para confirmar", 300, 275);

          textFont(fuenteTitulo);
          textSize(18);
          fill(255, 110, 110);
          text(msgPriv, 300, 315);

          // Botón Cancelar
          bx = 300; by = 340; bw = 160; bh = 45; bc = color(255, 70, 90); btam = 17; btxt = "Cancelar";
          hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
          if (hov) {
              manito = true;
              noStroke();
              for (int g = 3; g >= 1; g--) {
                  fill(bc, 22);
                  rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
              }
              fill(lerpColor(color(28, 34, 58), bc, 0.40));
              stroke(bc);
          }
          else {
              fill(28, 34, 58, 235);
              stroke(bc, 150);
          }
          strokeWeight(2);
          rect(bx, by, bw, bh, 10);
          strokeWeight(1);
          noStroke();
          fill(255, 18);
          rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
          fill(255);
          textFont(fuenteTitulo);
          textSize(btam);
          textAlign(CENTER, CENTER);
          text(btxt, bx + bw / 2, by + bh / 2 - 2);
          textAlign(LEFT, BASELINE);
      }
      break;
    }

    // =================================================================
    //                  PANTALLA 18: CONSULTAR ESTADO
    // =================================================================
    case 18: {
      color amarillo = color(255, 200, 60);

      // (La clasificación se calcula al inicio de draw() con la tabla del PDF)

      // ----- RECOMENDACIÓN SEGÚN LOS PUNTOS -----
      String recomendacion;
      if (puntos < 5) {
          recomendacion = "Tu uso es ejemplar. Mantén tus hábitos actuales.";
      }
      else {
          if (puntos <= 13) {
              recomendacion = "Buen nivel de uso, pero procura hacer pausas cada hora.";
          }
          else {
              if (puntos <= 20) {
                  recomendacion = "Cuidado: estás en riesgo. Reduce tu tiempo en redes y verifica lo que compartes.";
              }
              else {
                  recomendacion = "¡Atención! Riesgo alto de dependencia. Pon límites de tiempo y desconéctate más.";
              }
          }
      }

      // ----- TÍTULO -----
      textAlign(LEFT, BASELINE);
      textFont(fuenteTitulo);
      fill(255);
      textSize(32);
      text("ESTADO DIGITAL", 290, 80);

      float x0 = 290;
      float anchoTotal = width - 290 - 60;
      float cw = (anchoTotal - 20) / 2;
      float xb = x0 + cw + 20;
      float nivelRiesgo = constrain(puntos / 40.0, 0, 1);
      color cr = lerpColor(color(0, 220, 130), color(255, 60, 60), nivelRiesgo);

      // ----- 5 TARJETAS (fondo y título) -----
      for (int k = 0; k < 5; k++) {
        float tx = x0, ty = 105, tw = cw, th = 150;
        String tt = "";
        color tc = amarillo;
        switch (k) {
          case 0: tx = x0; ty = 105; tt = "INFORMACIÓN DEL USUARIO"; tc = color(0, 220, 130); break;
          case 1: tx = xb; ty = 105; tt = "MÉTRICAS DE ACTIVIDAD";   tc = color(0, 170, 255); break;
          case 2: tx = x0; ty = 275; tt = "CONTENIDO VISTO";         tc = color(180, 100, 255); break;
          case 3: tx = xb; ty = 275; tt = "EVALUACIÓN DE RIESGO";    tc = cr; break;
          case 4: tx = x0; ty = 445; tw = anchoTotal; th = 95; tt = "RECOMENDACIÓN DEL SISTEMA"; tc = amarillo; break;
        }
        fill(20, 26, 50, 235);
        stroke(tc, 150);
        strokeWeight(1.5);
        rect(tx, ty, tw, th, 14);
        strokeWeight(1);
        noStroke();
        fill(tc);
        rect(tx, ty + 14, 4, th - 28, 2);
        textFont(fuenteTitulo);
        textSize(14);
        textAlign(LEFT, BASELINE);
        text(tt, tx + 25, ty + 32);
      }

      // ----- INFORMACIÓN DEL USUARIO -----
      textFont(fuenteTexto);
      textSize(19);
      fill(255);
      textAlign(LEFT, BASELINE);
      text("Nombre: " + nombre, x0 + 25, 175);
      text("Edad: " + edad + " años", x0 + 25, 212);

      // ----- MÉTRICAS DE ACTIVIDAD -----
      textSize(15);
      text("Ingreso: " + hora_entrada, xb + 25, 168);
      text("Salida: " + hora_salida, xb + 25, 198);
      text("Tiempo en redes hoy: " + horas_uso + " h   |   En la semana: " + horasTotales + " h", xb + 25, 228);

      // ----- CONTENIDO VISTO -----
      fill(180, 100, 255);
      ellipse(x0 + 32, 339, 9, 9);
      ellipse(x0 + 32, 377, 9, 9);
      textSize(19);
      fill(255);
      text(primerContenido, x0 + 48, 345);
      text(segundoContenido, x0 + 48, 383);

      // ----- EVALUACIÓN DE RIESGO -----
      textFont(fuenteTitulo);
      textSize(40);
      fill(cr);
      text(puntos + " pts", xb + 25, 352);
      noStroke();
      fill(255, 25);
      rect(xb + 25, 365, cw - 50, 10, 5);
      fill(cr);
      rect(xb + 25, 365, (cw - 50) * nivelRiesgo, 10, 5);
      textFont(fuenteTexto);
      textSize(16);
      fill(255);
      text("Clasificación: " + clasificacion, xb + 25, 405);

      // ----- RECOMENDACIÓN -----
      textSize(19);
      text(recomendacion, x0 + 25, 512);
      break;
    }

    // =================================================================
    //                PANTALLA 19: ESTADÍSTICAS FINALES
    // =================================================================
    case 19: {
      // Confeti
      randomSeed(99);
      noStroke();
      for (int k = 0; k < 70; k++) {
          float cxc = random(width);
          float cyc = (random(height) + frameCount * random(1, 3)) % height;
          if (k % 4 == 0) fill(255, 0, 200);
          else {
              if (k % 4 == 1) fill(0, 220, 255);
              else {
                  if (k % 4 == 2) fill(212, 175, 55);
                  else fill(0, 220, 130);
              }
          }
          pushMatrix();
          translate(cxc, cyc);
          rotate(frameCount * 0.05 + k);
          rect(-5, -3, 10, 6);
          popMatrix();
      }

      // Trofeo
      float tx = width / 2;
      float ty = height * 0.2 + sin(frameCount * 0.05) * 8;
      noStroke();
      fill(212, 175, 55, 50);
      ellipse(tx, ty + 30, 230, 230);
      fill(212, 175, 55);
      arc(tx, ty, 120, 140, 0, PI);
      rect(tx - 60, ty - 30, 120, 31);
      rect(tx - 10, ty + 65, 20, 30);
      rect(tx - 40, ty + 92, 80, 16, 4);
      noFill();
      stroke(212, 175, 55);
      strokeWeight(8);
      arc(tx - 60, ty + 5, 50, 60, HALF_PI, PI + HALF_PI);
      arc(tx + 60, ty + 5, 50, 60, -HALF_PI, HALF_PI);
      strokeWeight(1);
      noStroke();
      fill(255, 255, 255, 90);
      rect(tx - 40, ty - 22, 12, 60, 6);
      fill(255, 245, 200);
      beginShape();
      for (int s = 0; s < 10; s++) {
          float ang = -HALF_PI + s * PI / 5;
          float r = 10;
          if (s % 2 == 0) {
              r = 22;
          }
          vertex(tx + cos(ang) * r, ty + 15 + sin(ang) * r);
      }
      endShape(CLOSE);

      textFont(fuenteTexto);
      textSize(20);
      fill(0, 220, 255);
      textAlign(CENTER, CENTER);
      text("M I S I Ó N   C O M P L E T A D A", width / 2, height * 0.45);

      // Título neón
      String tt = "Estadísticas finales";
      float ttx = width / 2;
      float tty = height * 0.53;
      color tc = color(212, 175, 55);
      textFont(fuenteTitulo);
      textSize(70);
      fill(tc, 40);
      text(tt, ttx - 3, tty); text(tt, ttx + 3, tty); text(tt, ttx, tty - 3); text(tt, ttx, tty + 3);
      fill(tc, 110);
      text(tt, ttx - 1.5, tty); text(tt, ttx + 1.5, tty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, ttx, tty);

      textFont(fuenteTexto);
      textSize(20);
      fill(225, 230, 245);
      text("¡Bien hecho, " + nombre + "! Sobreviviste a la semana digital.", width / 2, height * 0.62);
      break;
    }

    // =================================================================
    //                   PANTALLA 20: DATOS BÁSICOS
    // =================================================================
    case 20: {
      String tt = "Datos básicos";
      float tx = width / 2;
      float ty = 85;
      color tc = color(0, 220, 255);
      textFont(fuenteTitulo);
      textSize(64);
      textAlign(CENTER, CENTER);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      // ---- Datos reales de los 7 días (ya no se multiplica un solo día x 7) ----
      int horasAcumuladas = horasTotales;               // suma de las horas de los 7 días
      float promedioDiario = horasTotales / 7.0;        // promedio de horas por día

      // Días que tiene el año: 366 si es bisiesto, 365 si no
      int diasDelAño;
      if ((año % 4 == 0 && año % 100 != 0) || año % 400 == 0) {
          diasDelAño = 366;
      }
      else {
          diasDelAño = 365;
      }
      float diasPorAño = promedioDiario * diasDelAño / 24.0;   // promedio diario llevado a un año, en días

      // Mostrar con 1 decimal: se multiplica por 10 y se redondea (76.04 -> 760),
      // la división entre 10 da la parte entera (76) y el residuo % 10 da el decimal (0)
      int decimas = (int) (diasPorAño * 10 + 0.5);
      String textoDiasAño = (decimas / 10) + "." + (decimas % 10);

      pc = color(0, 220, 255);
      pw = min(1300, width - 80); px = (width - pw) / 2; py = 150; ph = 4 * 100 + 30;
      noStroke();
      fill(pc, 16);
      rect(px - 6, py - 6, pw + 12, ph + 12, 20);
      fill(12, 16, 36, 228);
      stroke(pc, 140);
      strokeWeight(1.5);
      rect(px, py, pw, ph, 16);
      stroke(pc);
      strokeWeight(3);
      for (int e = 0; e < 4; e++) {
        float ex = px + 8;
        float dx = 1;
        if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
        float ey = py + 8;
        float dy = 1;
        if (e >= 2) { ey = py + ph - 8; dy = -1; }
        line(ex, ey, ex + 22 * dx, ey);
        line(ex, ey, ex, ey + 22 * dy);
      }
      strokeWeight(1);
      noStroke();

      // 4 filas: la semana digital empieza con el ingreso del Día 1 y termina con la salida del Día 7
      for (int k = 0; k < 4; k++) {
        String etiqueta = "";
        String valor = "";
        color fc = color(255);
        switch (k) {
          case 0: etiqueta = "Hora de ingreso";           valor = fechaDia1 + "   " + ingresoDia1; fc = color(0, 220, 130); break;
          case 1: etiqueta = "Hora de salida";            valor = fechaDia7 + "   " + salidaDia7;  fc = color(255, 140, 40); break;
          case 2: etiqueta = "Horas acumuladas de uso";   valor = horasAcumuladas + " horas  (7 días)"; fc = color(180, 100, 255); break;
          case 3: etiqueta = "Días equivalentes por año"; valor = textoDiasAño + " días al año"; fc = color(255, 80, 100); break;
        }
        float fx = px + 35;
        float fy = py + 25 + k * 100;
        float fw = pw - 70;
        noStroke();
        fill(255, 12);
        rect(fx, fy, fw, 82, 12);
        fill(fc);
        rect(fx, fy + 16, 6, 50, 3);
        textFont(fuenteTexto);
        textSize(28);
        fill(205, 212, 232);
        textAlign(LEFT, CENTER);
        text(etiqueta, fx + 30, fy + 39);
        textFont(fuenteTitulo);
        textSize(26);
        fill(lerpColor(fc, color(255), 0.55));
        textAlign(RIGHT, CENTER);
        text(valor, fx + fw - 30, fy + 39);
      }
      break;
    }

    // =================================================================
    //                 PANTALLA 21: ESTADÍSTICAS DE JUEGO
    // =================================================================
    case 21: {
      String tt = "Estadísticas de Juego";
      float tx = width / 2;
      float ty = 68;
      color tc = color(212, 175, 55);
      textFont(fuenteTitulo);
      textSize(58);
      textAlign(CENTER, CENTER);
      fill(tc, 40);
      text(tt, tx - 3, ty); text(tt, tx + 3, ty); text(tt, tx, ty - 3); text(tt, tx, ty + 3);
      fill(tc, 110);
      text(tt, tx - 1.5, ty); text(tt, tx + 1.5, ty);
      fill(lerpColor(tc, color(255), 0.55));
      text(tt, tx, ty);

      String nivelAlcanzado;
      if (decisionesCorrectas >= 28) {
          nivelAlcanzado = "Nivel 3: Experto Digital";
      } else {
          if (decisionesCorrectas >= 18) {
              nivelAlcanzado = "Nivel 2: Usuario Frecuente";
          } else {
              nivelAlcanzado = "Nivel 1: Principiante Digital";
          }
      }

      // ----- LOGROS -----
      int cantidadLogros = 0;                 // contador de logros
      boolean logro1 = false, logro2 = false, logro3 = false, logro4 = false;
      if (puntos < 5) {
          cantidadLogros++;
          logro1 = true;
      }
      if (decisionesCorrectas >= 25) {
          cantidadLogros++;
          logro2 = true;
      }
      if (decisionesIncorrectas <= 5) {
          cantidadLogros++;
          logro3 = true;
      }
      if (horasTotales / 7.0 <= 3) {          // promedio de la semana
          cantidadLogros++;
          logro4 = true;
      }

      // ----- 3 TARJETAS DE NÚMEROS (grandes para que el jurado las lea bien) -----
      float cw = 340;
      float gap = 30;
      float xs = (width - (cw * 3 + gap * 2)) / 2;
      for (int k = 0; k < 3; k++) {
        float sx = xs + k * (cw + gap);
        String etiqueta = "";
        String valor = "";
        color sc = color(255);
        switch (k) {
          case 0: etiqueta = "Decisiones correctas";   valor = decisionesCorrectas + " / 35";   sc = color(0, 220, 130); break;
          case 1: etiqueta = "Decisiones incorrectas"; valor = decisionesIncorrectas + " / 35"; sc = color(255, 70, 90); break;
          case 2: etiqueta = "Puntaje digital";        valor = puntos + "";                      sc = color(255, 200, 60); break;
        }
        fill(20, 26, 50, 235);
        stroke(sc, 180);
        strokeWeight(3);
        rect(sx, 112, cw, 155, 18);
        strokeWeight(1);
        noStroke();
        textFont(fuenteTitulo);
        textSize(62);
        fill(sc);
        textAlign(CENTER, CENTER);
        text(valor, sx + cw / 2, 168);
        textFont(fuenteTexto);
        textSize(22);
        fill(210, 215, 235);
        text(etiqueta, sx + cw / 2, 235);
      }

      // ----- NIVEL ALCANZADO -----
      float anchoFila = cw * 3 + gap * 2;
      fill(0, 220, 255, 30);
      stroke(0, 220, 255);
      strokeWeight(2);
      rect(xs, 287, anchoFila, 70, 35);
      strokeWeight(1);
      noStroke();
      textFont(fuenteTexto);
      textSize(22);
      fill(170, 180, 205);
      textAlign(LEFT, CENTER);
      text("NIVEL ALCANZADO", xs + 35, 321);
      textFont(fuenteTitulo);
      textSize(30);
      fill(255);
      textAlign(RIGHT, CENTER);
      text(nivelAlcanzado, xs + anchoFila - 35, 321);

      // ----- INSIGNIAS DE LOGROS -----
      textFont(fuenteTitulo);
      textSize(25);
      fill(212, 175, 55);
      textAlign(LEFT, CENTER);
      text("LOGROS OBTENIDOS:  " + cantidadLogros + " de 4", xs, 392);

      float iw = (anchoFila - 3 * 20) / 4;
      for (int k = 0; k < 4; k++) {
        float ix = xs + k * (iw + 20);
        float iy = 418;
        String nombreLogro = "";
        String detalle = "";
        boolean ganado = false;
        switch (k) {
          case 0: nombreLogro = "Experto en Bienestar Digital"; detalle = "Riesgo menor a 5";  ganado = logro1; break;
          case 1: nombreLogro = "Influencer Responsable";       detalle = "25 o más aciertos"; ganado = logro2; break;
          case 2: nombreLogro = "Detective de Fake News";       detalle = "5 errores o menos"; ganado = logro3; break;
          case 3: nombreLogro = "Rey del Tiempo";               detalle = "Promedio de 3 h o menos";   ganado = logro4; break;
        }

        if (ganado) {
            noStroke();
            fill(212, 175, 55, 40 + sin(frameCount * 0.08) * 20);
            rect(ix - 6, iy - 6, iw + 12, 197, 22);
            fill(40, 34, 20, 240);
            stroke(212, 175, 55);
        }
        else {
            fill(20, 24, 40, 220);
            stroke(70, 80, 105);
        }
        strokeWeight(3);
        rect(ix, iy, iw, 185, 18);
        strokeWeight(1);
        noStroke();

        if (ganado) {
            // estrella dorada
            fill(212, 175, 55);
            beginShape();
            for (int s = 0; s < 10; s++) {
                float ang = -HALF_PI + s * PI / 5;
                float r = 15;
                if (s % 2 == 0) {
                    r = 34;
                }
                vertex(ix + iw / 2 + cos(ang) * r, iy + 50 + sin(ang) * r);
            }
            endShape(CLOSE);
        }
        else {
            // candado
            float lx = ix + iw / 2;
            float ly = iy + 52;
            noFill();
            stroke(110, 120, 150);
            strokeWeight(6);
            arc(lx, ly - 10, 38, 42, PI, TWO_PI);
            strokeWeight(1);
            noStroke();
            fill(110, 120, 150);
            rect(lx - 26, ly - 10, 52, 38, 8);
            fill(20, 26, 50);
            ellipse(lx, ly + 6, 9, 9);
        }

        textFont(fuenteTitulo);
        textSize(20);
        if (ganado) {
            fill(255, 230, 150);
        }
        else {
            fill(130, 140, 165);
        }
        textAlign(CENTER, CENTER);
        text(nombreLogro, ix + 10, iy + 92, iw - 20, 56);
        textFont(fuenteTexto);
        textSize(17);
        fill(170, 180, 205);
        text(detalle, ix + iw / 2, iy + 163);
      }
      break;
    }

    // =================================================================
    //   PANTALLA 28: FINAL (BUENO, REGULAR O MALO)
    //   PANTALLA 29: REPORTE FINAL + RANKING PERSONAL
    //   Las dos comparten los cálculos de abajo.
    // =================================================================
    case 28: case 29: {
      // ----- ¿Qué final le toca? Según el "17. Diagnóstico Final" del PDF -----
      // Menos de 5: Uso saludable (FINAL BUENO)
      // Entre 5 y 13: Debe mejorar algunos hábitos digitales (FINAL REGULAR)
      // Más de 13: Uso no saludable (FINAL MALO)
      int tipoFinal;
      if (puntos < 5) {
          tipoFinal = 1;
      }
      else {
          if (puntos <= 13) {
              tipoFinal = 2;
          }
          else {
              tipoFinal = 3;
          }
      }

      String tituloFinal = "";
      String diagnostico = "";
      String historia = "";
      color cf = color(255);
      int estrellas = 1;
      switch (tipoFinal) {
        case 1:
          tituloFinal = "FINAL BUENO";
          diagnostico = "Uso saludable de redes sociales";
          cf = color(0, 220, 130);
          estrellas = 3;
          historia = "¡" + nombre + ", sobreviviste a la semana digital! Verificaste la información antes de compartirla, "
                   + "cuidaste tu privacidad y supiste desconectarte a tiempo. Eres un ejemplo para Ciudad Digital.";
          break;
        case 2:
          tituloFinal = "FINAL REGULAR";
          diagnostico = "Debe mejorar algunos hábitos digitales";
          cf = color(255, 200, 60);
          estrellas = 2;
          historia = nombre + ", terminaste la semana con altibajos. Tomaste buenas decisiones, pero algunos hábitos "
                   + "todavía te ponen en riesgo. Con pequeños cambios puedes lograr el equilibrio digital.";
          if (horas_uso < horasPrimerDia) {
              historia = historia + " ¡Y usaste menos las redes el Día 7 que el Día 1!";
          }
          break;
        case 3:
          tituloFinal = "FINAL MALO";
          diagnostico = "Uso no saludable de redes sociales";
          cf = color(255, 70, 90);
          estrellas = 1;
          historia = nombre + ", la semana digital te atrapó. Pasaste demasiado tiempo conectado y varias decisiones "
                   + "pusieron en riesgo tu bienestar y tu seguridad. Es momento de poner límites.";
          break;
      }

      // ----- Mensaje del ranking personal -----
      String msgRanking;
      if (puntajeAnterior < 0) {
          msgRanking = "Primera partida: ¡este es tu primer récord!";
      }
      else {
          int diferencia = puntajeAnterior - puntos;
          if (diferencia > 0) {
              msgRanking = "¡Mejoraste " + diferencia + " puntos frente a la partida anterior!";
          }
          else {
              if (diferencia < 0) {
                  msgRanking = "Subiste " + (-diferencia) + " puntos de riesgo frente a la partida anterior.";
              }
              else {
                  msgRanking = "Igual que en la partida anterior.";
              }
          }
          if (nuevoRecord) {
              msgRanking = "¡NUEVO RÉCORD!  " + msgRanking;
          }
      }

      if (pantalla == 28) {
        // ========================= PANTALLA DEL FINAL =========================

        // ----- Título neón grande -----
        float tx = width / 2;
        float ty = height * 0.20;
        textFont(fuenteTitulo);
        textSize(84);
        textAlign(CENTER, CENTER);
        fill(cf, 40);
        text(tituloFinal, tx - 3, ty); text(tituloFinal, tx + 3, ty); text(tituloFinal, tx, ty - 3); text(tituloFinal, tx, ty + 3);
        fill(cf, 110);
        text(tituloFinal, tx - 1.5, ty); text(tituloFinal, tx + 1.5, ty);
        fill(lerpColor(cf, color(255), 0.55));
        text(tituloFinal, tx, ty);

        // ----- Estrellas: primero las 3 apagadas (ciclo Para)... -----
        float yEst = height * 0.34 + sin(frameCount * 0.06) * 5;
        noStroke();
        for (int k = 0; k < 3; k++) {
            float xEst = width / 2 + (k - 1) * 90;
            fill(255, 30);
            beginShape();
            for (int s2 = 0; s2 < 10; s2++) {
                float ang = -HALF_PI + s2 * PI / 5;
                float r = 15;
                if (s2 % 2 == 0) {
                    r = 34;
                }
                vertex(xEst + cos(ang) * r, yEst + sin(ang) * r);
            }
            endShape(CLOSE);
        }
        // ...y encima las que ganó (ciclo Hacer hasta: siempre se dibuja al menos una)
        int est = 0;
        do {
            float xEst = width / 2 + (est - 1) * 90;
            fill(cf, 60);
            ellipse(xEst, yEst, 90, 90);
            fill(cf);
            beginShape();
            for (int s2 = 0; s2 < 10; s2++) {
                float ang = -HALF_PI + s2 * PI / 5;
                float r = 15;
                if (s2 % 2 == 0) {
                    r = 34;
                }
                vertex(xEst + cos(ang) * r, yEst + sin(ang) * r);
            }
            endShape(CLOSE);
            est = est + 1;
        } while (est < estrellas);

        // ----- Diagnóstico (sección 17 del PDF) -----
        textFont(fuenteTexto);
        textSize(18);
        fill(150, 160, 185);
        textAlign(CENTER, CENTER);
        text("D I A G N Ó S T I C O", width / 2, height * 0.45);
        textFont(fuenteTitulo);
        textSize(28);
        fill(lerpColor(cf, color(255), 0.4));
        text(diagnostico, width / 2, height * 0.50);

        // ----- Historia del final en un panel -----
        pc = cf;
        pw = min(950, width - 120); px = (width - pw) / 2; py = height * 0.56; ph = 130;
        noStroke();
        fill(pc, 16);
        rect(px - 6, py - 6, pw + 12, ph + 12, 20);
        fill(12, 16, 36, 228);
        stroke(pc, 140);
        strokeWeight(1.5);
        rect(px, py, pw, ph, 16);
        stroke(pc);
        strokeWeight(3);
        for (int e = 0; e < 4; e++) {
          float ex = px + 8;
          float dx = 1;
          if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
          float ey = py + 8;
          float dy = 1;
          if (e >= 2) { ey = py + ph - 8; dy = -1; }
          line(ex, ey, ex + 22 * dx, ey);
          line(ex, ey, ex, ey + 22 * dy);
        }
        strokeWeight(1);
        noStroke();
        textFont(fuenteTexto);
        textSize(20);
        fill(225, 230, 245);
        textAlign(CENTER, CENTER);
        text(historia, px + 40, py + 10, pw - 80, ph - 20);
      }
      else {
        // ===================== PANTALLA DEL REPORTE FINAL =====================

        // ----- Título neón -----
        float tx = width / 2;
        float ty = height * 0.09;
        textFont(fuenteTitulo);
        textSize(52);
        textAlign(CENTER, CENTER);
        fill(cf, 40);
        text("REPORTE FINAL", tx - 3, ty); text("REPORTE FINAL", tx + 3, ty); text("REPORTE FINAL", tx, ty - 3); text("REPORTE FINAL", tx, ty + 3);
        fill(cf, 110);
        text("REPORTE FINAL", tx - 1.5, ty); text("REPORTE FINAL", tx + 1.5, ty);
        fill(lerpColor(cf, color(255), 0.55));
        text("REPORTE FINAL", tx, ty);

        // ----- REPORTE FINAL -----
        pc = cf;
        pw = min(1000, width - 120); px = (width - pw) / 2; py = height * 0.17; ph = 400;
        noStroke();
        fill(pc, 16);
        rect(px - 6, py - 6, pw + 12, ph + 12, 20);
        fill(12, 16, 36, 228);
        stroke(pc, 140);
        strokeWeight(1.5);
        rect(px, py, pw, ph, 16);
        stroke(pc);
        strokeWeight(3);
        for (int e = 0; e < 4; e++) {
          float ex = px + 8;
          float dx = 1;
          if (e == 1 || e == 3) { ex = px + pw - 8; dx = -1; }
          float ey = py + 8;
          float dy = 1;
          if (e >= 2) { ey = py + ph - 8; dy = -1; }
          line(ex, ey, ex + 22 * dx, ey);
          line(ex, ey, ex, ey + 22 * dy);
        }
        strokeWeight(1);
        noStroke();

        float c1 = px + 45;            // columna izquierda
        float c2 = px + pw / 2 + 10;   // columna derecha

        textFont(fuenteTitulo);
        textSize(22);
        fill(cf);
        textAlign(LEFT, CENTER);
        text("RESUMEN DE LA SEMANA", c1, py + 40);
        textFont(fuenteMono);
        textSize(18);
        fill(150, 160, 185);
        textAlign(RIGHT, CENTER);
        text("PARTIDA #" + partidasJugadas, px + pw - 45, py + 40);

        textAlign(LEFT, CENTER);
        textFont(fuenteTexto);
        textSize(24);
        fill(255);
        text("Jugador: " + nombre, c1, py + 85);

        textFont(fuenteTitulo);
        textSize(32);
        fill(cf);
        text("Puntaje: " + puntos, c1, py + 132);

        textSize(25);
        fill(255);
        text("Clasificación: " + clasificacion, c1, py + 178);

        textFont(fuenteTexto);
        textSize(25);
        fill(225, 230, 245);
        text("Diagnóstico: " + diagnostico, c1, py + 222);

        stroke(255, 40);
        line(c1, py + 254, px + pw - 45, py + 254);
        noStroke();

        textFont(fuenteTitulo);
        textSize(22);
        fill(212, 175, 55);
        text("RANKING PERSONAL", c1, py + 284);

        textFont(fuenteTexto);
        textSize(23);
        fill(255);
        text("Mejor puntaje: " + mejorPuntaje + "  (partida #" + partidaMejor + ")", c1, py + 324);
        if (puntajeAnterior < 0) {
            text("Partida anterior: -", c2, py + 324);
        }
        else {
            text("Partida anterior: " + puntajeAnterior, c2, py + 324);
        }
        textFont(fuenteTitulo);
        textSize(22);
        if (nuevoRecord || puntajeAnterior < 0) {
            fill(255, 225, 140);
        }
        else {
            fill(200, 210, 230);
        }
        text(msgRanking, c1, py + 366);

        // ----- Botones: JUGAR DE NUEVO y SALIR (mismas medidas que en mousePressed) -----
        for (int k = 0; k < 2; k++) {
          bw = 260; bh = 60; by = height * 0.17 + 418; btam = 20;
          if (k == 0) {
              bx = width / 2 - 280; btxt = "JUGAR DE NUEVO"; bc = color(0, 220, 255);
          }
          else {
              bx = width / 2 + 20; btxt = "SALIR"; bc = color(255, 70, 90);
          }
          hov = mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
          if (hov) {
              manito = true;
              noStroke();
              for (int g = 3; g >= 1; g--) {
                  fill(bc, 22);
                  rect(bx - g * 4, by - g * 4, bw + g * 8, bh + g * 8, 10 + g * 4);
              }
              fill(lerpColor(color(28, 34, 58), bc, 0.40));
              stroke(bc);
          }
          else {
              fill(28, 34, 58, 235);
              stroke(bc, 150);
          }
          strokeWeight(2);
          rect(bx, by, bw, bh, 10);
          strokeWeight(1);
          noStroke();
          fill(255, 18);
          rect(bx + 4, by + 4, bw - 8, bh * 0.4, 8);
          fill(255);
          textFont(fuenteTitulo);
          textSize(btam);
          textAlign(CENTER, CENTER);
          text(btxt, bx + bw / 2, by + bh / 2 - 2);
        }

        // ----- Lema oficial (sección 18 del PDF) -----
        textFont(fuenteTexto);
        textSize(18);
        fill(212, 175, 55, 200 + sin(frameCount * 0.05) * 55);
        textAlign(CENTER, CENTER);
        text("\"Tus decisiones digitales construyen tu futuro.\"", width / 2, height * 0.17 + 508);
      }
      break;
    }
  }

  // ==========================================
  // TEXTO "PRESIONA ENTER..." QUE PARPADEA
  // ==========================================
  if (pantalla == 0 || pantalla == 1 || (pantalla >= 19 && pantalla <= 21) || pantalla == 28) {
    String indicacion = "";
    float iy = height * 0.87;
    switch (pantalla) {
      case 0:  indicacion = "PRESIONA ENTER PARA COMENZAR"; break;
      case 1:  indicacion = "PRESIONA ENTER PARA CREAR TU JUGADOR"; break;
      case 19: indicacion = "PRESIONA ENTER PARA VER TUS RESULTADOS"; break;
      case 20: indicacion = "PRESIONA ENTER PARA CONTINUAR"; break;
      case 21: indicacion = "PRESIONA ENTER PARA VER TU FINAL"; iy = height - 55; break;
      case 28: indicacion = "PRESIONA ENTER PARA VER TU REPORTE FINAL"; break;
    }
    float a = 160 + sin(frameCount * 0.12) * 95;
    textFont(fuenteTitulo);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(255, a);
    text(indicacion, width / 2, iy);
    float tw = textWidth(indicacion);
    noStroke();
    fill(0, 220, 255, a);
    triangle(width / 2 - tw / 2 - 30, iy - 9, width / 2 - tw / 2 - 30, iy + 9, width / 2 - tw / 2 - 16, iy);
    triangle(width / 2 + tw / 2 + 30, iy - 9, width / 2 + tw / 2 + 30, iy + 9, width / 2 + tw / 2 + 16, iy);
  }

  // Manito si el mouse está sobre algo clickeable.
  // Solo se cambia el cursor cuando hace falta (no en cada cuadro).
  if (manito != manitoActiva) {
      manitoActiva = manito;
      if (manito) {
          cursor(HAND);
      }
      else {
          cursor(ARROW);
      }
  }
}

// =====================================================================
//                           TECLADO (SIN CAMBIOS)
// =====================================================================

void keyPressed(){

  if (key == BACKSPACE) {

    if (temporal.length() > 0) {
      temporal = temporal.substring(0, temporal.length() - 1);
    }
    // Al dividir entre 10 se quita el último dígito del número (ej: 125 / 10 = 12)
    numeroEscrito = numeroEscrito / 10;
  }


  else if ((key == ENTER || key == RETURN) && pantalla != 12 && pantalla != 27 && pantalla != 10 && pantalla != 25) {   // en 10, 12, 25 y 27 se elige con el mouse

    mensajeBisiesto = "";

    if (pantalla == 17 && botonSeleccionado == 4 && modoPriv != 0) {
          if (modoPriv == 1) {
                 if (temporal.trim().length() < 2) {
                        msgPriv = "El nombre debe tener al menos 2 letras.";
                 }
                 else {
                      nombre = temporal.trim();
                      temporal = "";
                      modoPriv = 0;
                      msgPriv = "Nombre actualizado correctamente.";
                 }
          }
          else {
                 if (temporal.length() == 0) {
                      msgPriv = "Escribe un número.";
                 }
                 else {
                      int nuevaEdad = numeroEscrito;

                      if (nuevaEdad < 1 || nuevaEdad > 120) {
                            msgPriv = "Edad inválida. Ingresa un valor entre 1 y 120.";
                      }
                      else {
                            edad = nuevaEdad;
                            temporal = "";
                            modoPriv = 0;
                            msgPriv = "Edad actualizada correctamente.";
                      }
                 }
          }

    }
    else {

      if (temporal.trim().length() == 0 && ((pantalla >= 2 && pantalla <= 12) || (pantalla >= 23 && pantalla <= 26))) {
          mensajeError = "Este campo no puede estar vacío.";
      }
      else {
          mensajeError = "";
          avanzarPantalla = true;

          switch(pantalla) {

            case 2:   // NOMBRE: mínimo 2 letras (al escribir solo se aceptan letras y espacios)
              String nom = temporal.trim();
              boolean nombreOk = nom.length() >= 2;
              if (nombreOk) {
                nombre = nom;
              } else {
                mensajeError = "El nombre debe tener al menos 2 letras.";
                avanzarPantalla = false;
              }
              break;

            case 3:   // EDAD: 1 a 120
              int e = numeroEscrito;
              if (e >= 1 && e <= 120) {
                edad = e;
              } else {
                mensajeError = "La edad debe estar entre 1 y 120.";
                avanzarPantalla = false;
              }
              break;

            case 4:   // AÑO: 1900 a 2100
              int a = numeroEscrito;
              if (a >= 1900 && a <= 2100) {
                año = a;
                if ((año % 4 == 0 && año % 100 != 0) || año % 400 == 0) {
                  mensajeBisiesto = "Año bisiesto";
                } else {
                  mensajeBisiesto = "";
                }
              }
              else {
                mensajeError = "El año debe estar entre 1900 y 2100.";
                avanzarPantalla = false;
              }
              break;

            case 5:   // MES: 1 a 12
              int m = numeroEscrito;
              if (m >= 1 && m <= 12) {
                mes = m;
              } else {
                mensajeError = "El mes debe estar entre 1 y 12.";
                avanzarPantalla = false;
              }
              break;

            case 6:   // DÍA: según el mes y si el año es bisiesto
              int d = numeroEscrito;
              int diasDelMes;
              if (mes == 2) {
                if ((año % 4 == 0 && año % 100 != 0) || año % 400 == 0) {
                  diasDelMes = 29;
                } else {
                  diasDelMes = 28;
                }
              } else {
                if (mes == 4 || mes == 6 || mes == 9 || mes == 11) {
                  diasDelMes = 30;
                } else {
                  diasDelMes = 31;
                }
              }
              if (d >= 1 && d <= diasDelMes) {
                dia = d;
              } else {
                mensajeError = "Ese mes tiene " + diasDelMes + " días. Ingresa un día entre 1 y " + diasDelMes + ".";
                avanzarPantalla = false;
              }
              break;

            case 7:   // DÍA DE LA SEMANA
              // Se acepta el día en minúscula, con la primera letra en mayúscula o todo en mayúscula.
              // Cada forma se revisa con su propio "case" y el día se guarda siempre en minúscula,
              // porque así lo usa el programa para pasar al día siguiente.
              String ds = temporal.trim();
              switch (ds) {
                case "lunes":
                case "Lunes":
                case "LUNES":
                  dia_semana = "lunes";
                  break;
                case "martes":
                case "Martes":
                case "MARTES":
                  dia_semana = "martes";
                  break;
                case "miercoles":
                case "Miercoles":
                case "MIERCOLES":
                case "miércoles":
                case "Miércoles":
                case "MIÉRCOLES":
                  dia_semana = "miércoles";
                  break;
                case "jueves":
                case "Jueves":
                case "JUEVES":
                  dia_semana = "jueves";
                  break;
                case "viernes":
                case "Viernes":
                case "VIERNES":
                  dia_semana = "viernes";
                  break;
                case "sabado":
                case "Sabado":
                case "SABADO":
                case "sábado":
                case "Sábado":
                case "SÁBADO":
                  dia_semana = "sábado";
                  break;
                case "domingo":
                case "Domingo":
                case "DOMINGO":
                  dia_semana = "domingo";
                  break;
                default:
                  mensajeError = "Escribe un día válido (lunes a domingo).";
                  avanzarPantalla = false;
                  break;
              }
              break;

            case 8:  case 23:   // HORA (registro inicial y diario): 1 a 12 (formato de 12 horas)
              int h = numeroEscrito;
              if (h >= 1 && h <= 12) {
                hora = h;
              } else {
                mensajeError = "La hora debe estar entre 1 y 12.";
                avanzarPantalla = false;
              }
              break;

            case 9:  case 24:   // MINUTOS (registro inicial y diario): 0 a 59
              int min = numeroEscrito;
              if (min >= 0 && min <= 59) {
                minutos = min;
              } else {
                mensajeError = "Los minutos deben estar entre 0 y 59.";
                avanzarPantalla = false;
              }
              break;

            case 11: case 26:   // HORAS DE USO (registro inicial y diario)
                  int hu = numeroEscrito;

                  // ================= HORA DE ENTRADA =================
                  // Pasar de 12 horas a 24 horas (militar)
                  int hEnt24 = hora % 12;              // 12 AM -> 0
                  if (franja.equals("PM")) {
                    hEnt24 = hEnt24 + 12;              // 1 PM -> 13, 12 PM -> 12
                  }

                  // El juego va día por día: la salida NO puede pasar al día siguiente.
                  // Como los minutos van de 0 a 59, si (hora de entrada + horas de uso) es 23 o menos,
                  // la salida queda como máximo a las 11:59 PM (23:59:01 con el segundo adicional).
                  int horasMaximas = 23 - hEnt24;

                  // ----- Números con 2 dígitos para mostrarlos como en un reloj (8 -> "08") -----
                  // Si el número es menor que 10 se le pone un 0 adelante.
                  String txtHEnt24 = "" + hEnt24;
                  if (hEnt24 < 10) {
                      txtHEnt24 = "0" + hEnt24;
                  }
                  String txtHora = "" + hora;
                  if (hora < 10) {
                      txtHora = "0" + hora;
                  }
                  String txtMin = "" + minutos;
                  if (minutos < 10) {
                      txtMin = "0" + minutos;
                  }
                  String txtDia = "" + dia;
                  if (dia < 10) {
                      txtDia = "0" + dia;
                  }
                  String txtMes = "" + mes;
                  if (mes < 10) {
                      txtMes = "0" + mes;
                  }

                  if (hu >= 0 && hu <= horasMaximas) {
                    horas_uso = hu;

                    // ----- Estadísticas de la semana -----
                    horasTotales = horasTotales + horas_uso;
                    if (num_dia == 1) {
                        horasPrimerDia = horas_uso;
                    }

                    hora_entrada = txtHEnt24 + ":" + txtMin + ":00"
                      + " (" + txtHora + ":" + txtMin + ":00 " + franja + ")"
                      + "  " + dia_semana + "   " + txtDia + "/" + txtMes + "/" + año;

                    // ================= HORA DE SALIDA =================
                    // Entrada + horas de uso + 1 segundo
                    int hSal24 = hEnt24 + horas_uso;     // nunca pasa de 23 (salida máxima 11:59 PM)
                    // los minutos de salida son los mismos de la entrada (txtMin)
                    int segSal = 1;                      // el segundo adicional

                        // Pasar la salida a 12 horas con AM/PM
                        int hSal12 = hSal24 % 12;
                        if (hSal12 == 0) {
                          hSal12 = 12;
                        }
                        String franjaSal;
                        if (hSal24 < 12) {
                          franjaSal = "AM";
                        }
                        else {
                          franjaSal = "PM";
                        }

                        // Números de la salida con 2 dígitos
                        String txtHSal24 = "" + hSal24;
                        if (hSal24 < 10) {
                            txtHSal24 = "0" + hSal24;
                        }
                        String txtHSal12 = "" + hSal12;
                        if (hSal12 < 10) {
                            txtHSal12 = "0" + hSal12;
                        }
                        String txtSeg = "" + segSal;
                        if (segSal < 10) {
                            txtSeg = "0" + segSal;
                        }

                        hora_salida = txtHSal24 + ":" + txtMin + ":" + txtSeg
                          + " (" + txtHSal12 + ":" + txtMin + ":" + txtSeg + " " + franjaSal + ")"
                          + "  " + dia_semana + "   " + txtDia + "/" + txtMes + "/" + año;

                        // ----- Horas de este día con minutos y segundos, en los 2 formatos (militar y 12 horas) -----
                        ingresoHoy = txtHEnt24 + ":" + txtMin + ":00"
                          + " (" + txtHora + ":" + txtMin + ":00 " + franja + ")";
                        salidaHoy  = txtHSal24 + ":" + txtMin + ":" + txtSeg
                          + " (" + txtHSal12 + ":" + txtMin + ":" + txtSeg + " " + franjaSal + ")";
                        String fechaHoy = dia_semana + " " + txtDia + "/" + txtMes + "/" + año;

                        // Para los datos básicos de la semana: ingreso del Día 1 y salida del Día 7
                        if (num_dia == 1) {
                            fechaDia1 = fechaHoy;
                            ingresoDia1 = ingresoHoy;
                        }
                        if (num_dia == 7) {
                            fechaDia7 = fechaHoy;
                            salidaDia7 = salidaHoy;
                        }

                        if (horas_uso > 3 && horas_uso < 8) {
                          puntos = puntos + 4;
                        }
                        else {
                              if (horas_uso >= 8) {
                                  puntos = puntos + 7;
                              }
                        }
                        // ================= PUNTOS POR HORARIO =================
                        // Horario saludable: de 8:00:00 a.m. a 8:00:00 p.m.
                        // La hora de salida incluye el segundo adicional
                        int segEntrada = hEnt24 * 3600 + minutos * 60;           // hora de entrada en segundos
                        int segSalida  = hSal24 * 3600 + minutos * 60 + segSal;   // hora de salida en segundos (con el +1)

                        if (segEntrada < 8 * 3600 || segEntrada > 20 * 3600 ||
                            segSalida  < 8 * 3600 || segSalida  > 20 * 3600) {
                          puntos = puntos + 4;
                        }
                  }
                  else {
                    String palabraHoras = " horas";
                    if (horasMaximas == 1) {
                        palabraHoras = " hora";
                    }
                    mensajeError = "Ingresaste a las " + hora + ":" + txtMin + " " + franja
                                 + ": máximo " + horasMaximas + palabraHoras + " (salida hasta las 11:59 PM).";
                    avanzarPantalla = false;
                  }
              break;
          }

          temporal = "";

          // ENTER solo avanza en: introducción y registro (0 a 12), estadísticas (19 a 21),
          // registro diario (23 a 26) y pantalla del final (28 -> 29).
          // En el dashboard (13 a 18) y en el reporte final (29) no hace nada.
          boolean pantallaConEnter = pantalla <= 12 || (pantalla >= 19 && pantalla <= 21) || (pantalla >= 23 && pantalla <= 26) || pantalla == 28;
          if ((avanzarPantalla && pantallaConEnter) || (pantalla>=19 && pantalla<22)) {
            pantalla = pantalla + 1;
            if (pantalla == 22) {
                pantalla = 28;          // después de las estadísticas viene el final

                // ----- Ranking personal: ¿esta partida es un nuevo récord? (menos riesgo = mejor) -----
                if (mejorPuntaje < 0 || puntos < mejorPuntaje) {
                    nuevoRecord = true;
                    mejorPuntaje = puntos;
                    partidaMejor = partidasJugadas;
                }
                else {
                    nuevoRecord = false;
                }
                String[] ranking = new String[1];
ranking[0] = mejorPuntaje + ";" + partidaMejor + ";" + partidasJugadas + ";" + puntos;
saveStrings(dataPath("ranking.txt"), ranking);

String nivelFinal;
if (decisionesCorrectas >= 28) {
    nivelFinal = "Nivel 3: Experto Digital";
}
else {
    if (decisionesCorrectas >= 18) {
        nivelFinal = "Nivel 2: Usuario Frecuente";
    }
    else {
        nivelFinal = "Nivel 1: Principiante Digital";
    }
}

String[] resumen = new String[10];
resumen[0] = "Jugador: " + nombre;
resumen[1] = "Edad: " + edad;
resumen[2] = "Partida: " + partidasJugadas;
resumen[3] = "Puntaje digital: " + puntos;
resumen[4] = "Clasificación: " + clasificacion;
resumen[5] = "Decisiones correctas: " + decisionesCorrectas;
resumen[6] = "Decisiones incorrectas: " + decisionesIncorrectas;
resumen[7] = "Horas acumuladas de uso: " + horasTotales;
resumen[8] = "Nivel alcanzado: " + nivelFinal;
resumen[9] = "Mejor puntaje: " + mejorPuntaje;
saveStrings(dataPath("ultima_partida.txt"), resumen);
            }
          }
      }
    }
  }
  else {
        if (key != CODED && pantalla != 12 && pantalla != 27 && pantalla != 10 && pantalla != 25) {
              if (pantalla == 17 && botonSeleccionado == 4 && modoPriv != 0) {
                    if (modoPriv == 1) {
                           boolean esLetra = false;

                           if (key >= 'a' && key <= 'z') esLetra = true;
                           if (key >= 'A' && key <= 'Z') esLetra = true;
                           if (key == ' ') esLetra = true;

                           if (key == 'á' || key == 'é' || key == 'í' ||
                               key == 'ó' || key == 'ú' || key == 'ñ') {
                                 esLetra = true;
                           }

                           if (key == 'Á' || key == 'É' || key == 'Í' ||
                               key == 'Ó' || key == 'Ú' || key == 'Ñ') {
                                 esLetra = true;
                           }

                           if (esLetra && temporal.length() < 20) {
                               temporal = temporal + key;
                           }
                    }
                    else {
                            if (key >= '0' && key <= '9' && temporal.length() < 3) {
                                  if (temporal.length() == 0) {
                                      numeroEscrito = 0;              // empieza un número nuevo
                                  }
                                  temporal = temporal + key;
                                  // key - '0' da el valor del dígito (ej: '7' - '0' = 7)
                                  numeroEscrito = numeroEscrito * 10 + (key - '0');
                             }
                   }

              }
              else {
                    if (pantalla == 3 || pantalla == 4 || pantalla == 5 || pantalla == 6 ||
                        pantalla == 8 || pantalla == 9 || pantalla == 11 ||
                        pantalla == 23 || pantalla == 24 || pantalla == 26) {
                          if (key >= '0' && key <= '9' && temporal.length() < 4) {
                                if (temporal.length() == 0) {
                                    numeroEscrito = 0;                // empieza un número nuevo
                                }
                                temporal = temporal + key;
                                // Cada dígito corre los anteriores una posición: 12 y luego 5 -> 12 * 10 + 5 = 125
                                numeroEscrito = numeroEscrito * 10 + (key - '0');
                          }
                    }
                    else {
                          if (pantalla == 2) {
                                // NOMBRE: solo se aceptan letras, tildes, ñ y espacios
                                boolean esLetra = false;
                                if (key >= 'a' && key <= 'z') esLetra = true;
                                if (key >= 'A' && key <= 'Z') esLetra = true;
                                if (key == ' ') esLetra = true;
                                if (key == 'á' || key == 'é' || key == 'í' ||
                                    key == 'ó' || key == 'ú' || key == 'ñ') {
                                      esLetra = true;
                                }
                                if (key == 'Á' || key == 'É' || key == 'Í' ||
                                    key == 'Ó' || key == 'Ú' || key == 'Ñ') {
                                      esLetra = true;
                                }
                                if (esLetra && temporal.length() < 20) {
                                    temporal = temporal + key;
                                }
                          }
                          else {
                                temporal = temporal + key;
                          }
                    }
              }
        }
    }
}

// =====================================================================
//                    MOUSE (misma lógica de antes)
//  Cambios: 1) se guarda feedbackPuntos/feedbackFrame al responder una situación
//           2) el botón "Siguiente día" quedó centrado (0.5 * width)
// =====================================================================

void mousePressed() {

  //************************************* BOTON CRECIENTE **********************************************
  float escalaClick = 1.0 + sin(frameCount * 0.1) * 0.03;
  float anchoActualClick = 400 * escalaClick;
  float altoActualClick = 72 * escalaClick;

  // Centro del espacio libre (igual que en draw): a la derecha del menú y debajo del HUD
  float cxLibre = 220 + (width - 220) / 2.0;
  float cyLibre = (245 + height) / 2.0;

  float xCentroClick = cxLibre;
  float yCentroClick = (cyLibre - 360 / 2.0) + 301;   // botón de la tarjeta "Resumen del día"

  // ******************************** Puntos de riesgo de cada botón según el día y la situación *****************************************
  //********************************* p1 = botón izquierdo, p2 = botón del centro, p3 = botón derecho ************************************


  int p1 = 0, p2 = 0, p3 = 0;
  switch (num_dia * 10 + i) {
    // Día 1
    case 10: p1 = 2; p2 = 0; p3 = 1; break;
    case 11: p1 = 2; p2 = 0; p3 = 1; break;
    case 12: p1 = 0; p2 = 1; p3 = 2; break;
    case 13: p1 = 1; p2 = 2; p3 = 0; break;
    case 14: p1 = 2; p2 = 0; p3 = 1; break;
    // Día 2
    case 20: p1 = 2; p2 = 1; p3 = 0; break;
    case 21: p1 = 0; p2 = 2; p3 = 1; break;
    case 22: p1 = 2; p2 = 0; p3 = 1; break;
    case 23: p1 = 2; p2 = 0; p3 = 1; break;
    case 24: p1 = 0; p2 = 2; p3 = 1; break;
    // Día 3
    case 30: p1 = 2; p2 = 0; p3 = 1; break;
    case 31: p1 = 2; p2 = 0; p3 = 1; break;
    case 32: p1 = 2; p2 = 0; p3 = 1; break;
    case 33: p1 = 2; p2 = 0; p3 = 1; break;
    case 34: p1 = 2; p2 = 0; p3 = 1; break;
    // Día 4
    case 40: p1 = 2; p2 = 0; p3 = 1; break;
    case 41: p1 = 2; p2 = 0; p3 = 1; break;
    case 42: p1 = 1; p2 = 0; p3 = 2; break;
    case 43: p1 = 2; p2 = 0; p3 = 1; break;
    case 44: p1 = 2; p2 = 0; p3 = 1; break;
    // Día 5
    case 50: p1 = 2; p2 = 0; p3 = 1; break;
    case 51: p1 = 2; p2 = 0; p3 = 1; break;
    case 52: p1 = 2; p2 = 0; p3 = 1; break;
    case 53: p1 = 2; p2 = 0; p3 = 1; break;
    case 54: p1 = 2; p2 = 0; p3 = 1; break;
    // Día 6
    case 60: p1 = 2; p2 = 1; p3 = 0; break;
    case 61: p1 = 2; p2 = 0; p3 = 1; break;
    case 62: p1 = 2; p2 = 0; p3 = 1; break;
    case 63: p1 = 2; p2 = 0; p3 = 1; break;
    case 64: p1 = 2; p2 = 0; p3 = 1; break;
    // Día 7
    case 70: p1 = 2; p2 = 0; p3 = 1; break;
    case 71: p1 = 2; p2 = 0; p3 = 1; break;
    case 72: p1 = 2; p2 = 0; p3 = 1; break;
    case 73: p1 = 2; p2 = 0; p3 = 1; break;
    case 74: p1 = 2; p2 = 0; p3 = 1; break;
  }

  //************************************* VARIABLES DEL CHAT-BOT ****************************************

  // Calculamos las mismas medidas para el mousePressed
  float anchoChat = 750;
  float altoChat = 420;
  float xChat = (width - anchoChat) / 2;
  float yChat = (height - altoChat) / 2;

  float anchoBoton = 320;
  float altoBoton = 45;
  float xBoton1 = xChat + 40;
  float xBoton2 = xChat + anchoChat - anchoBoton - 40;

  //*********************************** VARIABLES DE SITUACIONES ******************************************

  float bAncho = 180;
  float bAlto = 50;
  float bY = (cyLibre - 290 / 2.0) + 205;              // tarjeta de la situación
  float x1 = cxLibre - 280;
  float x2 = cxLibre - 90;
  float x3 = cxLibre + 100;

  //********************************* REVISAR PUBLICACIONES ******************************************
  if (mouseX >= 15 && mouseX <= 205 && mouseY >= 100 && mouseY <= 145 &&  pantalla > 12  &&  pantalla < 19) {
      botonSeleccionado = 1; // Marca el botón 1 como presionado

                pantalla = 14;
  }
  else{
      //*************************************** VER VIDEOS ********************************************
      if (mouseX >= 15 && mouseX <= 205 && mouseY >= 160 && mouseY <= 205 && pantalla > 12  &&  pantalla < 19) {
          botonSeleccionado = 2; // Marca el botón 2 como presionado

                pantalla = 15;
      }
      else{
          //************************************** CHATEAR ***********************************************
          if (mouseX >= 15 && mouseX <= 205 && mouseY >= 220 && mouseY <= 265 && pantalla > 12  &&  pantalla < 19) {
              botonSeleccionado = 3; // Marca el botón 3 como presionado

                  pantalla = 16;
          }
          else{
              //************************************* CONFIGURAR PRIVACIDAD ***********************************
              if (mouseX >= 15 && mouseX <= 205 && mouseY >= 280 && mouseY <= 325 && pantalla > 12  &&  pantalla < 19) {
                  botonSeleccionado = 4; // Marca el botón 4 como presionado

                      pantalla = 17;
              }
              else{
                  //*********************************** CONSULTAR ESTADO ***************************************
                  if (mouseX >= 15 && mouseX <= 205 && mouseY >= 340 && mouseY <= 385 &&  pantalla > 12  &&  pantalla < 19) {
                      botonSeleccionado = 5; // Marca el botón 5 como presionado

                          pantalla = 18;
                  }
                  else{
                      //*************************************** SALIR *******************************************
                      if (mouseX >= 15 && mouseX <= 205 && mouseY >= 400 && mouseY <= 445 && pantalla > 12  &&  pantalla < 19) {
                          botonSeleccionado = 6; // Marca el botón 6 como presionado
                          exit();
                      }
                      // Botones de las situaciones.............
                      else{
                          if (mouseX >= x1 && mouseX <= x1 + bAncho && mouseY >= bY && mouseY <= bY + bAlto && i>=0 && i<5 && pantalla ==13) {
                            puntos = puntos + p1;
                            feedbackPuntos = p1; feedbackFrame = frameCount;   // para el mensaje en pantalla
                            if (p1 == 0) decisionesCorrectas= decisionesCorrectas +1;
                            else decisionesIncorrectas = decisionesIncorrectas + 1;
                            i=i+1;
                          }
                          else{
                              if (mouseX >= x2 && mouseX <= x2 + bAncho && mouseY >= bY && mouseY <= bY + bAlto && i>=0 && i<5 && pantalla ==13) {
                                puntos = puntos + p2;
                                feedbackPuntos = p2; feedbackFrame = frameCount;   // para el mensaje en pantalla
                                if (p2 == 0) decisionesCorrectas= decisionesCorrectas +1;
                                else decisionesIncorrectas = decisionesIncorrectas + 1;
                                i=i+1;
                              }
                              else{
                                  if (mouseX >= x3 && mouseX <= x3 + bAncho && mouseY >= bY && mouseY <= bY + bAlto && i>=0 && i<5 && pantalla ==13) {
                                      puntos = puntos + p3;
                                      feedbackPuntos = p3; feedbackFrame = frameCount;   // para el mensaje en pantalla
                                      if (p3 == 0) decisionesCorrectas= decisionesCorrectas +1;
                                      else decisionesIncorrectas = decisionesIncorrectas + 1;
                                      i=i+1;
                                  }
                                  else{
                                       if(mouseX >= xCentroClick - (anchoActualClick / 2) && mouseX <= xCentroClick + (anchoActualClick / 2) && mouseY >= yCentroClick - (altoActualClick / 2) &&
                                       mouseY <= yCentroClick + (altoActualClick / 2) && pantalla == 13 && i==5){

                                           if(num_dia==7){
                                                  pantalla = 19;
                                           }
                                           if (num_dia < 7) {
                                                  num_dia = num_dia + 1;
                                                  i = 0;
                                                  if (num_dia >= 6) {
                                                      nivelElegido = 3;
                                                  } else {
                                                      if (num_dia >= 3) {
                                                          nivelElegido = 2;
                                                      }
                                                  }

                                                  // ---- Fecha del nuevo día: se suma 1 día a la fecha anterior ----
                                                  int diasMes;
                                                  if (mes == 2) {
                                                      if ((año % 4 == 0 && año % 100 != 0) || año % 400 == 0) {
                                                          diasMes = 29;
                                                      }
                                                      else {
                                                          diasMes = 28;
                                                      }
                                                  }
                                                  else {
                                                      if (mes == 4 || mes == 6 || mes == 9 || mes == 11) {
                                                          diasMes = 30;
                                                      }
                                                      else {
                                                          diasMes = 31;
                                                      }
                                                  }
                                                  dia = dia + 1;
                                                  if (dia > diasMes) {             // se pasó al mes siguiente
                                                      dia = 1;
                                                      mes = mes + 1;
                                                      if (mes > 12) {              // se pasó al año siguiente
                                                          mes = 1;
                                                          año = año + 1;
                                                      }
                                                  }
                                                  switch (dia_semana) {
                                                      case "lunes":     dia_semana = "martes";    break;
                                                      case "martes":    dia_semana = "miércoles"; break;
                                                      case "miercoles":
                                                      case "miércoles": dia_semana = "jueves";    break;
                                                      case "jueves":    dia_semana = "viernes";   break;
                                                      case "viernes":   dia_semana = "sábado";    break;
                                                      case "sabado":
                                                      case "sábado":    dia_semana = "domingo";   break;
                                                      case "domingo":   dia_semana = "lunes";     break;
                                                  }

                                                  // ---- Antes de empezar el día: registro diario (pantallas 23 a 27) ----
                                                  puntosInicioDia = puntos;    // para calcular los puntos de este día
                                                  campoActivo = 0;
                                                  primerContenido = "";
                                                  segundoContenido = "";
                                                  temporal = "";
                                                  mensajeError = "";
                                                  pantalla = 23;
                                           }
                                       }
                                       else{
                                            // ******************************************* LINK DE YOUTUBE *****************************************************
                                            if (pantalla == 15 && mouseX >= width*0.5 && mouseX <= width*0.5 + textWidth("https://www.youtube.com") && mouseY >= height*0.5 - 20 && mouseY <= height*0.5){

                                                    link("https://www.youtube.com"); // ¡Abre YouTube en el navegador!
                                            }
                                            else{
                                                //************************************************ BOTON VOLVER ****************************************************
                                                if (pantalla>12 && pantalla<19 && mouseX >= width-300 && mouseX <= width-150 && mouseY >= height-200 && mouseY <= height-150){

                                                      pantalla = 13;
                                                }

                                                // Botón 1: CONSEJO
                                                if (botonSeleccionado == 3 && mouseX >= xBoton1 && mouseX <= xBoton1 + anchoBoton && mouseY >= yChat + 200 && mouseY <= yChat + 200 + altoBoton && pantalla==16) {
                                                      if (puntos >= 14) {
                                                            respuestaBot = "Te sugiero limitar tu consumo de redes a máximo 2 horas al día.";
                                                      }
                                                      if (puntos < 14) {
                                                            respuestaBot = "¡Vas por buen camino! Procura no usar el teléfono 1 hora antes de dormir.";
                                                      }
                                                }

                                                // Botón 2: ESTADO
                                                if (botonSeleccionado == 3 && mouseX >= xBoton2 && mouseX <= xBoton2 + anchoBoton && mouseY >= yChat + 200 && mouseY <= yChat + 200 + altoBoton && pantalla==16) {
                                                      respuestaBot = "Tienes " + puntos + " puntos de riesgo. Clasificación: " + clasificacion + ".";
                                                }

                                                // Botón 3: REDES
                                                if (botonSeleccionado == 3 && mouseX >= xBoton1 && mouseX <= xBoton1 + anchoBoton && mouseY >= yChat + 260 && mouseY <= yChat + 260 + altoBoton && pantalla ==16) {
                                                      if (horas_uso > 4) {
                                                              respuestaBot = "Has registrado " + horas_uso + " hrs. ¡Atención! Es un tiempo elevado.";
                                                      }
                                                      if (horas_uso <= 4) {
                                                              respuestaBot = "Has registrado " + horas_uso + " hrs. Está dentro de un rango saludable.";
                                                      }
                                                }

                                                // Botón 4: SALIR
                                                if (botonSeleccionado == 3 && mouseX >= xBoton2 && mouseX <= xBoton2 + anchoBoton && mouseY >= yChat + 260 && mouseY <= yChat + 260 + altoBoton && pantalla==16) {

                                                    respuestaBot = "¡Un gusto hablar contigo, " + nombre + "!";
                                                    pantalla = 13;

                                                }
                                            }
                                       }
                                  }
                              }
                          }
                      }
                  }
              }
         }
     }
  }
  if (botonSeleccionado == 4 && pantalla == 17) {

      if (modoPriv == 0) {

          // Cambiar nombre
          if (mouseX >= 300 && mouseX <= 520 && mouseY >= 250 && mouseY <= 300) {
              modoPriv = 1;
              temporal = "";
              msgPriv = "";
          }

          // Cambiar edad
          if (mouseX >= 540 && mouseX <= 760 && mouseY >= 250 && mouseY <= 300) {
              modoPriv = 2;
              temporal = "";
              msgPriv = "";
          }

          // Configuración de privacidad: 4 filas, botón A en x = 640 y botón B en x = 800
          for (int k = 0; k < 4; k++) {
              float oyFila = 385 + k * 48;
              if (mouseY >= oyFila && mouseY <= oyFila + 38) {
                  boolean clicA = mouseX >= 640 && mouseX <= 790;
                  boolean clicB = mouseX >= 800 && mouseX <= 950;
                  if (clicA || clicB) {
                      switch (k) {
                        case 0:
                          perfilPrivado = clicB;
                          if (clicB) msgPriv = "Tu perfil ahora es privado.";
                          else msgPriv = "Tu perfil ahora es público: cualquiera puede verlo.";
                          break;
                        case 1:
                          mostrarUbicacion = clicA;
                          if (clicB) msgPriv = "Tu ubicación ya no se muestra.";
                          else msgPriv = "Tu ubicación será visible en tus publicaciones.";
                          break;
                        case 2:
                          mensajesSoloAmigos = clicB;
                          if (clicB) msgPriv = "Solo tus amigos te pueden escribir.";
                          else msgPriv = "Cualquier persona te puede escribir.";
                          break;
                        case 3:
                          dosPasos = clicB;
                          if (clicB) msgPriv = "Verificación en dos pasos activada.";
                          else msgPriv = "Verificación en dos pasos desactivada.";
                          break;
                      }
                  }
              }
          }
      }
      else {

          if (mouseX >= 300 && mouseX <= 460 && mouseY >= 340 && mouseY <= 385) {
              modoPriv = 0;
              temporal = "";
              msgPriv = "";
          }
      }
  }

  //********************************* PANTALLAS 12 Y 27: ELEGIR CONTENIDOS CON BOTONES ************************************
  // Va al final para que, al pasar a la pantalla 13, este mismo clic no toque un botón del juego.
  if (pantalla == 12 || pantalla == 27) {
      float anchoPanel = min(760, width - 120);
      float ix = (width - anchoPanel) / 2 + 40;
      float iw = anchoPanel - 80;

      // Ciclo Mientras: revisa los botones uno por uno y se detiene cuando encuentra el que se tocó
      int k = 0;
      boolean encontrado = false;
      while (k < 7 && !encontrado) {
          float iy = 150 + 85 + k * 58;          // mismas medidas que en draw()
          if (mouseX >= ix && mouseX <= ix + iw && mouseY >= iy && mouseY <= iy + 48) {
              encontrado = true;

              // Contenido y puntos de riesgo (definidos por el equipo):
              // educativo, verificadas, cultural = 0 | entretenimiento = 1
              // noticias falsas, información engañosa = 3 | violento = 4
              String item = "";
              int puntosItem = 0;
              switch (k) {
                case 0: item = "contenido educativo";  puntosItem = 0; break;
                case 1: item = "noticias verificadas"; puntosItem = 0; break;
                case 2: item = "contenido cultural";   puntosItem = 0; break;
                case 3: item = "entretenimiento";      puntosItem = 1; break;
                case 4: item = "noticias falsas";      puntosItem = 3; break;
                case 5: item = "contenido violento";   puntosItem = 4; break;
                case 6: item = "informacion engañosa"; puntosItem = 3; break;
              }

              // Si ya se eligió, no se puede volver a seleccionar
              if (!item.equals(primerContenido)) {
                  puntos = puntos + puntosItem;

                  mensajeError = "";
                  temporal = "";
                  if (campoActivo == 0) {
                      primerContenido = item;
                      campoActivo = 1;
                  }
                  else {
                      segundoContenido = item;
                      pantalla = 13;               // empieza (o continúa) el juego
                  }
              }
          }
          k = k + 1;
      }
  }

  //********************************* PANTALLAS 10 Y 25: FRANJA HORARIA (AM / PM) ************************************
  if (pantalla == 10 || pantalla == 25) {
      float anchoPanel = min(1000, width - 120);          // mismas medidas que en draw()
      float xPanel = (width - anchoPanel) / 2;
      float yBotones = height * 0.18 + 185 - 3;
      if (mouseY >= yBotones && mouseY <= yBotones + 70) {
          boolean eligio = false;
          if (mouseX >= xPanel + anchoPanel / 2 - 240 && mouseX <= xPanel + anchoPanel / 2 - 20) {
              franja = "AM";
              eligio = true;
          }
          if (mouseX >= xPanel + anchoPanel / 2 + 20 && mouseX <= xPanel + anchoPanel / 2 + 240) {
              franja = "PM";
              eligio = true;
          }
          if (eligio) {
              mensajeError = "";
              mensajeBisiesto = "";
              temporal = "";
              pantalla = pantalla + 1;          // 10 -> 11 (registro inicial) o 25 -> 26 (registro diario)
          }
      }
  }

  //********************************* PANTALLA 29: JUGAR DE NUEVO / SALIR ************************************
  if (pantalla == 29) {
      float byFinal = height * 0.17 + 418;          // mismas medidas que en draw()
      if (mouseY >= byFinal && mouseY <= byFinal + 60) {

          // SALIR
          if (mouseX >= width / 2 + 20 && mouseX <= width / 2 + 280) {
              exit();
          }

          // JUGAR DE NUEVO: reinicia todas las variables del juego y vuelve a la bienvenida
          if (mouseX >= width / 2 - 280 && mouseX <= width / 2 - 20) {
              partidasJugadas = partidasJugadas + 1;     // contador de partidas
              puntajeAnterior = puntos;                  // para comparar en el ranking de la próxima partida
              // (mejorPuntaje y partidaMejor NO se borran: son el ranking personal)

              pantalla = 0;
              num_dia = 1;
              i = 0;
              puntos = 0;
              nombre = "";
              temporal = "";
              clasificacion = "";
              mensajeError = "";
              mensajeBisiesto = "";
              avanzarPantalla = true;
              botonSeleccionado = 0;

              campoActivo = 0;
              primerContenido = "";
              segundoContenido = "";

              respuestaBot = "¡Hola! Selecciona una opción de abajo para conversar.";
              modoPriv = 0;
              perfilPrivado = false;
              mostrarUbicacion = true;
              mensajesSoloAmigos = false;
              dosPasos = false;
              msgPriv = "";
              hora_entrada = "";
              hora_salida = "Pendiente de calcular";

              nivelElegido = 1;
              decisionesCorrectas = 0;
              decisionesIncorrectas = 0;
              feedbackPuntos = 0;
              feedbackFrame = -1000;

              horasTotales = 0;
              horasPrimerDia = 0;
              puntosInicioDia = 0;
              ingresoHoy = "";
              salidaHoy = "";
              fechaDia1 = "";
              ingresoDia1 = "";
              fechaDia7 = "";
              salidaDia7 = "";
          }
      }
  }
}
