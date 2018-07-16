import Foundation

enum Trig {
    static func sine(_ degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    }
    
    static func cosine(_ degrees: Double) -> Double {
        return __cospi(degrees/180.0)
    }
}

protocol Shape {
    var area: Double { get }
    var perimeter: Double { get }
}

struct Point: Hashable {
    let x: Double
    let y: Double
}

extension Point: CustomStringConvertible {
    var description: String {
        return "x: \(x), y: \(y)"
    }
}

struct InternalAngle {
    let value: Double
    
    init?(_ value: Double) {
        guard value <= 180 else { return nil }
        self.value = value
    }
}

protocol Polygon: Shape {
    var verticies: [Point] { get }
    var angles: [InternalAngle] { get }
}

protocol Diagram {
    var height: Double { get }
    var width: Double { get }
    var shapes: [Shape] { get }
    var shapePositions: [Point: Shape] { get }
}

extension Diagram {
    var totalAreaOfChildren: Double {
        return self.shapes.reduce(0) { total, nextValue in
            return total + nextValue.area
        }
    }
    
    var totalPerimiterOfChildren: Double {
        return self.shapes.reduce(0) { total, nextValue in
            return total + nextValue.perimeter
        }
    }
}



struct Square: Polygon {
    let sideLength: Double
    
    var area: Double {
        return sideLength * sideLength
    }
    
    var perimeter: Double {
        return sideLength * 4
    }
    
    var angles: [InternalAngle] {
        return [InternalAngle(90),InternalAngle(0),InternalAngle(-90)].compactMap { $0 }
    }
    
    var verticies: [Point] {
        
        return angles.reduce([Point(x: 0, y: 0)]) { accumulated, nextAngle in
            
            let previousPoint = accumulated[accumulated.count - 1]
            let magnitudeFactor: (x: Double,y: Double) =
                (sideLength * Trig.cosine(nextAngle.value), sideLength * Trig.sine(nextAngle.value))
            print(magnitudeFactor)
            return accumulated + [Point(x: previousPoint.x + magnitudeFactor.x, y: previousPoint.y + magnitudeFactor.y)]
        }
    }
}

struct RightAngleTriangle: Polygon {
    
    let sideLengthA: Double
    let sideLengthB: Double
    var sideLengthC: Double {
        return sqrt((sideLengthA * sideLengthA) + (sideLengthB * sideLengthB))
    }
    
    var area: Double {
        return 0.5 * (sideLengthA * sideLengthB)
    }
    
    var perimeter: Double {
        return sideLengthA + sideLengthB + sideLengthC
    }
    
    var angles: [InternalAngle] {
        return [InternalAngle(90),InternalAngle(-45),InternalAngle(180)].compactMap { $0 }
    }
    
    var verticies: [Point] {
        
        let lineAnglePairs = [(sideLengthA,angles[0]), (sideLengthC,angles[1])]
        
        return lineAnglePairs.reduce([Point(x: 0, y: 0)]) { accumulated, nextPair in
            let previousPoint = accumulated[accumulated.count - 1]
            
            let lineLength = nextPair.0
            let angle = nextPair.1
            
            let magnitudeFactor: (x: Double,y: Double) =
                (lineLength * Trig.cosine(angle.value), lineLength * Trig.sine(angle.value))
            print(magnitudeFactor)
            
            return accumulated + [Point(x: previousPoint.x + magnitudeFactor.x, y: previousPoint.y + magnitudeFactor.y)]
            
        }
    }
}

let t1 = RightAngleTriangle(sideLengthA: 5, sideLengthB: 5)
print(t1.area)
print(t1.perimeter)

let s1 = Square(sideLength: 5)
print(s1.area)
print(s1.perimeter)

struct VirtualDiagram: Diagram {
    var height: Double
    var width: Double
    let shapePositions: [Point : Shape]
    
    var shapes: [Shape] {
        return Array(shapePositions.values)
    }
}


let vd = VirtualDiagram(height: 100, width: 100, shapePositions: [Point(x: 0, y: 0): t1, Point(x: 50, y: 70): s1])
print(vd.totalAreaOfChildren)
print(vd.totalPerimiterOfChildren)

protocol Renderer {
    func doRender(_ shape: Shape, at point: Point)
}

struct TextRenderer: Renderer {
    func doRender(_ shape: Shape, at point: Point) {
        //
    }
}

print("\n\(s1.verticies)")
print("\n\(t1.verticies)")


// square: 5,5,5,5. 0,0 ----> 0,5 ----> 5,5 ----> 5,0 ----> 0,0
// Origin is bottom left

