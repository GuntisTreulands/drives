//
//  DataBaseManager.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import CoreData

protocol DataBaseManagerLogic {
	func saveContext()
    func saveBackgroundContext(backgroundContext: NSManagedObjectContext)
    func mainManagedObjectContext() -> NSManagedObjectContext
    func newBackgroundManagedObjectContext() -> NSManagedObjectContext
    func addATask(action: @escaping () -> Void)
}

class DataBaseManager: NSObject, DataBaseManagerLogic {

	static let shared = DataBaseManager()

	var isDoingATask = false {
		didSet {
			if isDoingATask == false {
				doTask()
			}
		}
	}

	var backgroundTaskArray = [() -> Void]()
	var mainThreadTaskArray = [() -> Void]()


	var persistentContainer: NSPersistentContainer!

	// MARK: init

	private override init() {
		super.init()

		persistentContainer = NSPersistentContainer(name: "DataBase")
		persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

			self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
			self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump;
        })

	}

	// MARK: DataBaseManagerLogic

	func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                	print("error \(error)")
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
	
    func saveBackgroundContext(backgroundContext: NSManagedObjectContext) {
   
		if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                let error = error as NSError
                print("error \(error)")
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
	
    func mainManagedObjectContext() -> NSManagedObjectContext {
    	let mainContext = persistentContainer.viewContext
		mainContext.mergePolicy = NSRollbackMergePolicy
		return mainContext
    }
	
    func newBackgroundManagedObjectContext() -> NSManagedObjectContext {
		let bgContext = persistentContainer!.newBackgroundContext()
		bgContext.mergePolicy = NSOverwriteMergePolicy

		return bgContext
    }
	
    func addATask(action: @escaping () -> Void) {
		let taskIsComingFromMainThread = Thread.current.isMainThread

		DispatchQueue.main.async {
			if taskIsComingFromMainThread {
				self.mainThreadTaskArray.append(action)
			} else {
				self.backgroundTaskArray.append(action)
			}
			if !self.isDoingATask {
				self.doTask()
			}
		}
    }

	// MARK: Functions
	
    private func doTask()
    {
//    	print("mainThreadTaskArray \(mainThreadTaskArray)")
//    	print("backgroundTaskArray \(backgroundTaskArray)")
    	
    	if isDoingATask {
			return
    	}

    	if !mainThreadTaskArray.isEmpty {
			isDoingATask = true
			let function = mainThreadTaskArray.first!
			function()
			mainThreadTaskArray.removeFirst(1)
			isDoingATask = false
		} else if !backgroundTaskArray.isEmpty {
			isDoingATask = true
			let function = backgroundTaskArray.first!

			DispatchQueue.background(background: {
//				print("doing a background task - start!")
				function()
//				print("about to finish a background task - end!")
			}, completion:{
				DispatchQueue.main.async {
					self.backgroundTaskArray.removeFirst(1)
					self.isDoingATask = false
				}
			})
		}
    }
}
