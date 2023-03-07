;; -- CONDITION AND QUERY STATEMENTS --
;; Now, let's translate some user-defined statements.
;; Each statement begins with either `Condition` or `Query`.
;; `Condition` statements provide facts about the scenario.
;; `Query` statements are questions that evaluate quantities of interest.

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

;; Condition: Payton's partner has a brother named Kyle.
(condition
  (exists (lambda (x) (and
                        (partner-of? x 'payton)
                        (brother-of? 'kyle x)))))

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