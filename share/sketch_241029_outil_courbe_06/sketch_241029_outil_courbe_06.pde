/*
  v1: implementation des modes et de l'interface
    - gestion des message d'erreur
  v2:
    - ajout des dragdrop de fichier
  v3:
    - Ajout du mode CONVERT
    - ajout de la sauvegarde json
  v4
    - ajout du mode EDIT
  v5
    - ajout fonctionnalités mode EDIT
    - corrections diverses de comportement des boutons
    - correction passage d'un mode à l'autre avec conservation des courbes.
    - ajout du drop des json et passage en EDIT
  v6
    - nettoyage du code
    - modification placement elements controlP5
    - curseur move sur courbe mode CONVERT
    
    TODO
    - curseur doigt sur onglets
    - au debut ou quand pas de fichier chargé, les onglets de CONVERT et EDIt sont grisés et non cliquables
*/

import drop.*;
import controlP5.*;
import processing.svg.*;

/* PALETTE DE COULEURS UNIFIÉE */
// Couleurs des modes (fond et UI)
color IMPORT_BG = #eeeeee;    // Fond mode import
color CONVERT_BG = #eeeeee;   // Fond mode conversion
color EDIT_BG = #eeeeee;      // Même couleur que CONVERT_BG pour l'édition

// Couleurs de l'interface
color UI_INACTIVE = #dddddd;  // Mode inactif
color UI_EDIT_TAB = #f2f2f2;  // Fond du mode édition sélectionné
color UI_TEXT = #2b2b2b;      // Texte interface
color STROKE_COLOR = #2b2b2b; // Lignes
color POINT_COLOR = #ffca3a;  // Points de contrôle
color ARROW_IN = #8ac926;     // Flèche début (vert)
color ARROW_OUT = #ff595e;    // Flèche fin (rouge)
color SELECTED = #ff595e;     // Élément sélectionné
color ERROR_COLOR = #ff595e;  // Erreurs

// États de l'application
String MODE = "IMPORT";  // IMPORT, CONVERT, EDIT
int errorTimer = 0;
final int ERROR_DURATION = 3000;
String message = "";
boolean showError = false;

// Interface graphique
PShape importIcon, convertIcon, editIcon;
float uiWidth = 40;  // Largeur de la barre d'interface
float uiSectionHeight = 250;  // Hauteur de chaque section

// Variables pour le drag & drop
SDrop drop;
String currentFileName;
File currentFile;
boolean fileLoaded = false;

// Types de fichiers acceptés selon le mode
final String TYPE_SVG = "svg";
final String TYPE_JSON = "json";

// Variables pour le déplacement
PVector offset;
PVector lastMouse;
boolean isDragging = false;
boolean hasUnsavedChanges = false;

// Variables pour la sauvegarde
Button saveButton;
int svgShapeLength = 14; // Pour la génération JSON

// Variables pour le mode EDIT
ArrayList<Line> allLines;
Segment selectedSegment = null;
boolean isStartPoint = false;
PVector dragOffset;

// Classes pour le mode EDIT
class Segment {
  PVector start, end, direction;
  float angle, scale, fScale, seed, seedM;
  int gdFirst, nShapeL, nShapeR;

  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    this.direction = PVector.sub(end, start).normalize();
    this.angle = random(-30, 30);
    this.scale = random(0.19, .222);
    this.fScale = random(30, 50);
    this.gdFirst = round(random(1));
    this.nShapeL = 0;
    this.nShapeR = 0;
    
    // Calcul de la seed basé sur la distance à l'origine
    if (dist(0, 0, start.x, start.y) >= dist(0, 0, end.x, end.y)) {
      this.seedM = this.seed = (dist(0, 0, end.x, end.y)/500);
    } else {
      this.seedM = this.seed = (1/dist(0, 0, start.x, start.y)/500);
    }
  }
}

class Line {
  ArrayList<Segment> segments;

  Line() {
    segments = new ArrayList<Segment>();
  }

  void addSegment(PVector start, PVector end) {
    segments.add(new Segment(start, end));
  }
}

void setup() {
  size(1000, 1000);
  pixelDensity(2);
  
  // Initialisation des vecteurs
  offset = new PVector(0, 0);
  lastMouse = new PVector(0, 0);
  
  // Initialisation du drag & drop
  drop = new SDrop(this);
  
  setupControlP5();
  
  // Charger les icônes SVG
  importIcon = loadShape("import.svg");
  convertIcon = loadShape("convert.svg");
  editIcon = loadShape("edit.svg");
  
  // pour le mode EDIT
  allLines = new ArrayList<Line>();
}

void draw() {
  // Déterminer la couleur de fond selon le mode
  color bgColor;
  switch(MODE) {
    case "IMPORT":
      bgColor = IMPORT_BG;
      break;
    case "CONVERT":
      bgColor = CONVERT_BG;
      break;
    case "EDIT":
      bgColor = EDIT_BG;
      break;
    default:
      bgColor = IMPORT_BG;
  }
  background(bgColor);
  
  // Dessiner l'interface principale
  drawUI(bgColor);
  
  // Gérer l'affichage selon le mode
  switch(MODE) {
    case "IMPORT":
      drawImportMode();
      break;
    case "CONVERT":
      drawConvertMode();
      break;
    case "EDIT":
      drawEditMode();
      break;
  }
  
  // Mise à jour du curseur
  updateCursor();
  
  // Gérer les messages d'erreur
  handleErrorMessages();
}

void drawUI(color currentBgColor) {
  // Fond de la barre d'interface
  noStroke();
  fill(UI_INACTIVE);
  rect(width - uiWidth, 0, uiWidth, height);
  
  // Dessiner les sections pour chaque mode
  drawModeSection("IMPORT", 0, currentBgColor);
  drawModeSection("CONVERT", 1, currentBgColor);
  drawModeSection("EDIT", 2, currentBgColor);
}

void drawModeSection(String modeName, int index, color currentBgColor) {
  float yPos = index * uiSectionHeight;

  // Fond de la section
  noStroke();
  fill(UI_INACTIVE);
  rect(width - uiWidth, yPos, uiWidth, uiSectionHeight);
  
  // Si c'est le mode actif
  if (MODE.equals(modeName)) {
    // Utiliser une couleur différente pour l'onglet d'édition
    if (modeName.equals("EDIT")) {
      fill(UI_EDIT_TAB);
    } else {
      fill(EDIT_BG); // Utiliser la même couleur que le fond
    }
    noStroke();
    rect(width - uiWidth, yPos, uiWidth, uiSectionHeight);
  }
  
  // Icône du mode
  PShape icon = null;
  switch(modeName) {
    case "IMPORT":
      icon = importIcon;
      break;
    case "CONVERT":
      icon = convertIcon;
      break;
    case "EDIT":
      icon = editIcon;
      break;
  }
  
  if (icon != null) {
    shape(icon, width - uiWidth, yPos, uiWidth, uiSectionHeight);
  }
}

void mousePressed(MouseEvent evt) {
  // Gérer d'abord les clics sur l'interface
  // Gérer d'abord les clics sur l'interface
  if (mouseX > width - uiWidth || cp5.isMouseOver()) {
    if (mouseX > width - uiWidth) {
      int section = int(mouseY / uiSectionHeight);
      
      if (section == 0) {  // IMPORT
        MODE = "IMPORT";
        spacingSlider.setVisible(false);
        saveButton.setVisible(false);
        fileLoaded = false;  // Pour réafficher l'invite de dépôt de fichier
      }
      else if (section == 1) {  // CONVERT
        MODE = "CONVERT";
        // Si on vient du mode EDIT, convertir les lignes en courbes
        if (allLines != null && allLines.size() > 0) {
          convertLinesToCurves();
          fileLoaded = true;
          spacingSlider.setVisible(true);
          saveButton.setVisible(true);
        }
      }
      else if (section == 2) {  // EDIT
        if (MODE.equals("CONVERT") && allCurves.size() > 0) {
          convertCurvesToLines();
          spacingSlider.setVisible(false);
        }
        MODE = "EDIT";
        saveButton.setVisible(true);
      }
    }
    return;
  }

  // Gérer les clics selon le mode
  switch(MODE) {
    case "CONVERT":
      handleConvertModeMousePressed();
      break;
    case "EDIT":
      handleEditModeMousePressed(evt);
      break;
    case "IMPORT":
      // Pour l'instant, pas d'action spécifique en mode IMPORT
      break;
  }
}
void handleConvertModeMousePressed() {
  if (!cp5.isMouseOver()) { // Si on n'est pas sur un élément de l'interface
    isDragging = true;
    lastMouse = new PVector(mouseX, mouseY);
  }
}

void handleEditModeMousePressed(MouseEvent evt) {
  isDragging = false;
  if (mouseButton == LEFT) {
    Segment oldSelectedSegment = selectedSegment;
    boolean oldIsStartPoint = isStartPoint;
    selectedSegment = null;

    for (Line line : allLines) {
      for (int i = 0; i < line.segments.size(); i++) {
        Segment segment = line.segments.get(i);

        // Vérifier le point de début
        if (i == 0 && dist(mouseX, mouseY, segment.start.x, segment.start.y) < 10) {
          selectedSegment = segment;
          isStartPoint = true;
          dragOffset = PVector.sub(segment.start, new PVector(mouseX, mouseY));
          if (evt.getCount()==2) {
            int index = line.segments.indexOf(selectedSegment);
            if (index == 0 && isStartPoint) {
              reverseLine(line);
            }
          }
          break;
        }

        // Vérifier le point de fin
        if (i == line.segments.size() - 1 && dist(mouseX, mouseY, segment.end.x, segment.end.y) < 10) {
          selectedSegment = segment;
          isStartPoint = false;
          dragOffset = PVector.sub(segment.end, new PVector(mouseX, mouseY));
          if (evt.getCount()==2) {
            int index = line.segments.indexOf(selectedSegment);
            if (index == line.segments.size() - 1 && !isStartPoint) {
              reverseLine(line);
            }
          }
          break;
        }

        // Points intermédiaires
        if (i < line.segments.size() - 1 && dist(mouseX, mouseY, segment.end.x, segment.end.y) < 10) {
          selectedSegment = segment;
          isStartPoint = false;
          dragOffset = PVector.sub(segment.end, new PVector(mouseX, mouseY));
          break;
        }
      }
      if (selectedSegment != null) break;
    }

    if (selectedSegment != oldSelectedSegment || isStartPoint != oldIsStartPoint) {
      hasUnsavedChanges = true;
    }
  }
}

void mouseDragged() {
  if (MODE.equals("EDIT") && selectedSegment != null) {
    PVector newPos = new PVector(mouseX, mouseY).add(dragOffset);
    if (isStartPoint) {
      selectedSegment.start = newPos;
    } else {
      selectedSegment.end = newPos;
    }
    updateSegmentDirection(selectedSegment);
    updateAdjacentSegments(selectedSegment);
    hasUnsavedChanges = true;
  } else if (MODE.equals("CONVERT") && isDragging) {
    // Code existant pour le déplacement en mode CONVERT
    PVector currentMouse = new PVector(mouseX, mouseY);
    PVector delta = PVector.sub(currentMouse, lastMouse);
    offset.add(delta);
    lastMouse = currentMouse;
    hasUnsavedChanges = true;
  }
}

void keyPressed() {
  if (MODE.equals("EDIT")) {
    if (key == BACKSPACE && selectedSegment != null) {
      deleteSelectedPoint();
    } else if (key == 'r' && selectedSegment != null) {
      for (Line line : allLines) {
        int index = line.segments.indexOf(selectedSegment);
        if (index != -1) {
          if ((index == 0 && isStartPoint) || (index == line.segments.size() - 1 && !isStartPoint)) {
            reverseLine(line);
            hasUnsavedChanges = true;
          }
          break;
        }
      }
    }
  }
}

void mouseReleased() {
  isDragging = false;
}

void showError(String errorMessage) {
  message = errorMessage;
  showError = true;
  errorTimer = millis();
}

void handleErrorMessages() {
  if (showError && millis() - errorTimer < ERROR_DURATION) {
    fill(ERROR_COLOR);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(message, width/2, height - 50);
  } else {
    showError = false;
  }
}

void dropEvent(DropEvent event) {
  // Réinitialiser l'état
  fileLoaded = false;
  currentFile = null;
  
  if (event.isFile()) {
    File file = event.file();
    String fileName = file.getName().toLowerCase();
    
    switch(MODE) {
      case "IMPORT":
        if (fileName.endsWith(".svg")) {
          handleImportDrop(file, fileName);
        } else if (fileName.endsWith(".json")) {
          handleEditDrop(file, fileName);
          MODE = "EDIT";  // Passage automatique en mode EDIT
        } else {
          showError("Seuls les fichiers SVG ou JSON sont acceptés");
        }
        break;
      case "CONVERT":
        if (!fileName.endsWith(".svg")) {
          showError("Seuls les fichiers SVG sont acceptés en mode Convert");
          return;
        }
        handleImportDrop(file, fileName);
        break;
      case "EDIT":
        if (!fileName.endsWith(".json")) {
          showError("Seuls les fichiers JSON sont acceptés en mode Edit");
          return;
        }
        handleEditDrop(file, fileName);
        break;
    }
  }
}

void handleConvertDrop(File file, String fileName) {
  if (!fileName.endsWith(".svg")) {
    showError("Seuls les fichiers SVG sont acceptés en mode Convert");
    return;
  }
  
  if (!isSVGValid(file)) {
    showError("Le fichier SVG n'est pas valide ou ne contient pas de chemins");
    return;
  }
  
  currentFile = file;
  currentFileName = file.getAbsolutePath();
  fileLoaded = true;
}

void handleEditDrop(File file, String fileName) {
  if (!fileName.endsWith(".json")) {
    showError("Seuls les fichiers JSON sont acceptés en mode Edit");
    return;
  }
  
  if (!isJSONValid(file)) {
    showError("Le fichier JSON n'est pas valide ou ne correspond pas au format attendu");
    return;
  }
  
  // Charger le JSON
  allLines = loadJSONStructure(file.getAbsolutePath());
  currentFile = file;
  currentFileName = file.getAbsolutePath();
  fileLoaded = true;
  selectedSegment = null;
  saveButton.setVisible(true);  // Afficher le bouton de sauvegarde
  spacingSlider.setVisible(false);  // S'assurer que le slider est caché
  MODE = "EDIT";
}

boolean isSVGValid(File file) {
  try {
    XML svg = loadXML(file.getAbsolutePath());
    if (svg == null) return false;
    
    // Vérifier que c'est bien un SVG
    String rootName = svg.getName().toLowerCase();
    if (!rootName.equals("svg")) return false;
    
    // Vérifier qu'il contient au moins un élément path
    XML[] paths = svg.getChildren("path");
    return (paths != null && paths.length > 0);
    
  } catch (Exception e) {
    println("Erreur lors de la validation du SVG : " + e.getMessage());
    return false;
  }
}

boolean isJSONValid(File file) {
  try {
    JSONObject json = loadJSONObject(file.getAbsolutePath());
    if (json == null) return false;
    
    // Vérifier la structure attendue
    JSONObject settings = json.getJSONObject("settings");
    JSONArray lines = json.getJSONArray("lines");
    
    return (settings != null && lines != null);
    
  } catch (Exception e) {
    println("Erreur lors de la validation du JSON : " + e.getMessage());
    return false;
  }
}

void drawImportMode() {
  if (!fileLoaded) {
    if (!showError) {
      textAlign(CENTER, CENTER);
      textSize(16);
      fill(UI_TEXT);
      text("Glissez-déposez un fichier SVG ou JSON", width/2, height/2);
      // Éventuellement ajouter une indication plus précise
      textSize(12);
      text("SVG pour convertir, JSON pour éditer", width/2, height/2 + 25);
    }
  }
}

void drawEditMode() {
  if (!fileLoaded) {
    if (!showError) {
      textAlign(CENTER, CENTER);
      textSize(16);
      fill(UI_TEXT);
      text("Glissez-déposez un fichier JSON à éditer", width/2, height/2);
    }
    return;
  }

  for (Line line : allLines) {
    drawLine(line);
  }
  
  if (hasUnsavedChanges) {
    fill(ERROR_COLOR);
    noStroke();
    ellipse(width - 60, 20, 10, 10);
  }
}

/* mode import */
// Variables pour le traitement SVG
ArrayList<ArrayList<PVector>> allCurves = new ArrayList<ArrayList<PVector>>();
float espace = 20;  // Espacement des points
float strokeW = 2;  // Épaisseur des traits
boolean svgLoaded = false;

// Slider pour l'espacement
ControlP5 cp5;
Slider spacingSlider;

void setupControlP5() {
  cp5 = new ControlP5(this);
  
  spacingSlider = cp5.addSlider("spacingControl")
     .setPosition(20, height - 30)
     .setSize(200, 20)
     .setRange(4, 40)
     .setValue(20)
     .setCaptionLabel("espacement des points")
     .setDecimalPrecision(0)
     .setVisible(false)
     .onChange(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         if (svgLoaded) {
           espace = event.getController().getValue();
           reprocessSVG();
           hasUnsavedChanges = true;
         }
       }
     });

  saveButton = cp5.addButton("saveJSON")
     .setPosition(20, 10)
     .setSize(100, 20)
     .setCaptionLabel("Sauvegarder JSON")
     .setVisible(false);

  spacingSlider.getCaptionLabel().setColor(color(25, 25, 25));
}

void handleImportDrop(File file, String fileName) {
  if (!fileName.endsWith(".svg")) {
    showError("Seuls les fichiers SVG sont acceptés en mode Import");
    return;
  }
  
  if (!isSVGValid(file)) {
    showError("Le fichier SVG n'est pas valide ou ne contient pas de chemins");
    return;
  }
  
  // Nettoyer l'état précédent seulement si le nouveau fichier est valide
  fileLoaded = false;
  svgLoaded = false;
  currentFileName = null;
  allCurves.clear();
  allLines.clear();
  
  // Charger le nouveau fichier
  loadSVGFile(file);
  
  currentFile = file;
  currentFileName = file.getAbsolutePath();
  fileLoaded = true;
  svgLoaded = true;
  MODE = "CONVERT"; // Passage automatique en mode conversion
}

void loadSVGFile(File file) {
  try {
    allCurves.clear();
    XML svg = loadXML(file.getAbsolutePath());
    parseSVGPaths(svg);
    println("SVG chargé avec succès : " + file.getName());
  }
  catch (Exception e) {
    showError("Erreur lors du chargement du SVG : " + e.getMessage());
  }
}

void parseSVGPaths(XML svg) {
  XML[] paths = svg.getChildren("path");
  for (XML path : paths) {
    String d = path.getString("d");
    parsePathData(d);
  }
}

void parsePathData(String d) {
  String[] commands = d.trim().split("(?=[MmCcLlHhVvZz])");
  float currentX = 0, currentY = 0;
  float firstX = 0, firstY = 0;
  float x, y, x1, y1, x2, y2;
  ArrayList<PVector> currentCurve = new ArrayList<PVector>();
  ArrayList<PVector> bezierPoints;

  for (String cmd : commands) {
    if (cmd.length() > 0) {
      char command = cmd.charAt(0);
      String[] params = cmd.substring(1).trim().split("[ ,]+");

      switch (command) {
      case 'M': // Moveto absolu
      case 'm': // Moveto relatif
        if (currentCurve.size() > 0) {
          allCurves.add(currentCurve);
          currentCurve = new ArrayList<PVector>();
        }

        x = parseFloat(params[0]);
        y = parseFloat(params[1]);

        if (command == 'm') {
          currentX += x;
          currentY += y;
        } else {
          currentX = x;
          currentY = y;
        }
        firstX = currentX;
        firstY = currentY;
        currentCurve.add(new PVector(currentX, currentY));
        break;

      case 'C': // Cubic Bézier absolu
        x1 = parseFloat(params[0]);
        y1 = parseFloat(params[1]);
        x2 = parseFloat(params[2]);
        y2 = parseFloat(params[3]);
        x = parseFloat(params[4]);
        y = parseFloat(params[5]);

        bezierPoints = discretizeBezier(
          currentX, currentY,
          x1, y1,
          x2, y2,
          x, y
          );
        currentCurve.addAll(bezierPoints);
        currentX = x;
        currentY = y;
        break;

      case 'c': // Cubic Bézier relatif
        x1 = currentX + parseFloat(params[0]);
        y1 = currentY + parseFloat(params[1]);
        x2 = currentX + parseFloat(params[2]);
        y2 = currentY + parseFloat(params[3]);
        x = currentX + parseFloat(params[4]);
        y = currentY + parseFloat(params[5]);

        bezierPoints = discretizeBezier(
          currentX, currentY,
          x1, y1,
          x2, y2,
          x, y
          );
        currentCurve.addAll(bezierPoints);
        currentX = x;
        currentY = y;
        break;

      case 'Z':
      case 'z':
        if (currentCurve.size() > 0) {
          currentCurve.add(new PVector(firstX, firstY));
          allCurves.add(currentCurve);
          currentCurve = new ArrayList<PVector>();
        }
        break;
      }
    }
  }

  if (currentCurve.size() > 0) {
    allCurves.add(currentCurve);
  }
}

ArrayList<PVector> discretizeBezier(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2) {
  ArrayList<PVector> points = new ArrayList<PVector>();

  // Calculer la longueur approximative de la courbe
  float length = estimateBezierLength(x1, y1, cx1, cy1, cx2, cy2, x2, y2);
  int steps = ceil(length / espace);

  // Générer les points équidistants
  for (float t = 0; t <= 1; t += 1.0/steps) {
    float x = bezierPoint(x1, cx1, cx2, x2, t);
    float y = bezierPoint(y1, cy1, cy2, y2, t);
    points.add(new PVector(x, y));
  }

  return points;
}

float estimateBezierLength(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2) {
  float length = 0;
  int steps = 100;
  float prevX = x1;
  float prevY = y1;

  for (int i = 1; i <= steps; i++) {
    float t = i / (float)steps;
    float x = bezierPoint(x1, cx1, cx2, x2, t);
    float y = bezierPoint(y1, cy1, cy2, y2, t);
    length += dist(prevX, prevY, x, y);
    prevX = x;
    prevY = y;
  }

  return length;
}

/* FIN mode Import  */
void drawConvertMode() {
  if (!fileLoaded || !svgLoaded) {
    if (!showError) {
      textAlign(CENTER, CENTER);
      textSize(16);
      fill(UI_TEXT);
      text("Glissez-déposez un fichier SVG à convertir", width/2, height/2);
    }
    return;
  }
  
  // Appliquer la translation globale
  pushMatrix();
  translate(offset.x, offset.y);
  
  for (ArrayList<PVector> curve : allCurves) {
    // Définir le style pour chaque courbe
    stroke(STROKE_COLOR);
    strokeWeight(strokeW);
    
    // Dessiner les lignes
    for (int i = 0; i < curve.size() - 1; i++) {
      PVector p1 = curve.get(i);
      PVector p2 = curve.get(i + 1);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    // Dessiner les points
    fill(POINT_COLOR);
    noStroke();
    for (PVector p : curve) {
      ellipse(p.x, p.y, 5, 5);
    }
  }
  
  popMatrix();
  
  // Indicateur de modifications non sauvegardées
  if (hasUnsavedChanges) {
    fill(ERROR_COLOR);
    noStroke();
    ellipse(width - 60, 20, 10, 10);
  }
  
  // Rendre les contrôles visibles
  if (svgLoaded && MODE.equals("CONVERT")) {
    spacingSlider.setVisible(true);
    saveButton.setVisible(true);
  }
}


/* gestion JSON load et save */
void saveJSON() {
  if (currentFileName != null) {
    // Extraire juste le nom du fichier sans extension
    File file = new File(currentFileName);
    String baseFileName = file.getName();
    baseFileName = baseFileName.substring(0, baseFileName.lastIndexOf('.'));
    
    // Générer le nouveau nom de fichier dans le dossier data
    String newFileName = getNextAvailableFilename(baseFileName + "_points");
    
    saveJSONStructure(newFileName);
    hasUnsavedChanges = false;
    showError("Fichier sauvegardé : " + newFileName + ".json");
  }
}

String getNextAvailableFilename(String baseFilename) {
  // Utiliser sketchPath("data") pour le dossier data du sketch
  File f = new File(sketchPath("data"), baseFilename + ".json");
  if (!f.exists()) {
    return baseFilename;
  }
  
  int version = 1;
  while (true) {
    f = new File(sketchPath("data"), baseFilename + "_v" + version + ".json");
    if (!f.exists()) {
      return baseFilename + "_v" + version;
    }
    version++;
  }
}

void saveJSONStructure(String filename) {
  JSONObject mainJson = new JSONObject();
  JSONObject settings = new JSONObject();
  settings.setFloat("rotMin", 40);
  settings.setFloat("rotMax", -20);
  settings.setFloat("seedIncrement", 0.007994974963366985);
  mainJson.setJSONObject("settings", settings);

  JSONArray linesJson = new JSONArray();

  for (ArrayList<PVector> curve : allCurves) {
    JSONObject lineJson = new JSONObject();
    JSONArray segmentsJson = new JSONArray();

    for (int i = 0; i < curve.size() - 1; i++) {
      PVector start = curve.get(i);
      PVector end = curve.get(i + 1);
      // Ajouter le décalage aux positions
      PVector startOffset = PVector.add(start, offset);
      PVector endOffset = PVector.add(end, offset);
      PVector direction = PVector.sub(endOffset, startOffset).normalize();

      JSONObject segmentJson = new JSONObject();
      segmentJson.setJSONArray("start", new JSONArray().setFloat(0, startOffset.x).setFloat(1, startOffset.y));
      segmentJson.setJSONArray("end", new JSONArray().setFloat(0, endOffset.x).setFloat(1, endOffset.y));
      segmentJson.setJSONArray("direction", new JSONArray().setFloat(0, direction.x).setFloat(1, direction.y));
      segmentJson.setFloat("angle", random(-30, 30));
      segmentJson.setFloat("scale", random(0.19, 0.222));
      segmentJson.setInt("gdFirst", round(random(1)));
      segmentJson.setInt("nShapeL", int(random(svgShapeLength)));
      segmentJson.setInt("nShapeR", int(random(svgShapeLength)));

      float distStart = dist(0, 0, startOffset.x, startOffset.y);
      float distEnd = dist(0, 0, endOffset.x, endOffset.y);
      float seed = (distStart >= distEnd) ? (1/distEnd)/1 : (1/distStart)/1;
      segmentJson.setFloat("seed", seed);

      segmentsJson.append(segmentJson);
    }

    lineJson.setJSONArray("segments", segmentsJson);
    linesJson.append(lineJson);
  }

  mainJson.setJSONArray("lines", linesJson);

  // Sauvegarde directe avec le chemin complet
  saveJSONObject(mainJson, "data/" + filename + ".json");
}

ArrayList<Line> loadJSONStructure(String filename) {
  ArrayList<Line> lines = new ArrayList<Line>();

  // Charger le fichier JSON principal
  JSONObject mainJson = loadJSONObject(filename);
  if (mainJson == null) {
    println("Impossible de charger le fichier JSON : " + filename);
    return lines;
  }

  // Récupérer et appliquer les settings
  JSONObject settings = mainJson.getJSONObject("settings");
  // TODO: Gérer les settings si nécessaire

  // Récupérer le tableau de lignes
  JSONArray linesArray = mainJson.getJSONArray("lines");

  // Pour chaque ligne dans le JSON
  for (int i = 0; i < linesArray.size(); i++) {
    JSONObject lineJson = linesArray.getJSONObject(i);
    Line line = new Line();

    // Récupérer les segments
    JSONArray segmentsJson = lineJson.getJSONArray("segments");
    for (int j = 0; j < segmentsJson.size(); j++) {
      JSONObject segmentJson = segmentsJson.getJSONObject(j);

      JSONArray startJson = segmentJson.getJSONArray("start");
      PVector start = new PVector(startJson.getFloat(0), startJson.getFloat(1));

      JSONArray endJson = segmentJson.getJSONArray("end");
      PVector end = new PVector(endJson.getFloat(0), endJson.getFloat(1));

      JSONArray directionJson = segmentJson.getJSONArray("direction");
      PVector direction = new PVector(directionJson.getFloat(0), directionJson.getFloat(1));

      Segment segment = new Segment(start, end);
      segment.direction = direction;
      segment.angle = segmentJson.getFloat("angle");
      segment.scale = segmentJson.getFloat("scale");
      segment.gdFirst = segmentJson.getInt("gdFirst");
      segment.nShapeL = segmentJson.getInt("nShapeL");
      segment.nShapeR = segmentJson.getInt("nShapeR");
      segment.seed = segmentJson.getFloat("seed");
      segment.seedM = segmentJson.getFloat("seed");

      line.segments.add(segment);
    }

    lines.add(line);
  }

  println("Fichier JSON chargé avec succès : " + filename);
  return lines;
}

void reprocessSVG() {
  if (currentFile == null) return;
  
  // Réinitialiser les courbes
  allCurves.clear();
  
  // Recharger et parser le SVG avec les nouveaux paramètres
  XML svg = loadXML(currentFile.getAbsolutePath());
  parseSVGPaths(svg);
}

/* Méthodes EDIT */

void drawLine(Line line) {
  // D'abord, dessiner tous les segments
  for (Segment segment : line.segments) {
    stroke(STROKE_COLOR);
    strokeWeight(strokeW);
    line(segment.start.x, segment.start.y, segment.end.x, segment.end.y);
  }

  // Ensuite, dessiner les points de contrôle et les triangles
  for (int i = 0; i <= line.segments.size(); i++) {
    boolean isSelected = false;
    PVector pointPosition;
    float direction;
    noStroke();

    if (i == 0) {
      // Premier point de la ligne (triangle vert)
      Segment firstSegment = line.segments.get(0);
      pointPosition = firstSegment.start;
      direction = firstSegment.direction.heading();
      isSelected = (firstSegment == selectedSegment && isStartPoint);

      pushMatrix();
      translate(pointPosition.x, pointPosition.y);
      rotate(direction);
      if (isSelected) {
        fill(SELECTED);
      } else {
        fill(ARROW_IN);
      }
      drawTriangle(25);
      fill(255);
      circle(0, 0, 5);
      popMatrix();
    } 
    else if (i == line.segments.size()) {
      // Dernier point de la ligne (triangle rouge)
      Segment lastSegment = line.segments.get(i - 1);
      pointPosition = lastSegment.end;
      direction = lastSegment.direction.heading();
      isSelected = (lastSegment == selectedSegment && !isStartPoint);

      pushMatrix();
      translate(pointPosition.x, pointPosition.y);
      rotate(direction);
      if (isSelected) {
        fill(SELECTED);
      } else {
        fill(ARROW_OUT);
      }
      drawTriangle(15);
      fill(UI_TEXT);
      circle(0, 0, 5);
      popMatrix();
    } 
    else {
      // Points intermédiaires
      Segment currentSegment = line.segments.get(i);
      pointPosition = currentSegment.start;
      isSelected = (currentSegment == selectedSegment && isStartPoint) ||
        (line.segments.get(i-1) == selectedSegment && !isStartPoint);

      fill(255);
      if (isSelected) {
        fill(SELECTED);
      } else {
        fill(POINT_COLOR);
      }
      circle(pointPosition.x, pointPosition.y, 20);
    }
  }
}

void drawTriangle(float size) {
  beginShape();
  triangle(size, 0, -size/1.5, size/1.5, -size/1.5, -size/1.5);
  endShape(CLOSE);
}

/* INVERSER LE SENS D'UN SEGMENT */
void reverseLine(Line line) {
  ArrayList<Segment> newSegments = new ArrayList<Segment>();

  // Parcourir les segments en sens inverse
  for (int i = line.segments.size() - 1; i >= 0; i--) {
    Segment oldSegment = line.segments.get(i);
    Segment newSegment = new Segment(oldSegment.end.copy(), oldSegment.start.copy());

    // Copier les autres propriétés
    newSegment.scale = oldSegment.scale;
    newSegment.angle = oldSegment.angle;
    newSegment.gdFirst = oldSegment.gdFirst;
    newSegment.nShapeL = oldSegment.nShapeL;
    newSegment.nShapeR = oldSegment.nShapeR;
    newSegment.seed = oldSegment.seed;
    newSegment.seedM = oldSegment.seedM;

    newSegments.add(newSegment);
  }

  // Remplacer les segments
  line.segments = newSegments;

  // Mettre à jour les directions de tous les segments
  for (Segment segment : line.segments) {
    updateSegmentDirection(segment);
  }

  // Réinitialiser la sélection
  selectedSegment = null;
  isStartPoint = false;
  hasUnsavedChanges = true;
}

/* transformation du mode CONVERT à EDIT */

void convertCurvesToLines() {
  allLines = new ArrayList<Line>();
  
  for (ArrayList<PVector> curve : allCurves) {
    Line line = new Line();
    for (int i = 0; i < curve.size() - 1; i++) {
      // Ajouter l'offset aux points avant de créer les segments
      PVector start = PVector.add(curve.get(i), offset);
      PVector end = PVector.add(curve.get(i + 1), offset);
      line.addSegment(start, end);
    }
    allLines.add(line);
  }
  
  // Réinitialiser l'offset puisqu'il est maintenant inclus dans les positions
  offset = new PVector(0, 0);
  fileLoaded = true;
}
void convertLinesToCurves() {
  allCurves = new ArrayList<ArrayList<PVector>>();
  
  for (Line line : allLines) {
    ArrayList<PVector> curve = new ArrayList<PVector>();
    // Ajouter le premier point
    if (line.segments.size() > 0) {
      curve.add(line.segments.get(0).start);
      // Ajouter tous les points de fin
      for (Segment segment : line.segments) {
        curve.add(segment.end);
      }
    }
    allCurves.add(curve);
  }
  svgLoaded = true;
}
void updateSegmentDirection(Segment segment) {
  segment.direction = PVector.sub(segment.end, segment.start).normalize();
}

void updateAdjacentSegments(Segment currentSegment) {
  for (Line line : allLines) {
    int index = line.segments.indexOf(currentSegment);
    if (index != -1) {
      // Mettre à jour le segment précédent si ce n'est pas le premier
      if (index > 0) {
        Segment prevSegment = line.segments.get(index - 1);
        prevSegment.end = currentSegment.start;
        updateSegmentDirection(prevSegment);
      }
      // Mettre à jour le segment suivant si ce n'est pas le dernier
      if (index < line.segments.size() - 1) {
        Segment nextSegment = line.segments.get(index + 1);
        nextSegment.start = currentSegment.end;
        updateSegmentDirection(nextSegment);
      }
      break;
    }
  }
}
/* EFFACER UN POINT */
void deleteSelectedPoint() {
  for (Line line : allLines) {
    int index = line.segments.indexOf(selectedSegment);
    if (index != -1) {
      // Ne peut pas supprimer le seul segment d'une ligne
      if (line.segments.size() <= 1) {
        return;
      }

      if (isStartPoint) {
        // Supprimer le point de début (uniquement possible pour le premier segment)
        if (index == 0 && line.segments.size() > 1) {
          line.segments.remove(0);
        }
      } else {
        // Si c'est un point final
        if (index == line.segments.size() - 1) {
          line.segments.remove(index);
        }
        // Si c'est un point intermédiaire
        else if (index < line.segments.size() - 1) {
          Segment nextSegment = line.segments.get(index + 1);
          nextSegment.start = selectedSegment.start;
          updateSegmentDirection(nextSegment);
          line.segments.remove(index);
        }
      }
      selectedSegment = null;
      hasUnsavedChanges = true;
      break;
    }
  }
}

/*  gestion des rollover */

void updateCursor() {
  switch(MODE) {
    case "IMPORT":
      if (mouseX > width - uiWidth && mouseY > uiSectionHeight && mouseY < height - uiSectionHeight ) {
        cursor(HAND);
      } else {
        cursor(ARROW);
      }
      break;
    case "CONVERT":
      if (mouseX < width - uiWidth && !cp5.isMouseOver()) {
        cursor(MOVE);
      } else {
        cursor(HAND);
      }
      break;
      
    case "EDIT":
      boolean overPoint = false;
      
      // Vérifier si on survole un point ou un triangle
      for (Line line : allLines) {
        for (int i = 0; i < line.segments.size(); i++) {
          Segment segment = line.segments.get(i);
          
          // Premier point (triangle)
          if (i == 0 && dist(mouseX, mouseY, segment.start.x, segment.start.y) < 10) {
            overPoint = true;
            break;
          }
          
          // Point final (triangle)
          if (i == line.segments.size() - 1 && dist(mouseX, mouseY, segment.end.x, segment.end.y) < 10) {
            overPoint = true;
            break;
          }
          
          // Points intermédiaires
          if (dist(mouseX, mouseY, segment.end.x, segment.end.y) < 10) {
            overPoint = true;
            break;
          }
        }
        if (overPoint) break;
      }
      
      if (overPoint) {
        cursor(HAND);
      } else {
        cursor(ARROW);
      }
      break;
      
    default:
      cursor(ARROW);
      break;
  }
}
