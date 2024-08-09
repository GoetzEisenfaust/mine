--#################################
--        Initialisierung
 
local run = 100
local width = 2
local depth = 3
local rightDir = true
local junk = {}
junk[1] = 'minecraft:dirt'
junk[2] = 'minecraft:cobblestone'
junk[3] = 'minecraft:gravel'
 
local held = {}
held[1] = 'minecraft:coal_ore'
held[2] = 'minecraft:lapis_ore'
held[3] = 'minecraft:redstone_ore'
held[4] = 'minecraft:lit_redstone_ore'
held[5] = 'denseores:block0'
held[6] = 'minecraft:diamond_ore'
held[7] = 'ProjRed:Exploration:projectred.exploration.ore'
held[8] = 'Thaumcraft:blockCustomOre'
 
 
--#################################
 
--Funktion zum pruefen der Wertigkeit des Blocks
function heldBlock(slot)
  local ret = false
  for h=1, #held do
    if slot.name == held[h] then
      ret = true
      break
    end
  end
  return ret
end
 
 
--Funktion zum Graben
function digIt()
  while turtle.detect() do
    turtle.dig()
    os.sleep(0.5)
  end
  turtle.forward()
  while turtle.detectUp() do
    local success, slot = turtle.inspect()
    if heldBlock(slot) then
      print('held ',slot.name)
      break
    else
      turtle.digUp()
      os.sleep(0.5)
    end
  end
  if turtle.detectDown() then
    local success, slot = turtle.inspect()
    if not heldBlock(slot) then
      turtle.digDown()
    else
      print('held ',slot.name)
    end
  end
end
 
--Funktion zum Fackel setzen
function placeTorch()
  turtle.select(1)
  turtle.turnRight()
  while turtle.detect() do
    turtle.dig()
  end
  turtle.place()
  turtle.turnLeft()
  turtle.turnLeft()
  while turtle.detect() do
    turtle.dig()
  end
  turtle.forward()
  turtle.turnRight()
  turtle.turnRight()
  turtle.select(2)
  turtle.place()
  turtle.turnLeft()
  while turtle.detect() do
    turtle.dig()
    os.sleep(0.5)
  end
  turtle.forward()
  turtle.turnRight()
  while turtle.detect() do
    turtle.dig()
    os.sleep(0.5)
  end
  turtle.forward()
  turtle.turnLeft()
  while turtle.detectUp() do
    turtle.digUp()
    os.sleep(0.5)
  end
  turtle.digDown()
end
 
--Funktion zum auftanken
function checkFuel()
  local ret = false
  if turtle.getFuelLevel() < 50 then
    for i=3, 16 do
      turtle.select(i)
      if turtle.getItemCount() > 0 then
        if turtle.refuel() then
          ret = true
          break
        end
      end
    end      
  else
    ret = true
  end
  turtle.select(1)
  return ret
end
 
--Funktion zum Graben von Strecken
function digRow(w)
  checkFuel()
  trashJunk()
  for i=1, w do
    digIt()
    -- alle 10 Bloecke
    --   eine Fackel setzen
    --   Muell wegschmeissen
    --   Sprit Level ueberpruefen
    if (i%10 == 0 and i%100 ~= 0) then
      placeTorch()
      trashJunk()
      if not checkFuel() then
        print('kein Sprit mehr!!!')
        os.shutdown()
      end
      i = i+1
    end
  end
end
 
--Funktion zum Gehen
function goRow(w)
  for i=1, w do
    while turtle.detect() do
      turtle.dig()
    end
    turtle.forward()
    os.sleep(0.5)
  end
end
 
--Funktion zum Inventar leeren
function trashJunk()
  for i=3, 16 do
    turtle.select(i)
    if (turtle.getItemCount() > 0) then
      local slot = turtle.getItemDetail()
      for j=1, #junk do
        if (slot.name == junk[j] ) then
          turtle.dropDown()
        end
      end
    end
  end
  turtle.select(1)
end
 
--Run
turtle.select(1)
local slot1 = turtle.getItemDetail()
local count1 = turtle.getItemCount()
turtle.select(2)
local slot2 = turtle.getItemDetail()
local count2 = turtle.getItemCount()
 
if (count1 < 20) or (count2 < 20) or (slot1.name ~= 'minecraft:cobblestone') or (slot2.name ~= 'minecraft:torch') then
  print('Slot 1 muss mit 20 Cobblestone und \nSlot 2 mit 20 Fackeln gefuellt sein,\n du Kackboon!!!')
else
 
  --Hinweg
  digRow(run)
 
  --seitlich graben
  if rightDir then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  digRow(1)
  placeTorch()
  digRow(1)
  if rightDir then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
 
  --Rueckweg
  digRow(run)
 
  --Fuer die naechste Reihe bereit machen
  if rightDir then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  digRow(depth)
  if rightDir then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
end
