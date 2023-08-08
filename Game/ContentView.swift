//
//  ContentView.swift
//  Game
//
//  Created by Glenn Brannelly on 8/20/22.
//

import Foundation
import SwiftUI

class GameController: ObservableObject {
    
    @Published var player = Player()
    
    private var displayLink: CADisplayLink?
    private var startTime = CACurrentMediaTime()
    
    func startGameLoop() {
        stopDisplayLink()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    @objc
    private func update() {
        move()
    }
    
    private func move() {
        var player = player
        let moveStep = Double(player.speed) * player.moveSpeed
        
        player.rot += Double(player.dir) * player.rotSpeed
        
        print(player.rot)
        
        let newX = Double(player.x) + cos(player.rot) * moveStep
        let newY = Double(player.y) + sin(player.rot) * moveStep
        
        player.x = Int(newX)
        player.y = Int(newY)
        
        self.player = player
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

struct ContentView: View {
    
    var map: [[Int]] {
        [
            [1,1,1,1,1,1,1,1],
            [1,0,0,0,0,0,0,1],
            [1,0,0,1,1,1,0,1],
            [1,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,1],
            [1,0,1,1,0,0,0,1],
            [1,0,0,0,0,0,0,1],
            [1,1,1,1,1,1,1,1]
        ]
    }
    
    var mapWidth: Int = 0
    var mapHeight: Int = 0
    var scale = 64
    
    @StateObject var game = GameController()
    
    init() {
        mapWidth = map[0].count
        mapHeight = map.count
    }
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                
                for y in 0..<mapHeight {
                    for x in 0..<mapWidth {
                        let wall = map[y][x]
                        
                        if wall > 0 {
                            context.fill(
                                Path(CGRect(x: x * scale, y: y * scale, width: scale, height: scale)),
                                with: .color(.red)
                            )
                        }
                    }
                }
                
                context.fill(
                    Path(
                        CGRect(
                            x: game.player.x,
                            y: game.player.y,
                            width: 16,
                            height: 32
                        )
                    ),
                    with: .color(.blue)
                )
                
            }
            .border(Color.blue)
            
        }
        .onAppear(perform: game.startGameLoop)
    }
    
    /*
     function move() {
         // Player will move this far along
         // the current direction vector
         var moveStep = player.speed * player.moveSpeed;

         // Add rotation if player is rotating (player.dir != 0)
         player.rot += player.dir * player.rotSpeed;

         // Calculate new player position with simple trigonometry
         var newX = player.x + Math.cos(player.rot) * moveStep;
         var newY = player.y + Math.sin(player.rot) * moveStep;

         // Set new position
         player.x = newX;
         player.y = newY;
     }
     */
}

struct Player {
    var x: Int = 128
    var y: Int = 128
    var dir: Int = 1
    var rot: Double = 0
    var speed: Int = 1
    var moveSpeed: Double = 0.5
    var rotSpeed: Double = 0.1
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
