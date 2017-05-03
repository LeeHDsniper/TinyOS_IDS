from TOSSIM import *
from tinyos.tossim.TossimApp import *
from random import *
import sys

#n = NescApp("TestNetwork", "app.xml")
#t = Tossim(n.variables.variables())
t = Tossim([])
r = t.radio()

f = open("15-15-tight-mica2-grid.txt", "r")

#f = open("sparse-grid.txt", "r")
lines = f.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    if s[0] == "gain":
      r.add(int(s[1]), int(s[2]), float(s[3]))

noise = open("meyer-short.txt", "r")
lines = noise.readlines()
for line in lines:
  str = line.strip()
  if (str != ""):
    val = int(str)
    for i in range(0, 100):
      m = t.getNode(i);
      m.addNoiseTraceReading(val)




for i in range(0, 100):
  m = t.getNode(i);
  m.createNoiseModel();
  time = randint(t.ticksPerSecond(), 10 * t.ticksPerSecond())
  m.bootAtTime(time)
  print "Booting ", i, " at time ", time

print "Starting simulation."

#t.addChannel("size", sys.stdout)
#t.addChannel("TreeRouting", sys.stdout)
#t.addChannel("TestNetworkC", sys.stdout)
#t.addChannel("Route", sys.stdout)
#t.addChannel("PointerBug", sys.stdout)
#t.addChannel("QueueC", sys.stdout)
#t.addChannel("IDS-SwapMsg", sys.stdout)
#t.addChannel("IDS-Response",sys.stdout)
#t.addChannel("IDS-StatisticsMngr", sys.stdout)
#t.addChannel("IDS-DetectionBrige", sys.stdout)
#t.addChannel("IDS-DetectionEngine",sys.stdout)
#t.addChannel("IDS",sys.stdout)
t.addChannel("IDS-Scheduler",sys.stdout)
#t.addChannel("APP", sys.stdout)
#t.addChannel("IDS-StatisticsMngrDump", sys.stdout)
#t.addChannel("IDS-PacketCache", sys.stdout)
#t.addChannel("Error_rate", sys.stdout)
#t.addChannel("IDS-NeighList", sys.stdout)
#t.addChannel("IDS-PacketCacheCheck", sys.stdout)
#t.addChannel("IDS-PacketCacheDump", sys.stdout)
t.addChannel("TEST", sys.stdout)
while (t.time() < 60000 * t.ticksPerSecond()):
#  raw_input()
  t.runNextEvent()
print "Completed simulation."
