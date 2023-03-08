;; -- GENERAL UTILITIES --
;; Membership test that returns true instead of literal list
(define (member? a b)
  (if (member a b) true false))

;; Shuffle a list. Relies on items in the list being unique.
(define (shuffle-unique lst)
  (if (null? lst)
      ()
      (let* ((n (random-integer (length lst)))
             (x (list-ref lst n)))
      (cons x (shuffle-unique (difference lst (list x)))))))

;; Convenience method for accessing properties in association lists
(define (lookup obj key)
  (if (assoc key obj) (rest (assoc key obj)) ()))

;; Geometric distribution
(define (bounded-geometric p n max-n)
  (if (>= n max-n)
      n
      (if (flip p)
        n
        (bounded-geometric p (+ 1 n) max-n))))

;; Shallow flatten
(define (shallow-flatten x)
  (cond ((null? x) '())
        ((pair? x) (append (car x) (shallow-flatten (cdr x))))
        (else (list x))))

;; -- NAMING --
;; All the names that can be used in the conversational context.
(define ALL-NAMES '(avery blake charlie dana))

;; Replace unknown names with "other" (for histograms)
(define (mask-other names)
  (map (lambda (name)
         (cond
           ((null? name) name)
           ((member? name ALL-NAMES) name)
           (else "other")))
        names))

;; -- WORLD MODEL --
;; Generates unique person ids of the format (person-0, person-1, ...)
(define PERSON-PREFIX "person-")
(define new-person-id (make-gensym PERSON-PREFIX))
(define (id->idx person-id)
  (string->number (string-slice (stringify person-id) (string-length PERSON-PREFIX))))

;; Randomly assign a gender
(define person->gender (mem (lambda (person-id)
  (uniform-draw '(male female)))))

;; Randomly-ordered list of person names
(define NAMES (shuffle-unique ALL-NAMES))
(define person->name (mem (lambda (person-id)
  (list-ref NAMES (id->idx person-id)))))

;; Person node in tree
(define (person person-id parent-1-id parent-2-id) (list
  (pair 'person-id person-id)
  (pair 'name person-id)
  (pair 'gender (person->gender person-id))
  (pair 'parent-1-id parent-1-id)
  (pair 'parent-2-id parent-2-id)))

;; Generate the full tree
;; Max tree size is 1 + (sum_{n=0}^{n=MAX-DEPTH} 2 * MAX-WIDTH^n)
(define MAX-WIDTH 3)
(define MAX-DEPTH 2)
(define PARTNER-PROBABILITY 0.5)
(define (generate-tree root-primary-id root-secondary-id depth)
  (let* (
        ;; Create the primary parent
        (parent-1-id (new-person-id))
        (parent-1 (person parent-1-id root-primary-id root-secondary-id)))
  (if (flip PARTNER-PROBABILITY)
    ;; Case: parent-1 has partner
    (let* (
      ;; Create the secondary parent
      (parent-2-id (new-person-id))
      (parent-2 (person parent-2-id () ()))

      ;; Link the parents with a partner relation
      (parent-1 (append parent-1 (list (pair 'partner-id parent-2-id))))
      (parent-2 (append parent-2 (list (pair 'partner-id parent-1-id))))

      ;; Generate children
      (n-children (if (>= depth MAX-DEPTH) 0 (bounded-geometric 0.5 0 MAX-WIDTH)))
      (child-trees (repeat n-children (lambda () (generate-tree parent-1-id parent-2-id (+ depth 1)))))

      ;; Update the parents to point to the children
      (child-ids (map (lambda (t) (lookup (first t) 'person-id)) child-trees))
      (parent-1 (append parent-1 (list (pair 'child-ids child-ids))))
      (parent-2 (append parent-2 (list (pair 'child-ids child-ids)))))
    (append (list parent-1) (list parent-2) (shallow-flatten child-trees)))

    ;; Case: parent-1 has no partner
    (list parent-1))))

;; Generate the global tree.
(define T (generate-tree () () 0))

;; Assign names randomly to (some of) the people in the tree.
(define (add-names-to-tree tree names)
  (if (null? tree) ()
  (let*
    ;; Probability of addding a name to the first person
    ((p (min 1.0 (/ (length names) (length tree))))
    (person (first tree)))
    (if (flip p)
        ;; Name the person
        (let
          ((named-person (update-list person 1 (pair 'name (first names)))))
        (cons named-person (add-names-to-tree (rest tree) (rest names))))
        ;; Don't name the person
        (cons person (add-names-to-tree (rest tree) names))))))

;; Update the tree with the name information.
(define T (add-names-to-tree T NAMES))

;; -- CORE TREE UTILITIES --

;; Returns all instances of person with property `key` equal to `value`
(define filter-by-property
  (mem (lambda (key value)
    (filter (lambda (p) (equal? (lookup p key) value)) T))))

;; Returns the unique instance of person with name.
(define get-person-by-name
  (mem (lambda (name)
    (let
      ((results (filter-by-property 'name name)))
    (if (null? results) () (first results))))))

;; People without a name can be referenced directly by person-id.
(define get-person-by-id
  (mem (lambda (person-id)
    (if (null? person-id)
        ()
        (let ((idx (id->idx person-id)))
          (if (>= idx (length T)) () (list-ref T idx)))))))

;; Get a person object either by name or person-id.
(define get-person
  (mem (lambda (person-ref)
    (cond
      ((null? person-ref) ())
      ((member? person-ref NAMES) (get-person-by-name person-ref))
      (else (get-person-by-id person-ref))))))

;; Get a property of a person.
(define get-property
  (mem (lambda (name key)
    (lookup (get-person name) key))))

;; List of all the people in the tree with names.
(define named-people (filter (lambda (person) (not (null? person))) (map get-person NAMES)))

;; -- CONCEPTUAL SYSTEM --

;; Gets the partner of a person.
(define (partner-of name)
  (get-property (get-property name 'partner-id) 'name))

;; Gets the parents of a person.
(define (parents-of name)
  (let* ((parent-1-id (get-property name 'parent-1-id))
        (parent-1-name (get-property parent-1-id 'name))
        (parent-2-id (get-property name 'parent-2-id))
        (parent-2-name (get-property parent-2-id 'name)))
    (list parent-1-name parent-2-name)))

;; Gets the grandparents of a person.
(define (grandparents-of name)
  (let ((parent-1 (first (parents-of name))))
    (parents-of parent-1)))

;; Gets the children of a person.
(define (children-of name)
  (let ((child-ids (get-property name 'child-ids)))
    (map (lambda (child-id) (get-property child-id 'name)) child-ids)))

;; Gets the siblings of a person.
(define (siblings-of name)
  (let* ((parent-1-id (get-property name 'parent-1-id))
        (child-ids (get-property parent-1-id 'child-ids))
        (child-names (map (lambda (child-id) (get-property child-id 'name)) child-ids)))
    (filter (lambda (child-name) (not (equal? child-name name))) child-names)))

;; -- QUANTIFIERS --
;; predicate :: name -> boolean

(define (map-tree predicate)
  (map (lambda (x) (predicate (lookup x 'name))) T))

(define (filter-tree predicate)
  (filter (lambda (x) (predicate (lookup x 'name))) T))

(define (exists predicate)
  (some (map-tree predicate)))

;; -- BOOLEAN RELATIONS --
(define (partner-of? name_a name_b)
  (equal? name_a (partner-of name_b)))

(define (parent-of? name_a name_b)
  (member? name_a (parents-of name_b)))

(define (father-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'male)
      (parent-of? name_a name_b)))

(define (mother-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'female)
      (parent-of? name_a name_b)))

(define (grandparent-of? name_a name_b)
  (member? name_a (grandparents-of name_b)))

(define (grandfather-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'male)
      (grandparent-of? name_a name_b)))

(define (grandmother-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'female)
      (grandparent-of? name_a name_b)))

(define (child-of? name_a name_b)
  (member? name_a (children-of name_b)))

(define (son-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'male)
      (child-of? name_a name_b)))

(define (daughter-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'female)
      (child-of? name_a name_b)))

(define (sibling-of? name_a name_b)
  (member? name_a (siblings-of name_b)))

(define (brother-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'male)
      (sibling-of? name_a name_b)))

(define (sister-of? name_a name_b)
  (and (equal? (get-property name_a 'gender) 'female)
      (sibling-of? name_a name_b)))

;; -- TRANSLATION EXAMPLE 1 --
;; Condition: Ryan's partner is Taylor.
(condition (partner-of? 'ryan 'taylor))

;; Condition: Taylor is the mother of Sam.
(condition (mother-of? 'taylor 'sam))

;; Condition: Sam's father is Ryan.
(condition (father-of? 'ryan 'sam))

;; Condition: Sam has two siblings.
(condition (= (length (siblings-of 'sam)) 2))

;; Condition: Sam has a brother.
(condition
  (exists (lambda (x)
    (brother-of? x 'sam))))

;; Condition: Payton's partner has a kid named Kyle.
(condition
  (exists (lambda (x) (and
                        (partner-of? x 'payton)
                        (child-of? 'kyle x)))))

;; Condition: Payton's partner has a sister who has a son named Sam.
(condition
  (exists (lambda (x) (and
                        (partner-of? x 'payton)
                        (exists (lambda (y) (and
                                              (sister-of? y x)
                                              (son-of? 'sam y))))))))

;; Query: Who are Sam's parents?
(query (parents-of 'sam))

;; Query: How many children does Kyle have?
(query (length (children-of 'kyle)))

;; Query: Who is Ryan's grandfather?
(query
  (filter-tree
    (lambda (x) (grandfather-of? x 'ryan))))

;; Query: Does Taylor have a sister?
(query
  (exists (lambda (x)
    (sister-of? x 'taylor))))

;; Query: Which of Sam's parents is the daughter of Taylor?
(query
  (filter-tree
    (lambda (x) (and
                  (parent-of? x 'sam)
                  (daughter-of? x 'taylor)))))

;; -- TRANSLATION EXAMPLE 2 --
