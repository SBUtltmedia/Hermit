breed [shells shell]
shells-own [shellSize]
breed [crabs crab]
crabs-own [ crabShellSize crabShellHealth crabHealth  crabShellOccupancyCount]

patches-own [patchShellSize patchShellHealth patchOccupancyCount]
to setup
  clear-all
  ask patches [ set pcolor 39.2 ]
  reset-ticks
  set-default-shape crabs "hermitcrab2"
  set-default-shape shells "hermitshell"




  create-shells shell-number [
    make-shell random-xcor random-ycor getRandomShellSize 1 1
  ]
  create-crabs crab-number [
    make-crab
  ]
  

  reset-ticks
end



to make-crab

  set crabShellHealth 1
    set crabHealth 1
  set crabShellSize .1
    set color (crabShellSize * 60) + 87
    set xcor random-xcor
    set ycor random-ycor
    set size (crabShellSize * 2) + 1

end

to make-shell [x y ssize health occupancy]
  set xcor x
  set ycor y
  ask patch x y [
    set patchShellSize ssize
    set patchShellHealth health
    set patchOccupancyCount occupancy

  ]
  synch-shell-to-patch
  
end




to  synch-shell-to-patch
  set color ( patchShellSize * 60) + 87
  set size (patchShellSize * 2) + 1
  
end


to go

  ask crabs [
    checkForShells
    move
    checkCrabDeath
  ]

  ask shells[
    checkShellDeath
    ]


  let randomNumber random-float 1
  if randomNumber < crab-spawn-probability [
    create-crabs 1 [
      make-crab

    ]
  ]

  set randomNumber random-float 1
  if randomNumber < shell-spawn-probability [
    create-shells 1 [

    make-shell random-xcor random-ycor getRandomShellSize 1 1

  ]
  ]
  do-size-plots
  do-occupancy-plot
  tick

end

to move  ;; crab procedure

  rt random  10
  lt random  10
  fd 0.2


end

to drop-dead-shell [x y]
  let tmp-crabShellSize crabShellSize
  let tmp-crabShellHealth crabShellHealth
  let tmp-crabShellOccupancyCount crabShellOccupancyCount
  ask patch x y [
   set patchShellSize tmp-crabShellSize
   set patchShellHealth tmp-crabShellHealth
   set patchOccupancyCount tmp-crabShellOccupancyCount
  ]
  set breed shells
  make-shell x y tmp-crabShellSize tmp-crabShellHealth tmp-crabShellOccupancyCount

end
to checkForShells
  if  patchShellSize > crabShellSize + (crabShellSize + appealing-lower-range)  and patchShellSize < crabShellSize + appealing-lower-range + appealing-window-size
  [
    let lastCrabSize crabShellSize
    let lastCrabShellHealth crabShellHealth
    let lastpatchOccupancyCount patchOccupancyCount
    set crabShellSize patchShellSize
    set crabShellHealth  (patchShellHealth * (crabShellSize + 1))
    set patchShellHealth lastCrabShellHealth
    set patchShellSize lastCrabSize

    set size (crabShellSize * 2) + 1
    set color ( crabShellSize * 60) + 87
    set patchOccupancyCount crabShellOccupancyCount
    set crabShellOccupancyCount lastpatchOccupancyCount + 1

    ask shells-here [
      synch-shell-to-patch
    ]
  ]
end

to-report check-for-empty-patch

end
to-report populationDistribution [x]

  report 1 - sqrt x

end



to-report getRandomShellSize

  let potentialShell random-float 1
  let randomNumber random-float 1
  if populationDistribution potentialShell > randomNumber [report potentialShell]
  report getRandomShellSize

end

to checkShellDeath
  set patchShellHealth patchShellHealth - (shell-degradation * .001)
  let randomDeath random-float 1
  if patchShellHealth < randomDeath[
   die
  ]
end

to checkCrabDeath

  set crabHealth crabHealth - .0001 *  crab-degradation * (1 - crabShellSize ^ .3333333)

  let randomDeath random-float 1
  if crabHealth  < randomDeath [
    drop-dead-shell xcor ycor
  ]
end

to do-size-plots
  set-current-plot "Crab Sizes"
  plot-pen-reset
  set-plot-pen-mode 1
  foreach   [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]
  [ a ->  plot count crabs with [crabShellSize > a - .05 and crabShellSize < a  ] ]

end

to do-occupancy-plot
  set-current-plot "Vacancy Chain Visualisation"
  plot-pen-reset
  set-plot-pen-mode 1
  foreach [0 1 2 3 4 5 6 7 8 9 10]
  [a -> plot (count crabs with [crabShellOccupancyCount = a] + count patches with [patchOccupancyCount = a ])]
end
