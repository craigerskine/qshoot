pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--qshoot
--by craig erskine
function _init()
  mode="start"
  t=0
  cls(0)
    
  -- stars
  stars={}
  for i=1,50 do
    local newstar={
      x=flr(rnd(128)),
      y=flr(rnd(128)),
      s=rnd(.5)+0.1
    }
    add(stars,newstar)
  end
end

function _update60()
  t+=1
  if mode=="start" then
    update_start()
  elseif mode=="play" then
    update_play()
  elseif mode=="over" then
    update_over()
  elseif mode=="win" then
    update_win()
  end
end

function _draw()
  -- clear screen
  cls(0)
  starfield()
  stars_anim()
  if mode=="start" then
    draw_start()
  elseif mode=="play" then
    draw_game()
  elseif mode=="over" then
    draw_over()
  elseif mode=="win" then
    draw_win()
  end
end

function startgame()
  mode="play"
  t=0

  -- ship
  ship={
    spr=2, -- sprite
    x=60,
    y=112
  }
  
  -- exhaust
  exh=4
  
  -- enemies
  enm=32 -- sprite
  enms={}
  do_enm()

  -- explosions
  xpls={}

  -- lives
  lives=3
  invul=0
  
  -- bullets
  bul=16 -- sprite
  buls={}
  bult=0
  
  -- muzzle flash
  mzl=0
  
  -- score
  scr=0

end

--------------------------------------------------------------------------------

-- *** *** *** *** ***
-- UPDATE START
-- *** *** *** *** ***
function update_start()
  if btnp(4) or btnp(5) then
    startgame()
  end
end

-- *** *** *** *** ***
-- UPDATE PLAY
-- *** *** *** *** ***
function update_play()
  -- reset sprite when idle
  ship.spr=2

  -- move left
  if btn(0) then
    ship.spr=1
    ship.x-=1
  end

  -- move right
  if btn(1) then
    ship.spr=3
    ship.x+=1
  end

  -- move up
  if btn(2) then
    ship.y-=1
  end

  -- move down
  if btn(3) then
    ship.y+=1
  end

  -- exhaust animate
  exh+=0.33
  if exh>=8 then
    exh=4
  end

  -- screen edge detect
  if ship.x>120 then
    ship.x=120
  end
  if ship.x<0 then
    ship.x=0
  end
  if ship.y>120 then
    ship.y=120
  end
  if ship.y<7 then
    ship.y=7
  end

  -- collision shots + enemies
  for theenm in all(enms) do
    for thebul in all(buls) do
      if col(theenm,thebul) then
        del(buls,thebul)
        theenm.hp-=1
        theenm.fl=5
        if theenm.hp<=0 then
          sfx(1)
          do_xpl(theenm.x,theenm.y)
          del(enms,theenm)
          scr+=theenm.scr
          do_enm()
        else
          sfx(2)
        end
      end
    end
  end

  -- collision enemies
  if invul<=0 then
    for theenm in all(enms) do
      if col(theenm,ship) then
        lives-=1
        invul=30
        sfx(1)
      end
    end
  else
    invul-=1
  end

  -- lives
  if lives<=0 then
    mode="over"
    return
  end

  -- scr limit
  if scr>=10000 then
    mode="win"
  end

  -- shoot
  if btn(4) then
    if bult<=0 then
      bult=8
      local thebul={
        spr=bul,
        x=ship.x,
        y=ship.y-2
      }
      add(buls,thebul)
      mzl=3
      sfx(0)
    end
    bult-=1
  end

  -- bullet move/del (iterrate backwards)
  for thebul in all(buls) do
    thebul.y-=3
    if thebul.y<-8 then
      del(buls,thebul)
    end
  end
  
  -- bullet animate
  bul+=0.5
  if bul>=19 then
    bul=16
  end
  
  -- muzzle animate
  mzl-=1
  
  -- enemies move/animate
  for theenm in all(enms) do
    theenm.y+=.25
    if theenm.y>128 then
      theenm.y=5
    end
    theenm.spr+=0.1
    if theenm.spr>=enm+4 then
      theenm.spr=enm
    end
  end
end

-- *** *** *** *** ***
-- UPDATE OVER
-- *** *** *** *** ***
function update_over()
  if btnp(4) or btnp(5) then
    startgame()
  end
end

-- *** *** *** *** ***
-- UPDATE WIN
-- *** *** *** *** ***
function update_win()
  if btnp(4) or btnp(5) then
    startgame()
  end
end

--------------------------------------------------------------------------------

-- *** *** *** *** ***
-- DRAW START
-- *** *** *** *** ***
function draw_start()
  print("qshoot!",52,30,7)
  print("press ❎(z) or 🅾️(x)",24,60,12)
  print("❎(z) = shoot",40,75,13)
end

-- *** *** *** *** ***
-- DRAW GAME
-- *** *** *** *** ***
function draw_game()

  -- ship
  do_spr(ship)

  -- exhaust
  spr(exh,ship.x,ship.y+6)
  
  if invul<=0 then
  else
    -- invul
    if sin(t/5)<0 then
      circ(ship.x+3,ship.y+4,8,7)
    end
  end
  
  -- enemies
  for theenm in all(enms) do
    if theenm.fl>0 then
      theenm.fl-=1
      for i=1,15 do
        pal(i,7)
      end
    end
    do_spr(theenm)
    pal()
  end
  
  -- bullets
  for thebul in all(buls) do
    do_spr(thebul)
  end
  
  -- muzzles
  if mzl>0 then
    circfill(ship.x,ship.y,mzl,7)
    circfill(ship.x+7,ship.y,mzl,7)
  end

  -- explosions
  for thexpl in all(xpls) do
    spr(64,thexpl.x-5,thexpl.y-5,2,2)
    thexpl.age-=1
    if thexpl.age<=0 then
      del(xpls,thexpl)
    end
  end

  -- score
  print(scr,1,1,12)
end

-- *** *** *** *** ***
-- DRAW OVER
-- *** *** *** *** ***
function draw_over()
  print("game over",50,30,7)
  print("press ❎(z) or 🅾️(x)",24,60,12)
end

-- *** *** *** *** ***
-- DRAW WIN
-- *** *** *** *** ***
function draw_win()
  print("you win",50,30,7)
  print("press ❎(z) or 🅾️(x)",24,60,12)
end

function starfield()
  for i=1,#stars do
    local thestar=stars[i]
    local clr=13
    if thestar.s<0.3 then
      clr=1
    elseif thestar.s<0.5 then
      clr=2
    end
    pset(thestar.x,thestar.y,clr)
  end
end

function stars_anim()
  for i=1,#stars do
    local thestar=stars[i]
    thestar.y+=thestar.s
    if thestar.y>128 then
      thestar.y=thestar.y-128
    end
  end
end

function do_spr(sprite)
  spr(sprite.spr,sprite.x,sprite.y)
end

function col(a,b)
  -- a
  local a_l=a.x
  local a_t=a.y
  local a_r=a.x+7
  local a_b=a.y+7
  -- b
  local b_l=b.x
  local b_t=b.y
  local b_r=b.x+7
  local b_b=b.y+7
  -- check
  if a_t>b_b then return false end
  if b_t>a_b then return false end
  if a_l>b_r then return false end
  if b_l>a_r then return false end
  -- bang
  return true
end

function do_enm()
  local theenm={
    spr=enm,
    x=rnd(120),
    y=-8,
    hp=5,
    fl=0,
    scr=300
  }
  add(enms,theenm)
end

function do_xpl(xplx,xply)
  local thexpl={
    x=xplx,
    y=xply,
    age=5
  }
  add(xpls,thexpl)
end

__gfx__
00000000000220100002200001022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000e8000100880010008e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700010840200008400002048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700002e44e2020e44e0202e44e10000770000007700000077000000770000000000000000000000000000000000000000000000000000000000000000000
00077000027c4e202e47c4e202e47c20000cc0000077770000777700007777000000000000000000000000000000000000000000000000000000000000000000
0070070002114e202441144202e41120000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000222200022222200022220000000000000cc00000000000000cc0000000000000000000000000000000000000000000000000000000000000000000
00000000000990000009900000099000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000a00a0000a00a0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a9a00a9aa9a00a9aa9a00a9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000a0a9a00a9aa9a00a9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000a0a9a00a9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0000f0000000000a0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000707000000707000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07033070070330700703307007033070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033bb330033bb330033bb330033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b7717b33b7717b33b7717b33b7717b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b7117b33b7117b33b7117b33b7117b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03377330033773300337733003377330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03033030030330300303303003033030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03300330030000303000000303000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002244444220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022444444442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00224488888842200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00204489999844200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00244889aa9984220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004889aaaa988420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0044899a77a998440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0044899aaaa998440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00448899aa9988440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00248889999884420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00244488888884220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00224444444442200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022440042222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000
00000000000000000000000000000000000000000000000000000700077070700770077077700700000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000707070007070707070700700070000000000000000000000000000000000d000000000000000
00000000000000000020000000000000000000000000000000007070777077707070707007000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007700007070707070707007000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000d000000000000000000000770770070707700770007000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000
00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000002200000000000000000000d000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ccc0ccc0ccc00cc00cc000000ccccc000c00ccc00c0000000cc0ccc000000ccccc000c00c0c00c00000000000000000000000000
000000000000000000000000c0c0c0c0c000c000c0000000cc0c0cc2c00000c000c00000c0c0c0c00000cc000cc0c000c0c000c0000000000000000000000000
000000000000000000000000ccc0cc00cc10ccc0ccc00000ccc0ccc0c0000c0000c00000c0c0cc000000cc0c0cc0c0000c0000c0000000000000000000000000
000000000000000000000000c000c0c0c00000c000c00000cc0c0cc0c000c00000c00000c0c0c0c00000cc000cc0c000c0c000c0000000000000000000000000
000000000000000000000000c000c0c0ccc0cc00cc0000000ccccc000c01ccc00c000000cc00c0c000000ccccc000c00c0c00c00000000000000000200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000ddddd000d00ddd00d000000000000000dd0d0d00dd00dd0ddd0000000000000000000000000000000000000
0000000000000000000000000000000000000000dd0d0dd0d00000d000d00000ddd00000d000d0d0d0d0d0d00d00000000000000000000000000000000000000
0000000000000000000000000000000000000000ddd0ddd0d0000d0000d0000000000000ddd0ddd0d0d0d0d00d00000000000000000000000000000000000000
0000000000000000000000000000000000000000dd0d0dd0d000d00000d00000ddd0000000d0d0d0d0d0d0d00d00000000000000000000000000000000000000
00000000000000000000000000000000200000000ddddd000d00ddd00d0000000000d000dd00d0d0dd00dd000d00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000002000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000010000000000000000000000000000000000000000002000000000000000000000000000000000000000000010000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000395500a5502d5501f5500f550095500555002550015500055000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000396500a6502d6501f6500f650096500565002650016500065000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100003605017050360501705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
