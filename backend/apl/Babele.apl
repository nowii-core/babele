⍝ Babele APL Compiler - array programming backend
⍝ Nota: APL usa simboli speciali per le operazioni

⍝ Tipo di dato primitivo
Ty ← 'Int' 'Float' 'String' 'Bool' 'Void'

⍝ Rappresentazione dell'AST come array nidificato
⍝ [tipo, valore, figli...]
AST_Int ← {⊂'Int' ⍵}
AST_Str ← {⊂'Str' ⍵}
AST_Var ← {⊂'Var' ⍵}
AST_Add ← {⊂'Add' ⍺ ⍵}
AST_Print ← {⊂'Print' ⍵}

⍝ Inversione di un array
reverse ← ⌽

⍝ Somma di un vettore
sum ← +/

⍝ Prodotto di un vettore
prod ← ×/

⍝ Media
mean ← {(+/⍵)÷≢⍵}

⍝ Conteggio elementi
count ← ≢

⍝ Filtro elementi maggiori di 0
positive ← {⍵/⍨⍵>0}

⍝ Genera i primi N numeri naturali
naturals ← {⍳⍵}

⍝ Trasposta di una matrice
transpose ← ⍉

⍝ Prodotto interno (dot product)
dot ← +/×

⍝ Prodotto esterno
outer ← ∘.×

⍝ Test del compilatore
test ← {
  n ← 10
  v ← naturals n
  s ← sum v
  p ← prod v
  m ← mean v
  s p m
}

⍝ Main
result ← test
result
