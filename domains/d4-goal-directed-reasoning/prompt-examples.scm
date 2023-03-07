;; Condition: Bob likes pizza.
(condition (> (restaurant_utility 'bob 'pizza) 0))

;; Condition: Bob really likes pizza.
(condition (> (restaurant_utility 'bob 'pizza) 10))

;; Condition: Bob does not like pizza, and he actually despises vegetables.
(condition
    (and (< (restaurant_utility 'bob 'pizza) 0)
         (< (restaurant_utility 'bob 'vegetarian) 10)))

;; Condition: The pizza place is not open.
(condition (not (is_open 'pizza)))

;; Condition: Bob walked North on Danner.
(condition (exists_action 'bob (lambda (action)
                      (and
                      (is_subject_of_action? action 'bob)
                      (is_action? action 'is_walking)
                      (is_action? action 'north)
                      (is_preposition_of_action? action 'on)
                      (is_location_of_action? action 'danner)))))

;; Query: Does Bob like vegetarian food?
(query (> (restaurant_utility 'bob 'vegetarian) 0))

;; Condition: Where is Bob going?
(query (get_actions 'bob (lambda (action)
            (and (is_subject_of_action? action 'bob)
                 (is_action? action 'is_going)))))

;; Query: Where will Bob go to for lunch?
(query (get_location (first
         (get_actions 'bob (lambda (action)
                      (and (and
                      (is_subject_of_action? action 'bob)
                      (is_action? action 'is_going))
                      (is_preposition_of_action? action 'to)))))))