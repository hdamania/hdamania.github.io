//: Calculate the detour distance between two different rides. Given four latitude / longitude pairs, where driver one is traveling from point A to point B and driver two is traveling from point C to point D, write a function (in your language of choice) to calculate the shorter of the detour distances the drivers would need to take to pick-up and drop-off the other driver.

import UIKit

extension CGPoint {
    
//: This function calculates distance between 2 points using the euclidean formula in a XY plane.
//: Any other formula can also easily be used here to account for curvature, etc
    func distanceTo(other: CGPoint) -> CGFloat {
        return sqrt( pow(abs(x - other.x), 2) + pow(abs(y - other.y), 2) )
    }
    
}

//: Detour distance for drivers. Driver 1 = A->C->D->B, Driver 2 = C->A->B->D.
//: We see that for both detour routes, the drivers would travel using the other drivers main route (hence their detour).
//: So essentially, if we are comparing the detour routes for the drivers,
//: we would see that in comparing differences, routes |A->C| and |B->D| are travelled for both detours.
//: Thus to see which one is shorter, we can simply check to see which routes A->B and C->D are longer.
func shorterDetourDistance(pointA: CGPoint, pointB: CGPoint, pointC: CGPoint, pointD: CGPoint) -> String {
    let AB = pointA.distanceTo(pointB)
    let CD = pointC.distanceTo(pointD)
    
    let difference = AB-CD
    let absDescription = String(format: "%.2f", abs(AB - CD))
    
    if difference < 0 {
        return "C->A->B->D is shorter by around \(absDescription) units"
    } else if difference > 0 {
        return "A->C->D->B is shorter by around \(absDescription) units"
    } else {
        return "Both detours are the same distance. Check traffic for a better answer"
    }
}

//: Playground ftw! Confirm which detour to use

//: Enter different coordinates
var pointA = CGPoint(x: 5.3, y: 8.7)
var pointB = CGPoint(x: 12.3, y: 12.5)
var pointC = CGPoint(x: 13.5, y: 2.7)
var pointD = CGPoint(x: 11.8, y: 19.1)

//: Now let's call the function to see which one is shorter
shorterDetourDistance(pointA, pointB, pointC, pointD)

//: Confirm if the route is infact shorter by checking
var ACDB = pointA.distanceTo(pointC) + pointC.distanceTo(pointD) + pointD.distanceTo(pointB)
var CABD = pointC.distanceTo(pointA) + pointA.distanceTo(pointB) + pointB.distanceTo(pointD)