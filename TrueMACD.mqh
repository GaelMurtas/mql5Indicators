//Personal MACD class for indicators and expert

#ifndef _MACD
#define _MACD

#include "Utils.mqh"
#include "SMA.mqh"
class MACD
  {
  public :
   //enumération des couleurs possible
   enum Color{
      green,
      red,
      grey
   };
   private:
   //--- indicator values
   double            line[];
   double            signal[];
   double            histo[];
   Color histoCol[];

   // imputs value
   uint               maShortLength;
   uint               maLongLength;
   uint               signalLength;
   MA::MAtype         maType;
   uint               N;//nombre de valeur du MACD à calculer

   //calculs intermédiaire
   MA            maShort;
   MA            maLong;
   uint           maCalc;//plus ancienne valeur de moyenne mobile a calculer
   uint           maxPeriod;//plus ancienne valeur a prendre en compte pour le cacul de la valeur de l'intiteur actuel

   // battribut intermédiaire calculs function
   void inputInit(const double & prices[]){
      //initatialisation des attribut
      maxPeriod = N + maLongLength + signalLength - 2;
      maCalc = N + signalLength - 1;
      MA tmpMA1(maType, maShortLength, maCalc, prices);
      MA tmpMA2(maType, maLongLength, maCalc, prices);
      maShort = tmpMA1;
      maLong = tmpMA2;
      //allocations des ressources
      ArrayResize(line,maCalc);
      ArrayResize(signal,N);
      ArrayResize(histo,N);
      ArrayResize(histoCol,N);
    }
 
   void ligneCalul(){
      for(uint i = 0; i < maCalc; i++){
         line[i] = maShort.get(i) - maLong.get(i);
         }
         //Print("MACDCALCUL");
      }
   void signialCalcul(){
      MA lineMA(maType, signalLength,N,line);
      for(uint i = 0; i < N; i++){
         signal[i] = lineMA.get(i);
      }
   }
   
   void histoCalcul(){
      for(uint i = 0; i < N; i++){
         histo[i] = line[i]-signal[i];
      }
   }
   
   void colorCalcul(){
      for(uint i = 0; i < (N-1); i++){
         if((histo[i] > 0) && (histo[i] > histo[i+1])){histoCol[i]=green;}
         else{
            if((histo[i] < 0) && (histo[i] < histo[i+1])){histoCol[i]=red;}
            else {histoCol[i] = grey;}
         }
      }
      histoCol[N-1]=grey;
   }

public :
   //Constructeur & destructeur
   //MACD(const uint &);                  
   //MACD(const int &, const int &, const int &);
   MACD(const uint & l1, const uint & l2, const uint & ls, const MA::MAtype& type, const uint & n, const double & prices[]): N(n) {
      maLongLength = max(l1,l2);
      maShortLength = min(l1,l2);
      signalLength = ls;
      maType = type;
      //vérification de la taille de prices
      if(ArraySize(prices) < (maLongLength + signalLength + N -2)){
         Print("MACD CONSTRUCTION ERROR : needed ", maLongLength + signalLength + N -2, " prices and only ", ArraySize(prices), " disponible !");
      }
      inputInit(prices);
      ligneCalul();
      signialCalcul();
      histoCalcul();
      colorCalcul();
   }
   
   ~MACD(){
      ArrayFree(line);
      ArrayFree(signal);
      ArrayFree(histo);
      ArrayFree(histoCol);
   }
   
   //accesseurs par copie
   double getLine(const uint i) const{
      if (i >= N){
         Print("MACD ERROR LINE: access to element ", i, " tab size ", N, " !");
      }
      return line[i];
   }
   
   double getSignal(const uint i) const{
      if (i >= N){
         Print("MACD ERROR Signal: access to element ", i, " tab size ", N, " !");
      }
      return signal[i];
   }
   
   
   double getHisto(const uint i) const{
      if (i >= N){
         Print("MACD ERROR HISTO: access to element ", i, " tab size ", N, " !");
      }
      return histo[i];
   }
   
   double getColor(const uint i) const{
      if (i >= N){
         Print("MACD ERROR COLOR: access to element ", i, " tab size ", N, " !");
      }
      return histoCol[i];
   }
   
   uint size() const{
   return N;
   }
};

#endif