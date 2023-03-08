;; -- WORLD MODEL --
;; This Church program models a tug-of-war game between teams of players.
;; Each player has a strength, with strength value 50 being about average.
(define strength (mem (lambda (player) (gaussian 50 20))))

;; Each player has an intrinsic laziness frequency.
(define laziness (mem (lambda (player) (uniform 0 1))))

;; The team's strength is the sum of the players' strengths.
;; When a player is lazy in a match, they pull with half their strength.
(define (team-strength team)
  (sum
    (map (lambda (player)
            (if (flip (laziness player))
                (/ (strength player) 2)
                (strength player)))
      team)))

;; The winner of the match is the stronger team.
;; Returns true if team-1 won against team-2, else false.
(define (won-against team-1 team-2)
  (> (team-strength team-1) (team-strength team-2)))

;; -- UTILITY FUNCTIONS --
(define (count bool-list)
  (sum (map boolean->number bool-list)))

(define (argmax f lst)
  (if (null? (cdr lst))
    (car lst)
    (let ((higher-items (filter (lambda (x) (> (f x) (f (car lst)))) (cdr lst))))
      (if (null? higher-items)
        (car lst)
        (argmax f higher-items)))))

(define (argmin f lst)
  (if (null? (cdr lst))
    (car lst)
    (let ((lower-items (filter (lambda (x) (< (f x) (f (car lst)))) (cdr lst))))
      (if (null? lower-items)
        (car lst)
        (argmin f lower-items)))))

;; -- TRANSLATION EXAMPLE 1 --
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

;; Condition: Sue, Mary, and Bob are all stronger than John.
(condition (all (map (lambda (player) (stronger-than? player 'john)))))

;; -- TRANSLATION EXAMPLE 2 --
