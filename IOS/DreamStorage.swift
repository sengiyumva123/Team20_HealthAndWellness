// DreamStorage.swift
import CoreData

protocol DreamStorage {
    func saveDream(_ dream: Dream) throws
    func fetchDreams() throws -> [Dream]
    func deleteDream(_ id: UUID) throws
}

class CoreDataDreamStorage: DreamStorage {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }
    
    func saveDream(_ dream: Dream) throws {
        let dreamEntity = DreamEntity(context: context)
        dreamEntity.id = dream.id
        dreamEntity.text = dream.text
        dreamEntity.timestamp = dream.timestamp
        dreamEntity.soundscapeURL = dream.soundscapeURL?.absoluteString
        
        // Save emotions
        for emotion in dream.emotions {
            let emotionEntity = EmotionEntity(context: context)
            emotionEntity.label = emotion.label
            emotionEntity.score = emotion.score
            dreamEntity.addToEmotions(emotionEntity)
        }
        
        // Save archetypes
        for archetype in dream.archetypes {
            let archetypeEntity = ArchetypeEntity(context: context)
            archetypeEntity.name = archetype
            dreamEntity.addToArchetypes(archetypeEntity)
        }
        
        try context.save()
    }
    
    func fetchDreams() throws -> [Dream] {
        let request: NSFetchRequest<DreamEntity> = DreamEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let results = try context.fetch(request)
        return results.map { $0.toDream() }
    }
    
    func deleteDream(_ id: UUID) throws {
        let request: NSFetchRequest<DreamEntity> = DreamEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let dreamEntity = try context.fetch(request).first {
            context.delete(dreamEntity)
            try context.save()
        }
    }
}