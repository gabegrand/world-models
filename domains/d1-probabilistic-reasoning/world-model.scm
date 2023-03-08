;; -- Tug-of-war in Church --
;; Author: Gabe Grand (grandg@mit.edu)
;; Adapted from https://v1.probmods.org/conditioning.html#example-reasoning-about-the-tug-of-war

;; -- WORLD MODEL --
(define (run-world-model)
  (rejection-query

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

    ;; -- CONDITIONING STATEMENTS --
    (condition
      (and
        ;; Condition: Tom won against John.
        (won-against '(tom) '(john))
        ;; Condition: John and Mary won against Tom and Sue.
        (won-against '(john mary) '(tom sue))))

    ;; -- QUERY STATEMENT --
    ;; Query: How strong is Mary?
    (strength 'mary)
))

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

;; -- VISUALIZE QUERY --
(density (repeat 1000 run-world-model) "Mary's strength" true)
