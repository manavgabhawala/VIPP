//: Playground - noun: a place where people can play

//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground


let accessToken = "P39qfSbd38ReSKvjYOo9Ncpg6SGLiB"
let uberAPIBaseURL = "https://sandbox-api.uber.com/v1/"

let startLatitude = 37.7759792
let startLongitude = -122.41823
let endLatitude = 40.766805
let endLongitude = -73.996215
let productId = "d4abaae7-f4d6-4152-91cc-77523e8165a4"

let parameters = ["Authorization" : "Bearer \(accessToken)", "product_id" : productId, "start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude]
let params = "product_id=\(productId)&start_latitude=\(startLatitude)&start_longitude=\(startLongitude)&end_latitude=\(endLatitude)&end_longitude=\(endLongitude)"


let request = NSMutableURLRequest(URL: NSURL(string: "\(uberAPIBaseURL)requests")!) //requests?access_token=\(accessToken)
request.HTTPMethod = "POST"
request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
if (NSJSONSerialization.isValidJSONObject(parameters))
{
	println("Created valid JSON parameters\n")
}
request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: nil)

var response : NSURLResponse?
var error : NSError?

let requestJSON = NSURLConnection.sendSynchronousRequest(request.copy() as! NSURLRequest, returningResponse: &response, error: &error)

	println("\nResponse: \(response)\n")
	println("\nRaw JSON:  \(requestJSON)\n")
	print("\nJSON: ")
	println(NSJSONSerialization.JSONObjectWithData(requestJSON!, options: nil, error: nil))
	if (error == nil)
	{
		var jsonError : NSError?
		let requestDict = NSJSONSerialization.JSONObjectWithData(requestJSON!, options: nil, error: &jsonError) as! NSDictionary
		if jsonError == nil
		{
			let requestId = requestDict.objectForKey("request_id") as? String
			println("Successfully created request with request id: \(requestId)")
		}
		else
		{
			println("Error while parsing returned JSON: \(jsonError)")
		}
	}
	else
	{
		println("Error while creating an über request: \(error)")
	}
//

XCPSetExecutionShouldContinueIndefinitely()
