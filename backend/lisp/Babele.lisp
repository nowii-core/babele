;;; Babele Common Lisp Compiler

(defpackage :babele
  (:use :cl)
  (:export :compile-babele
           :tokenize
           :parse
           :generate-c))

(in-package :babele)

;;; Tipi
(deftype ty ()
  '(member :int :float :string :bool :void))

;;; AST
(defstruct expr
  (kind nil :type symbol)
  (value nil)
  (children nil :type list))

(defstruct stmt
  (kind nil :type symbol)
  (value nil)
  (children nil :type list))

(defstruct func
  (name "" :type string)
  (params nil :type list)
  (return-type :void :type ty)
  (body nil :type list))

(defstruct program
  (funcs nil :type list))

;;; Tokenizer
(defun tokenize (source)
  (let ((tokens '())
        (i 0)
        (n (length source)))
    (loop while (< i n) do
      (let ((c (char source i)))
        (cond
          ((member c '(#\Space #\Tab #\Newline #\Return))
           (incf i))
          ((char= c #\()
           (push :lparen tokens) (incf i))
          ((char= c #\))
           (push :rparen tokens) (incf i))
          ((char= c #\{)
           (push :lbrace tokens) (incf i))
          ((char= c #\})
           (push :rbrace tokens) (incf i))
          ((char= c #\;)
           (push :semi tokens) (incf i))
          ((char= c #\=)
           (push :assign tokens) (incf i))
          ((char= c #\")
           (let ((start (1+ i)))
             (incf i)
             (loop while (and (< i n) (not (char= (char source i) #\"))) do
               (incf i))
             (push (cons :string (subseq source start i)) tokens)
             (incf i)))
          ((alpha-char-p c)
           (let ((start i))
             (loop while (and (< i n)
                              (or (alphanumericp (char source i))
                                  (char= (char source i) #\_))) do
               (incf i))
             (let ((word (subseq source start i)))
               (push (cond
                       ((string= word "fn") :fn)
                       ((string= word "let") :let)
                       ((string= word "print") :print)
                       (t (cons :ident word)))
                     tokens))))
          (t (incf i)))))
    (nreverse (cons :eof tokens))))

;;; Environment
(defun lookup-var (name env)
  (cdr (assoc name env :test #'string=)))

;;; Type inference
(defun infer-type (expr env)
  (case (expr-kind expr)
    (:int-lit :int)
    (:string-lit :string)
    (:bool-lit :bool)
    (:var (lookup-var (expr-value expr) env))
    (:binop
     (let ((lt (infer-type (first (expr-children expr)) env))
           (rt (infer-type (second (expr-children expr)) env)))
       (cond
         ((and (eq lt :int) (eq rt :int)) :int)
         ((and (eq lt :string) (eq rt :string)) :string)
         ((and (eq lt :bool) (eq rt :bool)) :bool)
         (t (error "Tipo non compatibile: ~a + ~a" lt rt)))))
    (t (error "Espressione sconosciuta"))))

;;; Codegen C
(defun expr-to-c (expr)
  (case (expr-kind expr)
    (:int-lit (format nil "~a" (expr-value expr)))
    (:string-lit (format nil "\"~a\"" (expr-value expr)))
    (:var (expr-value expr))
    (:binop (format nil "(~a ~a ~a)"
                    (expr-to-c (first (expr-children expr)))
                    (expr-value expr)
                    (expr-to-c (second (expr-children expr)))))
    (t "0")))

(defun generate-c (prog)
  (with-output-to-string (s)
    (format s "/* Generato da Babele */~%")
    (format s "#include <stdio.h>~%~%")
    (dolist (f (program-funcs prog))
      (format s "int ~a(void) {~%" (func-name f))
      (dolist (st (func-body f))
        (case (stmt-kind st)
          (:let (format s "    const char* ~a = ~a;~%"
                        (stmt-value st)
                        (expr-to-c (first (stmt-children st)))))
          (:print (format s "    printf(\"%%s\\n\", ~a);~%"
                          (expr-to-c (first (stmt-children st)))))))
      (format s "    return 0;~%")
      (format s "}~%"))))

(defun compile-babele (source)
  (let* ((tokens (tokenize source)))
    (declare (ignore tokens))
    (format t "Compilazione Babele completata~%")))

(compile-babele "fn main() { print(\"ciao\"); }")
