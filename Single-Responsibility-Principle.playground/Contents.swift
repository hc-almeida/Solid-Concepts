import UIKit

/*
 Definição: O SRP - Single Responsibility Principle, é justamente o princípio que nos lembra de coesão. Esse princípio nos diz que a classe deve ter uma, e apenas uma, razão para mudar
 */

// -- Problema: classe com muitas responsabilidades

class TwitterManager {
    
    private func request() -> Data {
        return Data()
    }
    
    private func convertJsonToModel(with data: Data) -> [AnyObject] {
        return [AnyObject]()
    }
    
    private func saveInCoreData(with models: [AnyObject]) {
        
    }
     
    public func create() {
        let data = request()
        let model = convertJsonToModel(with: data)
        saveInCoreData(with: model)
    }
}

// -- Solução: Responsabilidades dividas em diversas classes.

class FBRequestManager {
    
    func request() -> Data {
        return Data()
    }
}

class ParseManeger {
    
    func convertJsonToModel(with data: Data) -> [AnyObject] {
        return [AnyObject]()
    }
}

class CoreDataManeger {
    
    func save(with models: [AnyObject]) { }
}

class FBMananger {
    
    private let request: FBRequestManager
    private let parse: ParseManeger
    private let coreData: CoreDataManeger
    
    init(request: FBRequestManager, parse: ParseManeger, coreData: CoreDataManeger) {
        self.request = request
        self.parse = parse
        self.coreData = coreData
    }
    
    func create() {
        let data = request.request()
        let object = parse.convertJsonToModel(with: data)
        coreData.save(with: object)
    }
}
