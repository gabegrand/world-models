;; -- Visual Reasoning in Church --
;; Author: Lio Wong (zyzzyva@mit.edu)

;; Objects have a shape attribute, which is a choice of cube, sphere, or cylinder shape categories.
(define choose-shape
  (mem (lambda (obj-id)
         (pair 'shape (uniform-draw '(mug can bowl))))))

;; Objects have a color attribute that is drawn from a predefined set of RGB values.
(define choose-color
  (mem (lambda (obj-id)
         (pair 'color (uniform-draw (list
                                      (list 255 0 0)
                                      (list 0 0 255)
                                      (list 0 255 0)
                                      (list 255 255 0)
                                    ))))))
;; An object is an object ID, and the object's attribute types and their values.
(define object (mem (lambda (obj-id) (list
                                      (pair 'object-id obj-id)
                                      (choose-shape obj-id)
                                      (choose-color obj-id)))))

;; Scenes can have a maximum of 12 objects.
(define max-objects 12)
;; The number of objects in a scene tends to be not too large, and is capped at the maximum number of objects.
(define choose-num-objects
  (mem (lambda (scene-id) (floor (min max-objects (* max-objects (exponential 1)))))))

;; Then, for each object we intend to generate, generate an object indexical, and associate it with a choice of attributes.
(define obj-id-gensym (make-gensym "obj-"))
(define (generate-n-objects scene-id total-objects)
    (if (= total-objects 0)
     (list (object (obj-id-gensym)))
     (cons (object (obj-id-gensym)) (generate-n-objects scene-id (- total-objects 1)))))
(define objects-in-scene (mem (lambda (scene-id) (generate-n-objects scene-id (choose-num-objects scene-id)))))


;; An object is red if it is of this continuous color value.
(define red (list 255 0 0))
;; An object is blue if it is of this continuous color value.
(define blue (list 0 0 255))
;; An object is green if it is of this continuous color value.
(define green (list 0 255 0))
;; An object is yellow if it is of this continuous color value.
(define yellow (list 255 255 0))

;; Check if an object is of a given shape.
(define is-shape?  (lambda (shape) (lambda (object) (equal? (cdr (assoc 'shape object)) shape))))
;; Check if an object is of a given named color.
(define is-color?  (lambda (color) (lambda (object) (equal? (cdr (assoc 'color object)) color))))

;; Select only objects from the scene of a given color.
(define filter-color(lambda (color) (lambda (object-list) (filter (is-color? color) object-list))))

;; Select only objects from the scene of a given shape.
(define filter-shape (lambda (shape) (lambda (object-list) (filter (is-shape? shape) object-list))))