"Babele Smalltalk Compiler - pure OOP backend"

Object subclass: #BabeleCompiler
    instanceVariableNames: 'environment output'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Babele'.

BabeleCompiler >> initialize [
    environment := Dictionary new.
    output := WriteStream on: String new.
].

BabeleCompiler >> declareVariable: aString ofType: aType [
    environment at: aString put: aType.
    ^ self
].

BabeleCompiler >> lookupVariable: aString [
    ^ environment at: aString ifAbsent: [ nil ]
].

BabeleCompiler >> emit: aString [
    output nextPutAll: aString.
    output nextPut: Character lf.
].

BabeleCompiler >> emitPreamble [
    self emit: '/* Generato da Babele */'.
    self emit: '#include <stdio.h>'.
    self emit: ''.
    self emit: 'int main(void) {'.
].

BabeleCompiler >> emitEpilogue [
    self emit: '    return 0;'.
    self emit: '}'.
].

BabeleCompiler >> emitVariable: aName withValue: aValue [
    self emit: '    const char* ', aName, ' = "', aValue, '";'.
].

BabeleCompiler >> emitPrint: aName [
    self emit: '    printf("%s\n", ', aName, ');'.
].

BabeleCompiler >> compileHello [
    self emitPreamble.
    self declareVariable: 'saluto' ofType: #String.
    self emitVariable: 'saluto' withValue: 'Ciao, mondo!'.
    self emitPrint: 'saluto'.
    self emitEpilogue.
    ^ output contents
].

Object subclass: #BabeleRuntime
    instanceVariableNames: 'stack'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Babele'.

BabeleRuntime >> initialize [
    stack := OrderedCollection new.
].

BabeleRuntime >> push: aValue [
    stack addLast: aValue.
].

BabeleRuntime >> pop [
    ^ stack removeLast.
].

BabeleRuntime >> peek [
    ^ stack last.
].

BabeleRuntime >> print [
    Transcript show: self pop printString; cr.
].

BabeleCompiler new compileHello.
