breed [crabs crab]
breed [shells shell]
breed [vacancyChains vacancyChain]

shells-own [shellSize]
vacancyChains-own [occupancyCount]
crabs-own [ crabShellSize crabShellHealth crabHealth]
globals [shellAgingCoefficient crabAgingCoefficient]
patches-own [patchShellSize patchShellHealth patchOccupancyCount]
to setup
  clear-all
  ask patches [ set pcolor 39.2 ]
  reset-ticks
  set-default-shape crabs "hermitcrab2"
  set-default-shape shells "hermitshell"
  set shellAgingCoefficient 0.001
  set crabAgingCoefficient 0.001

create-vacancyChains 100 [
    hide-turtle
    set occupancyCount 0
  ]

  create-shells initial-empty-shell-number [
    make-shell random-xcor random-ycor getRandomShellSize 1
  ]
  create-crabs initial-crab-number [
    make-crab
  ]


  reset-ticks
end

to go

  ask crabs [
    checkForShells
    move
    checkCrabDeath
  ]

  ask shells[
    checkShellDeath
    synch-shell-to-patch
    ]


  let randomNumber random-float 1
  if randomNumber < crab-entry-probability [
    create-crabs 1 [
      make-crab

    ]
  ]

  set randomNumber random-float 1
  if randomNumber < shell-entry-probability [
    create-shells 1 [

    make-shell random-xcor random-ycor getRandomShellSize 1

  ]
  ]
  do-size-plots
  currentOccupancyCountplot
  tick

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

to make-shell [x y ssize health]
  set xcor x
  set ycor y
  ask patch x y [
    set patchShellSize ssize
    set patchShellHealth health
    set patchOccupancyCount 0

  ]
  synch-shell-to-patch

end




to  synch-shell-to-patch
  set color ( patchShellSize * 60) + 87
  set size (patchShellSize * 2) + 1
end




to move  ;; crab procedure

  rt random  10
  lt random  10
  fd 0.2


end

to drop-dead-shell [x y]

    let tmp-crabShellSize crabShellSize
  let tmp-crabShellHealth crabShellHealth
  ask patch x y [
   set patchShellSize tmp-crabShellSize
   set patchShellHealth tmp-crabShellHealth
   set patchOccupancyCount 0
  ]

  set breed shells
  make-shell x y tmp-crabShellSize tmp-crabShellHealth

end
to checkForShells

  if patchShellSize > crabShellSize and patchShellSize < crabShellSize * (1 + higher-exchange-threshold)
  [

    let lastCrabSize crabShellSize
    let lastCrabShellHealth crabShellHealth
    set patchOccupancyCount patchOccupancyCount + 1
    ask vacancyChain patchOccupancyCount
    [
   set occupancyCount occupancyCount + 1
    ]
    set crabShellSize patchShellSize
    set crabShellHealth  (patchShellHealth * (crabShellSize + 1))
    set patchShellHealth lastCrabShellHealth
    set patchShellSize lastCrabSize

    set size (crabShellSize * 2) + 1
    set color ( crabShellSize * 60) + 87



;    ask shells-here [
;      synch-shell-to-patch
;    ]
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
  set patchShellHealth patchShellHealth * 1 - (shell-ageing * shellAgingCoefficient)
  let randomDeath random-float 1
  if patchShellHealth < randomDeath[
   die
  ]
end

to checkCrabDeath

  set crabHealth crabHealth * 1 -  (crab-ageing * (1 - crabShellSize ^ 3) * crabAgingCoefficient)

  let randomDeath random-float 1
  if crabHealth  < randomDeath [
    drop-dead-shell xcor ycor
  ]
end

to do-size-plots
  set-current-plot "Occupied Shell Sizes"
  plot-pen-reset
  set-plot-pen-mode 1
  foreach   [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]
  [ a ->  plot count crabs with [crabShellSize > a - .05 and crabShellSize < a  ] ]

end

to currentOccupancyCountplot
  set-current-plot "Length of Vacancy Chain"
  plot-pen-reset
  set-plot-pen-mode 1
  foreach [0 1 2 3 4 5 6 7 8 9 10]



  [a ->
    let currentOccupancyCount 0
    ask vacancyChain a[
      set currentOccupancyCount occupancyCount
    ]
plot currentOccupancyCount
  ]


end
@#$#@#$#@
GRAPHICS-WINDOW
272
10
978
717
-1
-1
17.0244
1
10
1
1
1
0
1
1
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
77
533
212
606
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
75
612
211
684
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
40
10
266
43
initial-crab-number
initial-crab-number
0.0
250
250.0
1.0
1
NIL
HORIZONTAL

SLIDER
38
389
264
422
initial-empty-shell-number
initial-empty-shell-number
0
250
250.0
1
1
NIL
HORIZONTAL

SLIDER
33
254
264
287
higher-exchange-threshold
higher-exchange-threshold
0
1
0.65
.01
1
NIL
HORIZONTAL

SLIDER
37
459
266
492
shell-ageing
shell-ageing
0
1
0.0
0.01
1
NIL
HORIZONTAL

PLOT
31
722
276
850
Empty Shell Count
time
shells
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count shells"

SLIDER
32
147
261
180
crab-ageing
crab-ageing
0
1
0.0
0.01
1
NIL
HORIZONTAL

PLOT
330
722
919
1000
Occupied Shell Sizes
crab size
distribution
0.0
1.0
0.0
100.0
true
true
"" ""
PENS
"default" 1.0 0 -7500403 true "" ""

PLOT
31
856
277
976
Crab Count
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count crabs"

SLIDER
33
290
263
323
crab-entry-probability
crab-entry-probability
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
32
326
234
359
shell-entry-probability
shell-entry-probability
0
1
0.18
0.01
1
NIL
HORIZONTAL

PLOT
1023
753
1223
903
Length of Vacancy Chain
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

@#$#@#$#@
# # WHAT IS IT?
This is an agent-based model exploring the size distribution of the empty snail shells occupied by
a population of hermit crabs. The model investigates the effect of shell and crab variables on that
distribution. In the model, crabs wander randomly on the ocean bottom looking for empty shells.
New, empty shells randomly appear in locations on the ocean bottom according to the
distribution chosen by the user. A crab takes the first empty shell that it finds, provided that is a
specified fraction larger than the one that it presently inhabits. A crab can take a new shell
appearing randomly from the chosen distribution or one left by another crab getting a new shell.
Both crabs and shells have specified lifetimes, but a shell only “dies” when it has reached its
lifetime and it is not occupied by a crab. The onscreen display shows a histogram of the
proportions of the hermit crab population residing in shells of various size categories.
# # HOW TO USE IT
1. Adjust the slider parameters (see below) or use the default settings.
2. Press the SETUP button.
3. View the HISTOGRAM to watch the size distribution of the shell sizes occupied by the hermit
crab change over time.
Variables for the model:
1. The type of distribution that governs the random appearance of hew empty snail shells on the
ocean bottom.
Parameters for the models:

1. The lifetime of the hermit crabs.
2. The lifetime of the snail shells.
3. The fraction larger that a new shell must be before a hermit crab takes it.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crab
false
0
Circle -7500403 true true 60 90 120
Circle -7500403 true true 180 30 30
Circle -7500403 true true 90 30 30
Polygon -7500403 true true 105 60 120 105 120 90 105 45 105 60
Polygon -7500403 true true 195 60 180 105 180 90 195 45 195 60
Polygon -7500403 true true 75 135 60 120 60 105 75 75 30 105 75 45 15 60 0 105 15 135 60 150 90 150 90 135
Polygon -7500403 true true 75 165 60 165 30 195 90 180
Polygon -7500403 true true 225 165 240 165 270 195 210 180
Polygon -7500403 true true 90 195 60 210 45 240 105 210
Polygon -7500403 true true 210 195 240 210 255 240 195 210
Polygon -7500403 true true 105 195 90 240 90 270 135 195
Polygon -7500403 true true 195 195 210 240 210 270 165 195
Polygon -7500403 true true 225 135 240 120 240 105 225 75 270 105 225 45 285 60 300 105 285 135 240 150 210 150 210 135
Circle -7500403 true true 120 90 120
Rectangle -7500403 true true 120 90 180 210

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hermit
false
0
Polygon -16777216 true false 72 103 78 118 89 117 100 117 99 98 113 100 114 116 152 131 159 149 208 177 253 227 261 269 234 235 204 210 214 236 217 272 195 241 175 210 146 177 143 180 152 207 132 229 119 271 98 253 86 224 85 200 70 232 59 269 43 253 29 260 37 240 29 226 22 232 5 264 7 229 15 211 25 205 25 156 12 162 20 145 31 139 4 141 23 128 56 128 63 120 56 102 70 100
Circle -16777216 true false 42 72 36
Circle -16777216 true false 87 72 36
Polygon -2674135 true false 63 131 24 130 9 140 26 135 60 137
Polygon -2674135 true false 52 135 23 146 15 159 32 148 65 139
Polygon -5825686 true false 77 162 20 214 11 231 7 257 19 230 80 178 38 243 33 257 63 220 103 169 85 158
Circle -2674135 true false 90 75 30
Circle -2674135 true false 45 75 30
Polygon -2674135 true false 45 150 65 123 90 120 118 121 150 135 158 163 135 180 75 165 60 146
Polygon -2674135 true false 153 151 199 206 210 233 214 264 196 234 175 206 133 159
Polygon -2674135 true false 60 103 73 137 77 129 66 97
Polygon -2674135 true false 103 101 107 142 113 135 110 97
Polygon -2674135 true false 153 150 203 180 248 229 257 261 235 229 180 186 158 162
Circle -16777216 true false 94 79 22
Circle -16777216 true false 48 79 22
Circle -1 true false 108 81 7
Circle -1 true false 62 81 7
Polygon -2674135 true false 88 161 88 221 103 251 118 266 128 230 148 206 133 161 103 146 88 161
Polygon -2674135 true false 28 157 28 217 43 247 58 262 68 228 82 199 78 159 53 139 28 157

hermitcrab2
false
0
Polygon -16777216 true false 72 121 84 103 95 89 115 73 126 67 151 63 173 60 185 53 191 53 208 59 219 52 228 48 241 52 251 42 258 46 262 57 262 69 272 82 268 95 280 105 274 117 282 138 278 162 264 177 250 191 228 202 204 211 175 215 152 213 131 204 98 171 76 129
Polygon -7500403 true true 79 120 87 107 108 84 129 70 157 66 175 64 190 57 208 64 218 57 229 52 240 57 253 45 258 57 257 68 267 80 262 94 274 104 269 115 276 134 272 158 258 174 237 191 210 204 180 208 156 206 117 194 94 174 78 151 77 135
Polygon -16777216 true false 72 103 78 118 89 117 100 117 99 98 113 100 114 116 152 131 159 149 208 177 253 227 261 269 234 235 204 210 214 236 217 272 195 241 175 210 146 177 143 180 152 207 132 229 119 271 98 253 86 224 85 200 70 232 59 269 43 253 29 260 37 240 29 226 22 232 5 264 7 229 15 211 25 205 25 156 12 162 20 145 31 139 4 141 23 128 56 128 63 120 56 102 70 100
Circle -16777216 true false 42 72 36
Circle -16777216 true false 87 72 36
Polygon -2674135 true false 63 131 24 130 9 140 26 135 60 137
Polygon -2674135 true false 52 135 23 146 15 159 32 148 65 139
Polygon -5825686 true false 77 162 20 214 11 231 7 257 19 230 80 178 38 243 33 257 63 220 103 169 85 158
Circle -2674135 true false 90 75 30
Circle -2674135 true false 45 75 30
Polygon -2674135 true false 45 150 65 123 90 120 118 121 150 135 158 163 135 180 75 165 60 146
Polygon -2674135 true false 153 151 199 206 210 233 214 264 196 234 175 206 133 159
Polygon -2674135 true false 60 103 73 137 77 129 66 97
Polygon -2674135 true false 103 101 107 142 113 135 110 97
Polygon -2674135 true false 153 150 203 180 248 229 257 261 235 229 180 186 158 162
Circle -16777216 true false 94 79 22
Circle -16777216 true false 48 79 22
Circle -1 true false 108 81 7
Circle -1 true false 62 81 7
Polygon -2674135 true false 88 161 88 221 103 251 118 266 128 230 148 206 133 161 103 146 88 161
Polygon -2674135 true false 28 157 28 217 43 247 58 262 68 228 82 199 78 159 53 139 28 157
Polygon -16777216 true false 237 56 263 74 261 69 241 55
Polygon -16777216 true false 174 65 214 82 252 105 271 117 274 123 237 100 216 87 172 67 165 65 172 64
Polygon -16777216 true false 206 63 240 77 267 98 266 95 241 74 210 61

hermitcrab3
false
0
Polygon -7500403 true true 79 120 87 107 108 84 129 70 157 66 175 64 190 57 208 64 218 57 229 52 240 57 253 45 258 57 257 68 267 80 262 94 274 104 269 115 276 134 272 158 258 174 237 191 210 204 180 208 156 206 117 194 94 174 78 151 77 135
Polygon -2674135 true false 63 131 24 130 9 140 26 135 60 137
Polygon -2674135 true false 52 135 23 146 15 159 32 148 65 139
Polygon -5825686 true false 77 162 20 214 11 231 7 257 19 230 80 178 38 243 33 257 63 220 103 169 85 158
Circle -2674135 true false 90 75 30
Circle -2674135 true false 45 75 30
Polygon -2674135 true false 45 150 65 123 90 120 118 121 150 135 158 163 135 180 75 165 60 146
Polygon -2674135 true false 153 151 199 206 210 233 214 264 196 234 175 206 133 159
Polygon -2674135 true false 60 103 73 137 77 129 66 97
Polygon -2674135 true false 103 101 107 142 113 135 110 97
Polygon -2674135 true false 153 150 203 180 248 229 257 261 235 229 180 186 158 162
Circle -16777216 true false 94 79 22
Circle -16777216 true false 48 79 22
Circle -1 true false 108 81 7
Circle -1 true false 62 81 7
Polygon -2674135 true false 88 161 88 221 103 251 118 266 128 230 148 206 133 161 103 146 88 161
Polygon -2674135 true false 28 157 28 217 43 247 58 262 68 228 82 199 78 159 53 139 28 157

hermitcrabold
false
0
Polygon -5825686 true false 78 229 66 253 62 269 80 246 139 201 120 192
Polygon -5825686 true false 90 195 45 225 15 270 45 240 90 210 90 270 105 225 120 195 90 195
Polygon -7500403 true true 112 142 124 114 149 100 169 97 186 99 196 93 208 94 216 97 229 91 244 97 258 88 266 86 269 92 266 101 284 116 278 121 285 138 280 147 287 174 281 198 272 210 247 219 227 221 197 215 159 203 133 189 119 163 113 141
Circle -2674135 true false 41 61 40
Circle -2674135 true false 97 40 46
Polygon -2674135 true false 75 95 94 135 102 145 109 140 111 122 113 84 124 84 118 145 151 156 167 167 173 195 231 216 243 229 252 252 258 277 248 258 231 240 207 225 184 219 207 244 214 258 219 292 204 271 187 246 164 224 140 214 118 199 116 230 118 264 120 282 87 272 78 252 73 230 81 209 91 198 65 200 41 218 28 249 17 232 14 196 33 173 48 166 77 168 64 157 28 154 60 150 76 155 68 147 42 141 78 141 93 151 97 147 65 97 73 92

hermitshell
false
0
Polygon -16777216 true false 86 148 85 138 92 115 101 100 115 82 151 67 175 62 186 54 207 50 213 45 230 44 239 41 254 40 261 43 261 49 258 59 269 64 266 77 275 84 273 99 283 107 290 117 298 130 299 148 299 162 292 183 279 199 258 211 240 215 222 217 201 213 186 206 168 191 151 176 134 164 119 154 101 151 88 152
Polygon -7500403 true true 149 171 191 205 211 213 226 214 252 210 275 197 290 180 296 159 295 135 289 122 279 108 269 102 272 86 263 78 265 66 254 61 258 51 258 45 251 43 240 44 233 47 231 48 216 48 210 54 190 56 178 66 156 69 139 76 118 85 109 95 100 109 93 123 88 138 89 148 106 149 124 153
Line -16777216 false 176 65 272 102
Line -16777216 false 208 53 267 80
Line -16777216 false 230 47 256 61

hermitshell2
false
0
Polygon -7500403 true true 149 171 191 205 211 213 226 214 252 210 275 197 290 180 296 159 295 135 289 122 279 108 269 102 272 86 263 78 265 66 254 61 258 51 258 45 251 43 240 44 233 47 231 48 216 48 210 54 190 56 178 66 156 69 139 76 118 85 109 95 100 109 93 123 88 138 89 148 106 149 124 153

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

rabbit
false
0
Circle -7500403 true true 76 150 148
Polygon -7500403 true true 176 164 222 113 238 56 230 0 193 38 176 91
Polygon -7500403 true true 124 164 78 113 62 56 70 0 107 38 124 91

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
