;; Now, let's translate some user-defined statements.
;; Each statement begins with either `Condition` or `Query`.
;; `Condition` statements provide facts about the scenario.
;; `Query` statements are questions that evaluate quantities of interest.

;; Condition: Alice won against Bob.
(condition (won-against '(alice) '(bob)))

;; Condition: John and Mary won against Tom and Sue.
(condition (won-against '(john mary) '(tom sue)))

;; Query: If Mary played against Tom, who would win?
(query (won-against '(mary) '(tom)))

;; Certain statements are underspecified and require some interpretation. For example:
;; Condition: Sue is very strong.
(condition (> (strength 'sue) 75))

;; We can `define` new constructs that are useful for translation. For example:
;; Condition: Bob is stronger than John.
(define (stronger-than? player-1 player-2)
  (> (strength player-1) (strength player-2)))
(condition (stronger-than? 'bob 'john))

;; Query: Is Sue stronger than Mary?
(query (stronger-than? 'sue 'mary))

;; Condition: A couple of the players are stronger than John.
(condition (>= (count (map (lambda (player) (stronger-than? player 'john) players)) 2)))