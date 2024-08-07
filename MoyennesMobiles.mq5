//+------------------------------------------------------------------+
//|                                              MoyennesMobiles.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MoyenneMobile
#property indicator_label1  "MoyenneMobile"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#include "SMA.mqh"
//input buffer
input uint _ma_length = 20;
input MA::MAtype _maType = MA::SMA;

//--- indicator buffers
double         MMbuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MMbuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,_ma_length-1);
//---
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
//---
   if (IsStopped()) return(0);
   //if(prev_calculated==rates_total) return(rates_total);
   //première valeur à calculer
   uint start = max(prev_calculated-1, _ma_length-1);
   //taille du tableau de prix à prendre en compte
   uint size = rates_total - start + _ma_length -1;
   //tableau contenant seulement les dernier prix nécessaire au calcul dans l'ordre du plus récent au plus ancien
   double lastPrices[];
   ArrayResize(lastPrices,size);
   uint j = size-1;
   for(uint i = (start-_ma_length+1); i < rates_total; i++)
     {
      //Print(i," ", start-tmp);
      lastPrices[j] = close[i];
      j--;
     }
   uint n = max(rates_total-start,1);//1 car prev calculated peut être égal a rates total
   MA ma (_maType, _ma_length, n, lastPrices);
   
   // remplissage des buffer a dessiner
   for(uint i=start;i<rates_total;i++)
     {
      uint tmp = rates_total-i-1;;
      MMbuffer[i] = ma.get(tmp);
      }
      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
