module Circles (..) where

import CirclesModel exposing (..)
import CirclesView exposing (..)
import List exposing ((::), map)
import Mouse
import Signal.Extra exposing ((~), (<~))
import Signal exposing (Signal, filter, foldp, sampleOn)
import Time exposing (Time, fps, timestamp)


clockSignal : Signal Time
clockSignal =
    fst <~ timestamp (fps 50)


clickPositionSignal : Signal ( Int, Int )
clickPositionSignal =
    sampleOn Mouse.clicks Mouse.position


inBoxClickPositionSignal : Int -> Int -> Signal ( Int, Int )
inBoxClickPositionSignal w h =
    let
        positionInBox pos = fst pos <= w && snd pos <= h
    in
        filter positionInBox ( 0, 0 ) clickPositionSignal


creationTimeSignal : Int -> Int -> Signal Time
creationTimeSignal w h =
    sampleOn (inBoxClickPositionSignal w h) clockSignal


newCircleSpecSignal : Int -> Int -> Signal CircleSpec
newCircleSpecSignal w h =
    makeCircleSpec <~ creationTimeSignal w h


newCircleSignal : Int -> Int -> Signal Circle
newCircleSignal w h =
    let
        makeCircle ( x, y ) spec = { position = { x = x, y = y }, circleSpec = spec }
    in
        makeCircle
            <~ inBoxClickPositionSignal w h
            ~ newCircleSpecSignal w h


allCirclesSpecSignal : Int -> Int -> Signal (List Circle)
allCirclesSpecSignal w h =
    foldp (::) [] (newCircleSignal w h)


computeCoordinate : Int -> Int -> Float -> Float -> Int
computeCoordinate startPointCoordinate boxSize velocity time =
    let
        distance = startPointCoordinate + round (velocity * time / 1000)

        distanceMod = distance % boxSize

        distanceDiv = distance // boxSize
    in
        if (distanceDiv % 2 == 0) then
            distanceMod
        else
            boxSize - distanceMod


positionedCircle : Int -> Int -> Float -> Circle -> Circle
positionedCircle w h time circle =
    let
        { position, circleSpec } = circle

        { radius, xv, yv, creationTime } = circleSpec

        relativeTime = time - creationTime

        boxSizeX = w - radius * 2

        boxSizeY = h - radius * 2

        x = radius + computeCoordinate (position.x - radius) boxSizeX (toFloat xv) relativeTime

        y = radius + computeCoordinate (position.y - radius) boxSizeY (toFloat yv) relativeTime
    in
        { position = { x = x, y = y }, circleSpec = circleSpec }


positionedCircles : Int -> Int -> Float -> List Circle -> List Circle
positionedCircles w h time circles =
    map (positionedCircle w h time) circles


circlesSignal : Int -> Int -> Signal (List Circle)
circlesSignal w h =
    positionedCircles w h
        <~ clockSignal
        ~ allCirclesSpecSignal w h

main =
  let main' w h = view w h <~ circlesSignal w h
  in
      main' 400 400
