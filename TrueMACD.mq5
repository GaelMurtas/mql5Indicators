//+------------------------------------------------------------------+
//|                                                     TrueMACD.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//---- plot TSI
#property indicator_label1  "MACD_line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "MACD_signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label3  "MACD_histo"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen, clrRed, clrSilver
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
 
 #include "TrueMACD.mqh"
 
//--- input parameters
input unsigned int _ma_length_1 = 26;
input unsigned int _ma_length_2 = 12;
input unsigned int _signal_length = 9;
input MA::MAtype maType = MA::SMA;

//+------------------------------------------------------------------+
//| Custom indicator global variables                                |
//+------------------------------------------------------------------+ 

double LineBuffer[]; 
double SignalBuffer[];
double HistoBuffer[];
double ColorBuffer[];
  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HistoBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorBuffer,INDICATOR_COLOR_INDEX);
   
   //Specify the number of color indexes, used in the graphic plot
   PlotIndexSetInteger(2,PLOT_COLOR_INDEXES,3);

//Specify colors for each index
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrGreen);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,1,clrRed);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,2,clrSilver);
   
   //initialition des valeurs inutiles
   /*for(uint i=0;i<(max(_ma_length_1,_ma_length_2)+_signal_length-2);i++)
     {
      LineBuffer[i] = 0;
      SignalBuffer[i] = 0;
      HistoBuffer[i] = 0;
      ColorBuffer[i] = 2;
     }*/

   return(INIT_SUCCEEDED);  
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if (IsStopped()) return(0);
   //plus longue ma
   uint ma_length = max(_ma_length_1,_ma_length_2);
   //première valeur à calculer
   uint start = max(prev_calculated-1, ma_length + _signal_length - 2);
   //taille du tableau de prix à prendre en compte
   uint size = rates_total - start + ma_length +_signal_length -2;
   //tableau contenant seulement les dernier prix nécessaire au calcul dans l'ordre du plus récent au plus ancien
   double lastPrices[];
   ArrayResize(lastPrices,size);
   uint j = size-1;
   for(uint i = (start-ma_length-_signal_length+2); i < rates_total; i++)
     {
      //Print(i," ", start-tmp);
      lastPrices[j] = close[i];
      j--;
     }
   //nombre de valeur de MACD à calculer  
   uint n = max(rates_total-start,1);//1 car prev calculated peut être égal a rates total
   MACD macd (_ma_length_1, _ma_length_2, _signal_length, maType, n, lastPrices);
   
   // remplissage des buffer a dessiner
   for(uint i=start;i<rates_total;i++)
     {
      uint tmp = rates_total-i-1;
      //Print(i, " ", rates_total, " ", tmp, " ", ma.tabSize());
      LineBuffer[i] = macd.getLine(tmp);
      SignalBuffer[i] = macd.getSignal(tmp);
      HistoBuffer[i] = macd.getHisto(tmp);
      if(macd.getColor(tmp) == MACD::green){ColorBuffer[i]=0;}
      else{
         if(macd.getColor(tmp) == MACD::red){ColorBuffer[i]=1;}
         else ColorBuffer[i] = 2;
      }
     }
     
     ArrayFree(lastPrices);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
