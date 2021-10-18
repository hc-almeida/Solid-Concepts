
/*
 O princípio da substituição de Liskov: Diz que objetos da superclasse, ou seja classe mãe,
 podem ser substituídos por objetos de subclasses, classes filhas, sem quebrar a aplicação.
 Caso a super-classe não lance exceções então as sub-classes, ambém não devem lançar,
 exceto quando estas exceções são subtipos das exceções lançadas pelos métodos da super-classe
 */

import UIKit

// -- Problema: Um dos exemplos mais comuns sobre o princípio de Liskov, é o exemplo do Quadrado e Retângulo. Afinal, eles são bem parecidos a única diferença é que o quadrado é um tipo especial de retângulo que possuí todos os lados iguais.


// Classe retangulo que recebe altura e largura pelo init

class Rectangle {
    var width: Int
    var height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func area() -> Int {
        width * height
    }
}

class Square: Rectangle { } // Classe quadrado herda de retangulo.

// Ambas as classes conseguem calcular a área, mas temos um problema, um quadrado tem lados iguais, nao precisa passar altura e largura.

let square = Square(width: 5, height: 10)

let rectangle = Rectangle(width: 7, height: 5)

// -- Problema 2: Se mudar o init da classe filha para receber apenas um lado..

class Square2: Rectangle {
    
    init(width: Int) {
        super.init(width: width, height: width)
    }
}

let square2 = Square2(width: 5)

/*
 Ao fazer isso, estamos alterando a precondição da classe do quadrado e agora ela se torna mais forte
 que a da classe mãe. Em um quadrado, ambos os lados precisam ser iguais. Em um retângulo, não.
 De acordo com o princípio de Liskov, não poderíamos fazer essa herança.
 */

// ----------------------------------

// -- Solução: Usar protocolos pode ser uma boa prática

protocol Geometrics {
    func area() -> Int
}

class Rectangle1: Geometrics {
    var width: Int
    var height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func area() -> Int {
        width * height
    }
}

class Square3: Geometrics {
    var edge: Int

    init(edge: Int) {
        self.edge = edge
    }

    func area() -> Int {
        edge * edge
    }
}

let square3 = Square3(edge: 5)
print(square3.area())
let rectangle1 = Rectangle1(width: 7, height: 5)
print(rectangle1.area())

let objects: [Geometrics] = [square3, rectangle1]

objects.forEach { object in
    print(object.area())
}


// ----------------------------------

/*
 
 O príncio de Liskov está ligado com heranças e acoplamento.
 
 Heranças: Quando utilizamos herança, devemos tomar cuidado com os contratos que estamos definindo, pois utilizar herança faz com que classes filhas implementem ou tenham sem necessidade métodos que estão fora do seu escopo. Existe duas coisas que são importante levar em consideração ao utilizar herança, que são pré (input) e pós-condições (output) que a super classe ou classe mãe definiu.

 Acoplamento: Sempre que uma classe depende da outra para existir, é acoplamento. E, dependendo da forma com que esse acoplamento é feito, podemos ter problemas no futuro e isso fica fortemente ligado com as pré e pós-condições.
 
    - > A classe filha, em tese, só deveria poder afrouxar a precondição.
 
        - Ex: Pense no caso em que a classe mãe tem um método que recebe inteiros de 1 a 100. A classe filho pode sobrescrever esse método e permitir o método a receber inteiros de 1 a 200. Veja que, dessa forma, todo o código que já fazia uso da classe pai continua funcionando.
 
    - > Por outro lado, a pós-condição só pode ser apertada; ela nunca pode afrouxar.
        - Ex: Pense em um método que devolve um inteiro, de 1 a 100. As classes que a usam entendem isso. A classe filha sobrescreve o método e devolve números só entre 1 a 50. Os clientes continuarão a funcionar, afinal eles já entendiam saídas entre 1 e 50.
 */
