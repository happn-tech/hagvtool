import CoreData
import Foundation



@objc(PBXTarget)
public class PBXTarget : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		let mine = [
			"buildPhases_cd": "buildPhases"
		]
		return super.propertyRenamings().merging(mine, uniquingKeysWith: { current, new in
			precondition(current == new, "Incompatible property renamings")
			NSLog("%@", "Warning: Internal logic shadiness: Property rename has been declared twice for destination \(current), in class \(self)")
			return current
		})
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		name = try rawObject.get("name")
		productName = try rawObject.get("productName")
		
		let buildPhasesIDs: [String] = try rawObject.get("buildPhases")
		buildPhases = try buildPhasesIDs.map{ try PBXBuildPhase.unsafeInstantiate(rawObjects: rawObjects, id: $0, context: context, decodedObjects: &decodedObjects) }
		
		let buildConfigurationListID: String = try rawObject.get("buildConfigurationList")
		buildConfigurationList = try XCConfigurationList.unsafeInstantiate(rawObjects: rawObjects, id: buildConfigurationListID, context: context, decodedObjects: &decodedObjects)
	}
	
	public var buildPhases: [PBXBuildPhase]? {
		get {buildPhases_cd?.array as! [PBXBuildPhase]?}
		set {buildPhases_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["name"]                   = try name.get()
		mySerialization["productName"]            = try productName.get()
		mySerialization["buildPhases"]            = try buildPhases.get().map{ try $0.xcIDAndComment(projectName: projectName).get() }
		mySerialization["buildConfigurationList"] = try buildConfigurationList.get().xcIDAndComment(projectName: projectName).get()
		
		let parentSerialization = try super.knownValuesSerialized(projectName: projectName)
		return parentSerialization.merging(mySerialization, uniquingKeysWith: { current, new in
			NSLog("%@", "Warning: My serialization overrode parent’s serialization’s value “\(current)” with “\(new)” for object of type \(rawISA ?? "<unknown>") with id \(xcID ?? "<unknown>").")
			return new
		})
	}
	
}
