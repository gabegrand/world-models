;; -- Planning in Church --
;; Author: Lio Wong (zyzzyva@mit.edu)

(define gridworld (list
     (list 'ames 'lawn 'lawn 'lawn 'sushi)
     (list 'ames 'lawn 'lawn 'lawn 'danner)
     (list 'office 'barlow 'barlow 'barlow 'danner)
     (list 'ames 'lawn 'lawn 'lawn 'danner)
     (list 'ames 'lawn 'lawn 'lawn 'vegetarian)
     (list 'pizza 'carson 'carson 'carson 'danner)
))
(define restaurants (list 'sushi 'pizza 'vegetarian))

(define initial_x 1)
(define initial_y 3)


(define has_bike (mem (lambda (agent-id) (flip))))
(define available_motions (mem (lambda (agent-id) (if (has_bike agent-id) (list 'is_walking 'is_biking) (list 'is_walking)))))
(define directions (list 'west 'east 'north 'south))
(define available_actions (mem (lambda (agent-id) (cons (pair 'stay 'stay) (cartesian_product (available_motions agent-id) directions)))))

(define is_open (mem (lambda (restaurant_type) (flip))))
(define POSITIVE_UTILITY_MEAN 10)
(define NEGATIVE_UTILITY_MEAN -10)
(define UTILITY_VARIANCE 1)
(define restaurant_utility (mem (lambda (agent-id restaurant_type)
                           (uniform-draw
                           (list
                           (gaussian POSITIVE_UTILITY_MEAN UTILITY_VARIANCE)
                           (gaussian NEGATIVE_UTILITY_MEAN UTILITY_VARIANCE)
)))))

(define motion_utility (mem (lambda (agent-id location_type motion_type)
  (case location_type
      (('lawn) (case motion_type
                (('is_biking) -1)
                (('is_walking) -0.2)
                (('is_staying) 0)
                (else 0))
                )
      (else (case motion_type
                (('is_biking) -0.01)
                (('is_walking) -0.2)
                (('is_staying) 0)
                (else 0)))
))))

(define food_utility (mem (lambda (agent-id location_type)
  (case location_type
      (('lawn) 0)
      (('ames) 0)
      (('barlow) 0)
      (('carson) 0)
      (('danner) 0)
      (('office) 0)
      (else
       (if (is_open location_type) (restaurant_utility agent-id location_type) NEGATIVE_UTILITY_MEAN))
))))

(define utility_function (mem (lambda (agent-id gridworld state_x state_y action)
        (let ((location_type (get_gridworld_at gridworld state_x state_y)))
        (let ((motion_type (car action)))
        (let ((state_food_utility (food_utility agent-id location_type)))
        (let ((state_motion_utility (motion_utility agent-id location_type motion_type)))
        (+ state_food_utility state_motion_utility))))))))

(define get_gridworld_at (lambda (gridworld x y)
   (list-elt (list-elt gridworld y) x)
))
(define x_increment (lambda (direction)
  (case direction
      (('west) -1)
      (('east) 1)
      (('north) 0)
      (('south) 0)
      (('stay) 0)
)))
(define y_increment (lambda (direction)
  (case direction
      (('north) -1)
      (('south) 1)
      (('west) 0)
      (('east) 0)
      (('stay) 0)
)))
(define gridworld_max_x (lambda (gridworld) (length (list-elt gridworld 1))))
(define gridworld_max_y (lambda (gridworld) (length gridworld)))
(define gridworld_transition (lambda (gridworld current_x current_y action)
   (let ((direction (cdr action)))
   (let ((next_x (if (>= current_x (gridworld_max_x gridworld)) current_x (+ (x_increment direction) current_x))))
   (let ((next_x (if (< next_x 1) current_x next_x)))
   (let ((next_y (if (>= current_y (gridworld_max_y gridworld)) current_y (+ (y_increment direction) current_y))))
   (let ((next_y (if (< next_y 1) current_y next_y)))
   (let ((next_state (get_gridworld_at gridworld next_x next_y)))
   (list next_state next_x next_y)
))))))))

(define value_function (mem (lambda (agent-id curr_iteration gridworld state_x state_y)
   (if (equal? curr_iteration -1) 0
   (let ((prev_optimal_action_value (optimal_action_value agent-id (- curr_iteration 1) gridworld state_x state_y)))
   (cdr prev_optimal_action_value))
))))

(define available_actions_to_values (mem (lambda (agent-id curr_iteration gridworld state_x state_y)
       (map (lambda (action)
              (let ((utility (utility_function agent-id gridworld state_x state_y action)))
              (let ((next_state (gridworld_transition gridworld state_x state_y action)))
              (let ((next_state_x (second next_state)))
              (let ((next_state_y (third next_state)))
              (let ((next_state_value (value_function agent-id curr_iteration gridworld next_state_x next_state_y)))
              (pair action (+ utility next_state_value))
        ))))))
        (available_actions agent-id))
)))

(define optimal_action_value (mem (lambda (agent-id curr_iteration gridworld state_x state_y)
      (let ((actions_to_values (available_actions_to_values agent-id curr_iteration gridworld state_x state_y)))
      (max_cdr actions_to_values)
      )
)))

(define MAX_ITERATIONS 20)
(define should_terminate (mem (lambda (agent-id gridworld state_x state_y)
        (if (<= (value_function agent-id MAX_ITERATIONS gridworld initial_x initial_y) 0) true
        (let ((location_type (get_gridworld_at gridworld state_x state_y)))
        (let ((state_food_utility (food_utility agent-id location_type)))
                           (> state_food_utility 0)))))))



(define optimal_policy_from_initial_state (mem (lambda (agent-id gridworld state_x state_y)
     (if (should_terminate agent-id gridworld state_x state_y) ()
     (let ((curr_optimal_action_value (optimal_action_value agent-id MAX_ITERATIONS gridworld state_x state_y)))
     (let ((curr_optimal_action (car curr_optimal_action_value)))
     (let ((next_state (gridworld_transition gridworld state_x state_y curr_optimal_action)))
     (let ((next_state_x (second next_state)))
     (let ((next_state_y (third next_state)))
     (let ((remaining_policy (optimal_policy_from_initial_state agent-id gridworld next_state_x next_state_y)))
     (cons curr_optimal_action remaining_policy)
))))))))))

(define trajectory_from_initial_state (mem (lambda (agent-id gridworld state_x state_y)
     (if (should_terminate agent-id gridworld state_x state_y) ()
     (let ((curr_optimal_action_value (optimal_action_value agent-id MAX_ITERATIONS gridworld state_x state_y)))
     (let ((curr_optimal_action (car curr_optimal_action_value)))
     (let ((next_state (gridworld_transition gridworld state_x state_y curr_optimal_action)))
     (let ((next_state_location (first next_state)))
     (let ((next_state_x (second next_state)))
     (let ((next_state_y (third next_state)))
     (let ((remaining_trajectory (trajectory_from_initial_state agent-id gridworld next_state_x next_state_y)))
     (cons next_state_location remaining_trajectory))
))))))))))

(define optimal_policy (mem (lambda (agent-id gridworld initial_state_x initial_state_y)
        (cons (pair 'start 'start) (optimal_policy_from_initial_state agent-id gridworld initial_state_x initial_state_y)))))

(define optimal_trajectory (mem (lambda (agent-id gridworld initial_state_x initial_state_y)
        (cons (get_gridworld_at gridworld initial_state_x initial_state_y) (trajectory_from_initial_state agent-id gridworld initial_state_x initial_state_y))
)))

(define optimal_policy_with_trajectory (mem (lambda (agent-id gridworld initial_state_x initial_state_y)
        (zip (optimal_policy agent-id gridworld initial_state_x initial_state_y) (optimal_trajectory agent-id gridworld initial_state_x initial_state_y))
)))

(define get_terminal_goal_state (mem (lambda (agent-id gridworld initial_state_x initial_state_y)
        (last (optimal_trajectory agent-id gridworld initial_state_x initial_state_y)))))

(define trajectory_has_location_type? (mem (lambda (agent-id location_type gridworld initial_state_x initial_state_y)
        (member? location_type (optimal_trajectory agent-id gridworld initial_state_x initial_state_y))
)))
(define policy_has_motion_type? (mem (lambda (agent-id motion_type gridworld initial_state_x initial_state_y)
      (let ((policy_motions (map (lambda (action) (first action)) (optimal_policy agent-id gridworld initial_state_x initial_state_y))))
      (member? motion_type policy_motions)
))))
(define policy_and_trajectory_has_motion_at_location? (mem (lambda (agent-id motion_type location_type gridworld initial_state_x initial_state_y)
      (let ((policy_motions (map (lambda (action) (first action)) (optimal_policy agent-id gridworld initial_state_x initial_state_y))))
      (let ((trajectory (optimal_trajectory agent-id gridworld initial_state_x initial_state_y)))
      (let ((motions_at_locations (zip policy_motions trajectory)))
      (member? (list motion_type location_type) motions_at_locations)
))))))

(define motion_at_location? (mem (lambda (agent-id motion_type location_type gridworld initial_state_x initial_state_y)
      (let ((policy_motions (map (lambda (action) (first action)) (optimal_policy agent-id gridworld initial_state_x initial_state_y))))
      (let ((trajectory (optimal_trajectory agent-id gridworld initial_state_x initial_state_y)))
      (let ((motions_at_locations (zip policy_motions trajectory)))
      motions_at_locations
))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Derived predicates.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define action_id_gensym (make_gensym "action-"))
(define is_going_to_actions (mem (lambda (agent-id)
        (let ((action_states (optimal_policy_with_trajectory agent-id gridworld initial_x initial_y)))
        (let ((final_location (last (last action_states))))
        (list (list
                  (pair 'action_id  (action_id_gensym))
                  (pair 'action_subject agent-id)
                  (pair 'action_predicates (list 'is_going (list 'to final_location)))
                  (pair 'action_preposition 'to)
                  (pair 'action_location final_location)
         )))))))

(define is_going_on_actions (mem (lambda (agent-id)
        (let ((action_states (optimal_policy_with_trajectory agent-id gridworld initial_x initial_y)))
        (fold (lambda (action_state these_actions)
        (let ((action_location (last action_state)))
        (let ((action_manner (first (first action_state))))
        (let ((action_direction (cdr (first action_state))))
        (cons
        (list
                  (pair 'action_id  (action_id_gensym))
                  (pair 'action_subject agent-id)
                  (pair 'action_predicates (list 'is_going action_manner action_direction (list 'on action_location)))
                  (pair 'action_preposition 'on)
                  (pair 'action_location action_location)
         )
        these_actions)
                ))))
        () action_states)
))))

(define actions_in_scene (mem (lambda (agent-id) (concatenate (is_going_to_actions agent-id) (is_going_on_actions agent-id)))))
(define is_action? (lambda (action action_predicate) (member? action_predicate (lookup action 'action_predicates))))
(define is_subject_of_action? (lambda (action entity) (eq?
    (lookup action 'action_subject)
    entity
  )))

(define is_preposition_of_action? (lambda (action preposition) (eq?
    (lookup action 'action_preposition)
    preposition
  )))
(define is_location_of_action? (lambda (action location) (eq?
    (lookup action 'action_location)
    location
  )))

(define get_location (lambda (action)
    (lookup action 'action_location)
  ))

(define (exists_action agent-id predicate)
    (some (map predicate (actions_in_scene agent-id))))

(define (get_actions agent-id predicate)
    (fold (lambda (action these_actions) (if (predicate action) (cons action these_actions) these_actions))
          () (actions_in_scene agent-id))
)