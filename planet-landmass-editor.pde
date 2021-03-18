import java.util.LinkedList;

//ui constants
final int HEIGHT = 500;
final int MAP_W = 1000;
final int MAP_H = HEIGHT;
final int GUI_W = 400;
final int GUI_H = HEIGHT;
final color GUI_COLOR = 220;
final color RED = color(255, 0, 0);

//height mapping
final int MAXH = 20000;
final int MINH = 0;
final int DIFF = abs(MAXH - MINH);

//other params
final int SFT_STEP = 10;
final int THR_STEP = (int)(DIFF/100.0);
final int H_STEP = (int) (255*500/(float)(DIFF));
final int MIN_BSIZE = 10;
final int MAX_BSIZE = 100;
final float BLR_STEP = 0.1;
final int MAX_UNDO = 20;

PImage img;
float H[], B[];
PGraphics ui, map, gui;
LinkedList<float[]> undo, redo;

//parameters
int thr = (int)(DIFF * 0.5);
int shiftW = 0;
float blurAmt = 0;
int min = 0;
int max = 255;
int brushSize = 10;

boolean borders = false;
boolean editMode = false;
boolean changeMade = true;
boolean changedBlur = true;
boolean clicking = false;
boolean invert = false;

//user interaction
void keyPressed(){
  switch(key) {
  case '4': 
    thr -= THR_STEP;
    if(thr < 0) thr = MINH;
    break;
  case '6': 
    thr += THR_STEP;
    if(thr > MAXH) thr = MAXH;
    break;
  case '1': 
    shiftW -= SFT_STEP;
    shiftW %= MAP_W;
    break; 
  case'3': 
    shiftW += SFT_STEP;
    shiftW %= MAP_W;
    break;  
  case '2': 
    blurAmt -= BLR_STEP;
    if(blurAmt < 0) blurAmt = 0;
    changedBlur = true;
    break;  
  case '5': 
    blurAmt += BLR_STEP;
    if(blurAmt > 1) blurAmt = 1;
    changedBlur = true;
    break; 
  case '*': 
    max += H_STEP;
    if(max > 255) max = 255;
    break;
  case '9': 
    max -= H_STEP;
    if(max <= min) max = min + 1;
    break;
  case '/': 
    min += H_STEP;
    if(min > max) min = max;
    break;
  case '8': 
    min -= H_STEP;
    if(min < 0) min = 0;
    break;
  case 'c': 
    borders = !borders;
    break;  
  case 'e':
    editMode = ! editMode;
    ui.beginDraw();
    ui.background(0, 0);
    ui.endDraw();
    break;
  case 'u':
    if(!undo.isEmpty()){
      addToRedo();
      B = undo.pop();
    }
    break;
  case 'r':
    if(!redo.isEmpty()){
      addToUndo();
      B = redo.pop();
    }
    break;
  case 's':
    selectOutput("Export map as png...", "saveSelected");
    break;
  case 'i':
    invert = !invert;
    break;
  }
  key = '\\';
  changeMade = true;
}

//save map
void saveSelected(File f){
  boolean editState = editMode;
  boolean borderState = borders;
  editMode = false;
  borders = false;
  drawMap();
  map.save(f.getAbsolutePath()+".png");
  editMode = editState;
  borders = borderState;
  changeMade = true;
}

void fileSelected(File f){
  //img = loadImage("25000 iterations.png");
  img = loadImage(f.getAbsolutePath());
  img.loadPixels();
}

void settings(){
  selectInput("Select source image...", "fileSelected");
  size(MAP_W+GUI_W, HEIGHT);
  //fileSelected(null);
}

void setup(){
  while(img == null) print("");
  //user interface
  ui = createGraphics(MAP_W, MAP_H);
  //map
  map = createGraphics(MAP_W, MAP_H);
  //gui
  gui = createGraphics(GUI_W, GUI_H);
  //height vals
  H = new float[width*height];
  //brush
  B = new float[width*height];
  //undo
  undo = new LinkedList<float[]>();
  redo = new LinkedList<float[]>();
  addToUndo();
}

//to set brush size
void mouseWheel(MouseEvent ev){
  if(!editMode) return;
  float e = ev.getCount();
  if(e > 0) brushSize -= 10;
  else brushSize += 10;
  brushSize = constrain(brushSize, MIN_BSIZE, MAX_BSIZE);
}

//to use brush
void mouseDragged(){
  mouseClicked();
}

void mouseReleased(){
  clicking = false;
}

void mouseClicked(){
  if(!editMode) return;
  if(!clicking) addToUndo();
  clicking = true;
  modifyTerrain(mouseX - GUI_W, mouseY, mouseButton);
}

void draw(){
  //reblur image only if using different blur amount
  if(changedBlur){
    PImage src = img.copy();
    src.filter(BLUR, blurAmt);
    for(int i = 0; i < img.pixels.length; i++) H[i] = map(src.pixels[i], color(0), color(255), 0, 1);
    changedBlur = false;
  }
  //update map only if some value is changed
  if(changeMade) {
    gui();
    drawMap();
    changeMade = false;
  }
  //if using brush don't update background map
  if(editMode){
    ui.beginDraw();
    ui.background(0, 0);
    ui.noFill();
    ui.strokeWeight(2);
    ui.stroke(255, 0, 0);
    ui.circle(mouseX - GUI_W, mouseY, brushSize);
    ui.endDraw();
    gui();
  }
  //render all graphics
  background(0);
  image(gui, 0, 0);
  image(map, GUI_W, 0);
  image(ui, GUI_W, 0);
}

int index(int x, int y){
  if(x >= MAP_W || x < 0 || y < 0 || y >= MAP_H) return -1;
  return y*MAP_W+x;
}

void drawMap(){
    map.beginDraw();
    map.loadPixels();
    for(int x = 0; x < MAP_W; x++){
        for(int y = 0; y < MAP_H; y++){
          int x2 = x - shiftW;
          int y2 = y;
          int i2 = index((MAP_W + x2)%MAP_W, (y2 + MAP_H)%MAP_H);
          float tmpH = H[i2] + B[i2];
          if(invert) tmpH = 1 - tmpH;
          int h = (int)(constrain(tmpH, 0, 1) * DIFF) + MINH;
          int index = index(x, y);
          if(h > thr){
            int newH = (int)map(h, thr, MAXH, min, max);
            map.pixels[index] = color(newH);
          } else if(borders && abs(h-thr) <= THR_STEP) map.pixels[index] = color(255, 0, 0);
          else map.pixels[index] = color(0, 0);
      }
    }
    map.updatePixels();
    map.endDraw();
}

//brush
void modifyTerrain(int x_, int y_, int type){
  int dir = type == LEFT ? 1 : type == RIGHT ? -1 : 0;
  if(invert) dir *= -1;
  x_ -= shiftW;
  for(int x = x_ - brushSize/2; x < x_ + brushSize/2; x++){
    for(int y = y_ - brushSize/2; y < y_ + brushSize/2; y++){
      float dist = dist(x_, y_, x, y);
      if(dist <= brushSize/2){
        float perc = pow(1 - dist/brushSize, 3);
        int index = index((x + MAP_W)%MAP_W, y);
        if(index != -1){
          B[index] += type == CENTER ? -B[index]*perc : 0.01 * dir * perc;
          if(B[index] > 1 - H[index]) B[index] = 1 - H[index];
          else if(B[index] < -H[index]) B[index] = -H[index];
        }
      }
    }
  }
  changeMade = true;
}

//undoes
void addToUndo(){
  float b[] = new float[B.length];
  for(int i = 0; i < B.length; i++) b[i] = B[i];
  undo.push(b);
  if(undo.size() > MAX_UNDO) undo.removeLast();
}

//redoes
void addToRedo(){
  float b[] = new float[B.length];
  for(int i = 0; i < B.length; i++) b[i] = B[i];
  redo.push(b);
  if(redo.size() > MAX_UNDO) redo.removeLast();
}

//draw gui
void gui(){
  gui.beginDraw();
  gui.background(GUI_COLOR);
  gui.rectMode(CENTER);
  gui.noFill();
  gui.stroke(0);
  gui.rect(GUI_W/2, GUI_H/2, GUI_W, GUI_H);
  
  gui.textAlign(CENTER);
  int c = 8;
  int k = 14;
  int i = 2;
  guiText("Planet Landmass Editor", 22, RED, GUI_W/2, GUI_H/k);
  
  gui.textAlign(LEFT);
  guiText("Sea level (4 - 6): " + thr + " m", 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Min height above sea level (8 - /): " + (int)((MAXH/2)*min/255.0) + " m", 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Max height above sea level (9 - *): " + (int)((MAXH/2)*max/255.0) + " m", 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Blur amount (2 - 5): " + blurAmt, 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Showing coastline (c): " + borders, 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Edit mode (e): " + editMode +
          (editMode ? ", brush size: " + brushSize : ""),
          15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Inverting (i): " + invert, 15, 0, GUI_W/c, i++*GUI_H/k);
  guiText("Horizontal shifting (1 - 3): " + shiftW, 15, 0, GUI_W/c, i++*GUI_H/k);
  
  guiText("Press 's' to save", 15, RED, GUI_W/c, i++*GUI_H/k);
  guiText("left/right click to increase/decrease height", 15, RED, GUI_W/c, i++*GUI_H/k);
  guiText("middle click to erase", 15, RED, GUI_W/c, i++*GUI_H/k);
  guiText("u/r to undo/redo", 15, RED, GUI_W/c, i++*GUI_H/k);
  gui.textAlign(CENTER);
  guiText("Copyright (C) 2021  Marco Amerotti", 10, 0, GUI_W/2, 490);
  
  gui.endDraw();
}

//shortcut to draw text on gui
void guiText(String s, int size, color c, int x, int y){
  gui.fill(c);
  gui.textSize(size);
  gui.text(s, x, y);
}
