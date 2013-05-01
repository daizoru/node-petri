#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

System

  bootstrap: [ require './player' ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->

    server:
      host: 'localhost'
      port: 3100

    game:
      scene: 'rsg/agent/nao/nao.rsg'
      team  : 'Daizoru'
      number: 0

    engine:
      updateInterval: 100.ms
    
    robot:
      effectors: [
        #      No.   Description          Hinge Joint Perceptor name  Effector name
        'he1'  # 0   Neck Yaw             [0][0]      hj1             he1
        'h2'   # 1   Neck Pitch           [0][1]      hj2             he2

        'lae1' # 2   Left Shoulder Pitch  [1][0]      laj1            lae1
        'lae2' # 3   Left Shoulder Yaw    [1][1]      laj2            lae2
        'lae3' # 4   Left Arm Roll        [1][2]      laj3            lae3
        'lae4' # 5   Left Arm Yaw         [1][3]      laj4            lae4
        'lle1' # 6   Left Hip YawPitch    [2][0]      llj1            lle1
        'lle2' # 7   Left Hip Roll        [2][1]      llj2            lle2
        'lle3' # 8   Left Hip Pitch       [2][2]      llj3            lle3
        'lle4' # 9   Left Knee Pitch      [2][3]      llj4            lle4
        'lle5' # 10  Left Foot Pitch      [2][4]      llj5            lle5
        'lle6' # 11  Left Foot Roll       [2][5]      llj6            lle6

        'rle1' # 12  Right Hip YawPitch   [3][0]      rlj1            rle1
        'rle2' # 13  Right Hip Roll       [3][1]      rlj2            rle2
        'rle3' # 14  Right Hip Pitch      [3][2]      rlj3            rle3
        'rle4' # 15  Right Knee Pitch     [3][3]      rlj4            rle4
        'rle5' # 16  Right Foot Pitch     [3][4]      rlj5            rle5
        'rle6' # 17  Right Foot Roll      [3][5]      rlj6            rle6
        'rae1' # 18  Right Shoulder Pitch [4][0]      raj1            rae1
        'rae2' # 19  Right Shoulder Yaw   [4][1]      raj2            rae2
        'rae3' # 20  Right Arm Roll       [4][2]      raj3            rae3
        'rae4' # 21  Right Arm Yaw        [4][3]      raj4            rae4
      ]
