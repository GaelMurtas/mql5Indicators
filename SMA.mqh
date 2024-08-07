//Persnal simple moving average class

#ifndef _SMA
#define _SMA

#include "Utils.mqh"

class MA
{
   public:
   //differents type de moyenne mobiles
   enum MAtype{SMA, EMA};
   
   private:
      double value[];//les valeur de la SMA value[0] étant la plus récente
      double coeffEMA[];
      double valueEMA[];
      uint length;
      uint N;
      MAtype type;
      
      //fonction utilitaire
      void calculValues(const double & price[]){
         if (ArraySize(price) < (N+length-1)){
         Print("MA Erreur in calculValues : entrie array too small");
         }
         //calcul pour de value pour le cas d'une SMA, sert également de cas de base pour le cas EMA
         ArrayResize(value,N);
         value[0] = price[0];
         for(uint i = 1; i<length; i++){
            value[0] = value[0] + price[i];
         }
         value[0]=value[0]/length;
         for(uint i=1; i < N; i++){
            value[i]=value[i-1]- price[(i-1)]/length + price[(i+length-1)]/length;
         }
         if(type==EMA){//algo Perso pour ENA en O(length)
            ArrayResize(valueEMA,N+length-1);
            //calcul du coeff de lissage
            double lambda = (double)2/(length+1);/*
            valueEMA[N+length-2]= lambda*price[N+length-2] + (1-lambda)*value[N-1];
            for(uint i=N+length-2; (i+1) > N; i--){
               valueEMA[i-1]=price[i-1]*lambda + valueEMA[i]*(1-lambda);
            }*/
            valueEMA[N-1]=value[N-1]*pow(1-lambda,length);
               for(uint i=0; i < length; i++){
                  valueEMA[N-1]=valueEMA[N-1]+price[i+N-1]*lambda*pow(1-lambda,i);
               }
            for(uint i = N-1; (i+1)>1; i--){
               valueEMA[i-1] = lambda*price[i-1] + (1-lambda)*(valueEMA[i]-lambda*pow(1-lambda, length-1)*price[i+length-1]-pow(1-lambda, length)*value[i])+pow(1-lambda, length)*value[i-1];
            }
            //for(uint n=1; n<=N; n++){
               //par formule de récurrence
               /*valueEMA[n+length-2]= lambda*price[n+length-2] + (1-lambda)*value[n-1];
               for(uint i=n+length-2; i > (n-1); i--){
                  valueEMA[i-1]=price[i-1]*lambda + valueEMA[i]*(1-lambda);
               }*/
               //par formule de somme
               /*valueEMA[n-1]=value[n-1]*pow(1-lambda,length);
               for(uint i=0; i < length; i++){
                  valueEMA[n-1]=valueEMA[n-1]+price[i+n-1]*lambda*pow(1-lambda,i);
               }*/
            //}
         }
      }
      
   public:
   
      MA(): length(0), N(0)
      {
      }
      
      MA(const MAtype & t, const uint & l,const uint & n,const double & price[]): type(t), length(l), N(n)
      {
         calculValues(price);
      }
      
      ~MA(){
      ArrayFree(value);
      }
      
      //acceseurs par copie avec le bon décalage
      double get(const uint & i) const{
         if (i > (N-1)){
            Print("MA access byond limit !");
            Print ("Access :");
            Print (i);
            Print ("Limit :");
            Print (length);
            }
          if(type == SMA){
          return value[i];
          }
         return valueEMA[i];
      }
      
      uint maSize() const{
      return length;
      }
      
      uint tabSize() const{
      return N;
      }
};

#endif 