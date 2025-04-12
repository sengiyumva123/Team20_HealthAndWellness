// DreamEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(DreamEntity)
public class DreamEntity: NSManagedObject {
    func toDream() -> Dream {
        Dream(
            id: id ?? UUID(),
            text: text ?? "",
            timestamp: timestamp ?? Date(),
            soundscapeURL: soundscapeURL.flatMap(URL.init),
            emotions: emotions?.array as? [EmotionEntity] ?? [],
            archetypes: archetypes?.array as? [ArchetypeEntity] ?? []
        )
    }
}

// DreamEntity+CoreDataProperties.swift
extension DreamEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DreamEntity> {
        return NSFetchRequest<DreamEntity>(entityName: "DreamEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var soundscapeURL: String?
    @NSManaged public var emotions: NSSet?
    @NSManaged public var archetypes: NSSet?
}

// EmotionEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(EmotionEntity)
public class EmotionEntity: NSManagedObject {
    func toEmotion() -> Emotion {
        Emotion(label: label ?? "", score: score)
    }
}

// ArchetypeEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(ArchetypeEntity)
public class ArchetypeEntity: NSManagedObject {
    func toArchetype() -> String {
        name ?? ""
    }
}