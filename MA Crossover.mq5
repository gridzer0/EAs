//+------------------------------------------------------------------+
//|                                                 MA Crossover.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//trade execution libs
#include <Trade/Trade.mqh>
CTrade trade;

   //trade parameters
double stopLoss = 25;
double takeProfit = 100;
double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
double tradeVolume = 1;


//input variables
input int inputFastPeriod = 7;  //fast MA period
input int inputSlowPeriod = 21;  //slow MA period

//global variables
int handleSlowMA;
int handleFastMA;

//array declaration
double arrayFastMA[];
double arraySlowMA[];


//copied buffers declaration
int copySlowMA;
int copyFastMA;

//onInit
int OnInit()
  {
  //fast period validity check
   if (inputFastPeriod <= 0)
      {
         printf("invalid fast period value");
         ExpertRemove();
      }
   
   //slow period validity check
   if (inputSlowPeriod <= 0)
      {
         printf("invalid slow period value");
         ExpertRemove();
         
      }   
      
   //fast EMA > slow EMA check
   if(inputFastPeriod >= inputSlowPeriod)
      {
         printf("fast MA period cannot be > slow MA period");
         ExpertRemove();   
      }
      
    //fast MA handle creation
    handleFastMA = iMA(_Symbol,PERIOD_CURRENT,inputFastPeriod,0,MODE_SMA,PRICE_CLOSE);
    
    //fast MA handle validity check
    if(handleFastMA == INVALID_HANDLE)
    {
      printf("error creating fast MA handle",GetLastError());
      ExpertRemove();
    }
    
    //slow MA handle creation
    handleSlowMA = iMA(_Symbol,PERIOD_CURRENT,inputSlowPeriod,0,MODE_SMA,PRICE_CLOSE);
    
    //slow MA handle validity check
    if(handleSlowMA == INVALID_HANDLE)
    {
      printf("error creating slow MA handle",GetLastError());
      ExpertRemove();
    }
    
    //array indexing reversal
    ArraySetAsSeries(arrayFastMA,true);
    ArraySetAsSeries(arraySlowMA,true);
    
   //start message
   printf("EA started");
   return(INIT_SUCCEEDED);
  }
  
//onDeinit
void OnDeinit(const int reason)
  {
  //fast MA handle release
  if(handleFastMA != INVALID_HANDLE)
  {
   IndicatorRelease(handleFastMA);
  }
  
  //slow MA handle release
  if(handleSlowMA != INVALID_HANDLE)
  {
   IndicatorRelease(handleSlowMA);
  }
  
  //deinit msg
   printf("EA stopped");
  }

//onTick
void OnTick()
  {
  

   
   
  //fast MA buffer copy
   copyFastMA = CopyBuffer(handleFastMA,0,0,2,arrayFastMA);
   
  //fast MA validity check
   if(copyFastMA != 2)
   {
      printf("CopyBuffer error: fast MA", GetLastError());
   }
   
  //slow MA buffer copy
   copySlowMA = CopyBuffer(handleSlowMA,0,0,2,arraySlowMA);
   
  //slow MA validity check
   if(copySlowMA != 2)
   {
      printf("CopyBuffer error: slow MA", GetLastError());
   }
   
   Comment(
           "Fast[0]:" ,arrayFastMA[0], "\n",
           "Fast[1]:" ,arrayFastMA[1], "\n",
           "Slow[0]:" ,arraySlowMA[0], "\n",
           "Slow[1]:" ,arraySlowMA[1], "\n"
          );
          
   //logic
   if(arrayFastMA[0] > arraySlowMA [0] && arrayFastMA[1] < arraySlowMA[1])
   {
      Print("bull cross");
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,tradeVolume,askPrice,stopLoss,takeProfit,"position opened");
   }
  
   
  }

