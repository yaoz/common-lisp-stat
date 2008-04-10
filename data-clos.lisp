;;; -*- mode: lisp -*-

;;; File:       data-clos.lisp
;;; Author:     AJ Rossini <blindglobe@gmail.com>
;;; Copyright:  (c)2008, AJ Rossini.  BSD, LLGPL, or GPLv2, depending
;;;             on how it arrives.  
;;; Purpose:    data package for lispstat
;;; Time-stamp: <2008-03-12 17:18:42 user>
;;; Creation:   <2008-03-12 17:18:42 user>

;;; What is this talk of 'release'? Klingons do not make software
;;; 'releases'.  Our software 'escapes', leaving a bloody trail of
;;; designers and quality assurance people in its wake.

;;; This organization and structure is new to the 21st Century
;;; version.

;;; data-clos.lisp
;;; 
;;; redoing data structures in a CLOS based framework.
;;;
;;; No real basis for work, there is a bit of new-ness and R-ness to
;;; this work. In particular, the notion of relation is key and
;;; integral to the analysis.  Tables are related and matched
;;; vectors,for example.  "column" vectors are related observations
;;; (by measure/recording) while "row" vectors are related readings
;;; (by case)

(in-package :cl-user)

(defpackage :lisp-stat-data-clos
  (:use :common-lisp
	:clem )
  (:export dataset ;; primary tool/structure
	   modifyData ;; metadata mods
	   importData ;; get it in
	   reshapeData  ;; data mods

	   varNames caseNames
	   ))

(in-package :lisp-stat-data-clos)


;; Need to figure out typed vectors.   We then map a series of typed
;; vectors over to tables where columns are equal typed.  In a sense,
;; this is a relation (1-1) of equal-typed arrays.  For the most part,
;; this ends up making the R data.frame into a relational building
;; block (considering 1-1 mappings using row ID as a relation).  


(defclass table ())

(defclass relation ())

(defclass dataset ()
  ((store :initform nil
	  :initarg :storage
	  :accessor dataset
	  :documentation "Data storage slot.  Should be an array or a
relation,")
   (documentation-string :initform nil
			 :initarg :doc
			 :accessor doc-string
			 :documentation "Information about dataset.")
   (case-labels :initform nil
		:initarg :case-labels 
		:accessor case-labels
		:documentation "labels used for describing cases (doc
metadata), possibly used for merging.")
   (var-labels :initform nil
	       :initarg :var-labels
	       :accessor var-labels
	       :documentation "Variable names."))
  (:documentation "Standard Cases by Variables Dataset."))

;; Need to set up dataset as a table or a relation.  One way or
;; another it should all work out.  TODO:  How do we do multiple
;; inheritance or composite structures?

(defvar my-ds-1 nil 
  "test ds for experiment.")
(setf my-ds-1 (make-instance 'dataset))
my-ds-1


(defun consistent-dataset-p (ds)
  "Test that dataset is internally consistent with metadata.
Ensure that dims of stored data are same as case and var labels."
  (equal (array-dimensions (dataset ds))
       (list (length (var-labels ds))
	     (length (case-labels ds)))))

(defvar my-ds-2 nil 
  "test ds for experiment.")
(setf my-ds-2 (make-instance 'dataset
			     :storage #2A((1 2 3 4 5) (10 20 30 40 50))
			     :doc "This is an interesting dataset"
			     :case-labels (list "a" "b" "c" "d" "e")
			     :var-labels (list "x" "y")))

(consistent-dataset-p my-ds-2)
my-ds-2
(make-array (list 3 5))

(slot-value my-ds-2 'store)
(dataset my-ds-2)
(eq (dataset my-ds-2) (slot-value my-ds-2 'store))

(doc-string my-ds-2)
(case-labels my-ds-2)
(var-labels my-ds-2)
;; need to ensure that for things like the following, that we protect
;; this a bit more so that the results are not going to to be wrong.
;; That would be a bit nasty if the dataset becomes inconsistent.
(setf (var-labels my-ds-2) (list "a" "b"))
(setf (var-labels my-ds-2) (list "a" "b" "c")) ;; Should error!
(consistent-dataset-p my-ds-2) ;; F
(setf (var-labels my-ds-2) (list "a" "b"))
(consistent-dataset-p my-ds-2) ;; T


(defun print-structure-table (ds)
  "example of what we want the methods to look like.  Should be sort
of like a spreadsheet if the storage is a table."
  (print-as-row (var-labels ds))
  (let ((j -1))
    (dolist (i (case-labels ds))
      (princ "%i %v" i (row-extract (dataset ds) (incr j))))))

(defun print-structure-relational (ds)
  "example of what we want the methods to look like.  Should be sort
of like a graph of spreadsheets if the storage is a relational
structure."
  (dolist (k (relations ds))
    (print-as-row (var-labels ds))
    (let ((j -1))
      (dolist (i (case-labels ds))
	(princ "%i %v" i (row-extract (dataset ds) (incr j)))))))
  



(defgeneric extract  (dataform what into-form))

(defmethod extract ((ds dataset) what into-form)
  (reshape (get ds what) into-form))



(defclass data-format())


(defun transpose (x)
  "map NxM to MxN.")

(defun reorder-by-rank (x order &key (by-row t))
  " .")

(defun reorder-by-permutation (x perm &key (by-row t))
  " .")

;;; Need to consider modification APIs
;;; actions are:
;;; - import 
;;; - get/set row names (case names)
;;; -         column names (variable names)
;;; -         dataset values
;;; -         annotation/metadata
;;; -    make sure that we do coherency checking in the exported
;;; -    functions.
;;; -    ... 
;;; - extract/reformat/reshapr a reformed version of the dataset (no
;;;           additional input). 
;;; -         either overwriting or not, i.e. with or without copy.
;;; - check consistency of resulting data with metadata and related
;;;           data information.
;;; - 

;;; Variable-name handling for Tables.  Needs error checking.
(defun varNames (ds)
  (var-labels ds))

(defun set-varNames (ds vN)
  (if (= (length (var-labels ds))
	 (length vN))
      (setf (var-labels ds) vN)
      (error "wrong size.")))

(defsetf varNames set-varNames)

(varNames my-ds-2)
(setf (varNames my-ds-2) (list "a" "b"))
(varNames my-ds-2)


;;; Case-name handling for Tables.  Needs error checking.
(defun caseNames (ds)
  (case-labels ds))

(defun set-caseNames (ds vN)
  (if (= (length (case-labels ds))
	 (length vN))
      (setf (case-labels ds) vN)
      (error "wrong size.")))

(defsetf caseNames set-caseNames)

(defvar origCaseNames nil)
(setf origCaseNames (caseNames my-ds-2))
(setf (caseNames my-ds-2) (list "a" "b" "c" 4 5))
(caseNames my-ds-2)
(setf (caseNames my-ds-2) (list "a" "b" 4 5))
(setf (caseNames my-ds-2) origCaseNames)


(defgeneric importData (source featureList)
  "command to get data into CLS.  Specific methods will need to handle
  files, internal data structures, and DBMS's.")

(defmethod importData ((fileHandle pathfile)
		       (fmt sourceTypes))
  "File-based input for data."
  (let ((newData (getData fileHandle 'csv)))
    (progn
      (if (colnames-in fmt)
	  (setf (varNames newData) (var 1 newData))
	  (setf (varNames newData) nil))
      (if (rownames-in fmt)
	  (setf (caseNames newData) (var 1 newData))
	  (setf (caseNames newData) nil)))))

      
(defmethod importData ((ds array) (fmt list))
  "mapping arrays into CLS data.")


(defmethod importData ((dsSpec DBMSandSQLextract)
		       (fmt mappingTypes))
  "mapping DBMS into CLS data.")


(defgeneric reshapeData (ds spec copy-p)
  "Subset, augment, reshape a table into a table.")

