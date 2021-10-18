/*
 Princípio da segregação de interface (ISP — Interface segregation principle):
    Nenhum cliente deve ser forçado a depender de métodos que não utiliza.
 */

import UIKit


/*
 Esse príncipio está ligado com coesão, segue o mesmo contexto do SPR, quanto mais coesa a
 classe mais claro é a responsabilidade dela, esse mesmo pressuposto se aplica para as interfaces.
 
 */

// -- Situação: Digamos que tenhamos um protocolo de `cache` no nosso aplicativo e nele podemos salvar o `Access Token` e recuperar o identificador do usuário, UserID

protocol Cache {
    func retriveAccessToken() -> Token?
    func retriveUserId() -> String?
    func save(value: Data)
}

/*
 Requisitos desses funcionalidades: Serão usados duas formas diferentes para salvar os dados, o token de usuário será usando
 o `Keychain` enquanto que o `UserId` será salvo no `UserDefaults`.
 */

class UserCache: Cache {
    //Retrive using UserDefaults
    func retriveUserId() -> String? {
        UserDefaults.standard.string(forKey: "UserId")
    }
    
    //Save using UserDefaults
    func save(value: Data) {
        UserDefaults.standard.setValue(value, forKey: "UserId")
    }
    
    func retriveAccessToken() -> Token? {
        nil
    }
}

class AccessTokenCache: Cache {
    //Retrive using Keychain
    func retriveAccessToken() -> Token? {
        let query = keychainQuery(withKey: "UserId")
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            return nil
        }
        return try? JSONDecoder().decode(Token.self, from: resultsData)
    }
    
    //Save using Keychain
    func save(value: Data) {
        let query = keychainQuery(withKey: "AccessToken")
        
        query.setValue(value, forKey: kSecValueData as String)
        let status = SecItemAdd(query, nil)
        print("Update status: ", status)
    }
    
    func retriveUserId() -> String? {
        nil
    }
    
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
}


/*
 Problema: Aqui temos um exemplo do ISP sendo quebrado. Podemos notar que para implementar o protocolo de Cache, as classes concretas precisam implementar métodos fora do seu contexto e domínio, quebrando assim a responsabilidade única que deveriam ter para ser mais coesas e desta forma causando problemas de acoplamento onde caso tenhamos mudanças em algum dos métodos de uma classe poderá impactar causando efeitos colaterais na outra classe.
 */

// ---------------------------------

// -- Solução: A melhor forma é separar as responsabilidades, quebrando os métodos do Cache em outros protocolos.


protocol Cache2  {
    func save(value: Data)
}

protocol UserDefaultsCacheable: Cache2 {
    func retriveUserId() -> String?
}

protocol KeychainCacheable: Cache2 {
    func retriveAccessToken() -> Token?
}

// -- As implementações concretas iram implementar só o que realmente precisam.

class UserCache2: UserDefaultsCacheable {
    //Retrive using UserDefaults
    func retriveUserId() -> String? {
        UserDefaults.standard.string(forKey: "UserId")
    }
    
    //Save using UserDefaults
    func save(value: Data) {
        UserDefaults.standard.setValue(value, forKey: "UserId")
    }
}

class AccessTokenCache2: KeychainCacheable {
    
    func retriveAccessToken() -> Token? { }
    
    func save(value: Data) { }

}

/*
    Código agora se tornou mais coeso, pois cada responsabilidade está dentro do seu devido contexto
    e além disso pode remover as implementações vazias ou que retornavam valores opcionais
 */
