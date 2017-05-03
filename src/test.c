#include <tossim.h>
#include <iostream>
#include <fstream>
using namespace std;

#define NODES_COUNT  100

int main(void){
  Tossim* t = new Tossim(NULL);
  Radio* r = t->radio();
 
  cout << "% reading topology model" << endl;  
  ifstream topo;
//  topo.open("link_gain_tight");
//  topo.open("02/link_gain");
//  topo.open("15-15-tight-mica2-grid.txt");
//  topo.open("15-15-medium-mica2-grid.txt");
  topo.open("my_gain");


  if(! topo.is_open()){
    exit(1);
  }
  
  string type;
  int i1,i2;
  double d1;

  do{
    topo >> type;
    if(type == "gain") {
      topo >> i1 >> i2 >> d1;
      //cout << type << ":" << i1 << ":" << i2 << ":" << d1 << endl; 
      if(i1 < NODES_COUNT && i2 < NODES_COUNT){
        r->add(i1,i2,d1);
      }
    }else if(type == "noise"){
      break;
    }
  }while(!topo.eof());

  topo.close();
  
  cout << "% reading noise model" << endl;  
  ifstream noise;
  noise.open("casino-lab.txt");
  int noise_int = 0;
  for(int j=0;j < 1000; j++ ){
    noise >> noise_int;
//  cout << "noise " << noise_int << endl;
    for(int i=0; i < NODES_COUNT; i++){
        t->getNode(i)->addNoiseTraceReading(noise_int);
    }
  }
  
  noise.close();

 
  //randomizing bootup time 
  //100ms
  long long int max_boot_time = 1000000000;

  
  for(int i=0; i< NODES_COUNT;i++){
    Mote* m = t->getNode(i);
    m->createNoiseModel();
    //int time = 1 + i*2009942;
    //int time = 1 + i*421421;
    long long int time = rand() % max_boot_time;
    //cout << "node " << i << "booting at time : " << time << endl;

    /** boot up in 0 - 5s */ 
    m->bootAtTime(time*50);
  }
  //t->addChannel("IDS-SwapMsg",stdout);
  //t->addChannel("IDS-Scheduler",stdout);
  //t->addChannel("IDS-DetectionEngine",stdout);
  //t->addChannel("IDS-StatisticsMngrDump",stdout);  
  //t->addChannel("IDS-Response",stdout);
  t->addChannel("TEST",stdout);
  //t->addChannel("ATTACK",stdout);
  for (int i = 0; i < 100 * t->ticksPerSecond(); i++) {
    if((t->time() / t->ticksPerSecond()) > 1000){
        exit(0);
    }

    t->runNextEvent();
  }


}

