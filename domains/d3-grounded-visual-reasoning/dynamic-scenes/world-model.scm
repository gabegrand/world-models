;; -- Physical Events in Church --
;; Author: Lio Wong (zyzzyva@mit.edu)

(define (get_attribute obj key)
    (if (assoc key obj) (rest (assoc key obj)) ()))

  (define (member? a b)
    (if (member a b) true false))
  (define concatenate
    (lambda (list-1 list-2)
      (if (null? list-1)
          list-2
          (cons (car list-1) (concatenate (cdr list-1) list-2)))))

(define (pairs x l)
  (define (aux accu x l)
    (if (null? l)
        accu
        (let ((y (car l))
              (tail (cdr l)))
          (aux (cons (cons x y) accu) x tail))))
  (aux '() x l))

(define (cartesian_product l m)
  (define (aux accu l)
    (if (null? l)
        accu
        (let ((x (car l))
              (tail (cdr l)))
          (aux (append (pairs x m) accu) tail))))
  (aux '() l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Generative domain theory: dynamic scenes. Collision detection.
(define get_num_objects 2)
(define OBJECT_DEFAULT_RADIUS 1)
(define GRAVITY 9.8)
(define DELTA_T 0.5)

(define get_initial_color
     (lambda (obj_id)
     (if (eq? obj_id 'obj-0)
         (list 255 0 0)
         (list 0 0 255))))

(define choose_mass
     (mem (lambda (obj_id)
            (abs (gaussian 5 3)))))

(define choose_shapes
     (mem (lambda (scene-id) (uniform-draw (list 'sphere 'block)))))

(define min_x -3)
(define max_x 3)
(define mid_x (+ (/ (- max_x min_x) 2) min_x))
(define get_initial_x
     (lambda (obj_id)
     (if (eq? obj_id 'obj-0)
         min_x
         mid_x)))

(define min_force 0)
   (define max_force 10)
   (define mid_force (+ (/ (- max_force min_force) 2) min_force))
   (define choose_initial_force
     (mem (lambda (obj_id)
            (if (eq? obj_id 'obj-0)
            (abs (gaussian mid_force 3))
             0
                ))))

(define static_friction_constant (lambda (shape)
                                  (if (eq? shape 'sphere)
         0.02
         0.05)
                                    ))
(define kinetic_friction_constant (lambda (shape)
                                  (if (eq? shape 'sphere)
        0.01
        0.02)
                                    ))
(define normal_force (lambda (m) (* m GRAVITY)))
(define force_after_friction (lambda (f v shape m)
        (if (> (abs v) 0)
        (- f (* (kinetic_friction_constant shape) (normal_force m)))
        (if (< f (* (static_friction_constant shape) (normal_force m))) 0 (- f (* (kinetic_friction_constant shape) (normal_force m)))
         ))))

(define newtons_second (lambda (f m) (/ f m)))
(define v_next (lambda (v_prev a_prev delta_t)
                 (let ((v_temp (+ v_prev (* a_prev delta_t))))
                 (if (>= (* v_prev v_temp) 0) v_temp 0))
  ))
(define x_next (lambda (x_prev v_prev delta_t) (+ x_prev (* v_prev delta_t))))
(define initial_object_state (mem (lambda (obj_id scene_id)
                                       (let ((obj_shape (choose_shapes scene_id)))
                                       (let ((obj_mass (choose_mass obj_id)))
                                         (let ((obj_color (get_initial_color obj_id)))
                                           (let ((initial_x (get_initial_x obj_id)))
                                             (let ((initial_push_force (choose_initial_force obj_id)))
                                             (let ((initial_force (force_after_friction initial_push_force 0 obj_shape obj_mass)))
                                               (list
                                                (pair 'object_id obj_id)
                                                (pair 'object_radius OBJECT_DEFAULT_RADIUS)
                                                (pair 'shape obj_shape)
                                                (pair 'mass obj_mass)
                                                (pair 'color obj_color)
                                                (pair 'x initial_x)
                                                (pair 'initial_push_force initial_push_force)
                                                (pair 'f initial_force)
                                                (pair 't 0)
                                                (pair 'a_prev (newtons_second initial_force obj_mass))
                                                (pair 'a (newtons_second initial_force obj_mass))
                                                (pair 'v_0 0)
                                                (pair 'v (v_next 0 (newtons_second initial_force obj_mass) DELTA_T)))
                                               )))))))))
(define obj_id_gensym (make_gensym "obj-"))
(define generate_initial_state
     (mem (lambda (scene_id total_objects)
            (if (= total_objects 1)
                (list (initial_object_state (obj_id_gensym) scene_id))
                (cons (initial_object_state (obj_id_gensym) scene_id) (generate_initial_state scene_id (- total_objects 1)))))))

(define generate_initial_scene_event_state (mem (lambda (scene_id total_objects)
                                                             (pair 0
                                                                   (list
                                                                    (pair 'scene_states (generate_initial_state scene_id total_objects))
                                                                    (pair 'event_states [])
                                                                    ))
                                                             )
))

(define event_id_gensym (make_gensym "event-"))
(define circle_intersect? (lambda (subject_x subject_radius object_x object_radius)
(let ((square_circle_distance (expt (- subject_x object_x) 2)))
(let ((square_radii (expt (+ subject_radius object_radius) 2)))
(leq square_circle_distance square_radii)))
))
(define elastic_collision_subject_v (lambda (subject_m subject_v object_m object_v)
      (/ (+ (* 2 (* object_m object_v)) (* subject_v (- subject_m object_m))) (+ subject_m object_m))
))

(define get_collision_events (lambda (time scene_event_state_for_time)
  (let ((scene_event_state (get_attribute scene_event_state_for_time time)))
  (let ((scene_state (get_attribute scene_event_state 'scene_states)))
  (if (= (length scene_state) 1)
      ()
  (fold (lambda (event events) (if (equal? event ()) events (cons event events)))  ()
  (let ((paired_object_states (cartesian_product scene_state scene_state)))
  (map (lambda (paired_objects)

  (let ((event_subject (get_attribute (first paired_objects) 'object_id)))
  (let ((event_object (get_attribute (cdr paired_objects) 'object_id)))
  (if (eq? event_subject event_object) ()
  (let ((subject_v (get_attribute (first paired_objects) 'v)))
  (let ((subject_x (get_attribute (first paired_objects) 'x)))
  (let ((subject_m (get_attribute (first paired_objects) 'mass)))
  (let ((subject_radius (get_attribute (first paired_objects) 'object_radius)))
  (let ((object_v (get_attribute (cdr paired_objects) 'v)))
  (let ((object_x (get_attribute (cdr paired_objects) 'x)))
  (let ((object_m (get_attribute (cdr paired_objects) 'mass)))
  (let ((object_radius (get_attribute (cdr paired_objects) 'object_radius)))
  (if (circle_intersect? subject_x subject_radius object_x object_radius)
      (list
                  (pair 'event-id  (event_id_gensym))
                  (pair 'event_time  time)
                  (pair 'event_predicates (list 'is_colliding))
                  (pair 'event_subject event_subject)
                  (pair 'event_object event_object)
                  (pair 'subject_initial_v subject_v)
                  (pair 'subject_final_v (elastic_collision_subject_v subject_m subject_v object_m object_v))
                  (pair 'object_initial_v object_v)
                  )
   ()))))))))))
  )))
  paired_object_states)))
)))))


(define generate_next_object_state (lambda (current_time event_state) (lambda (prev_object_state)
  (let ((obj_id (cdr (assoc 'object_id prev_object_state))))
  (let ((collision_events (fold (lambda (event events) (if (equal? (get_attribute event 'event_subject) obj_id) (cons event events) events)) () event_state)))
  (if (> (length collision_events) 0)
  (generate_collision_event_state current_time obj_id prev_object_state (car collision_events))
  (generate_no_collision_event_state current_time obj_id prev_object_state)
  )
  )))))

(define generate_collision_event_state (lambda (current_time obj_id prev_object_state collision_event)
  (let ((obj_radius (cdr (assoc 'object_radius prev_object_state))))
      (let ((obj_mass (cdr (assoc 'mass prev_object_state))))
        (let ((obj_color (cdr (assoc 'color prev_object_state))))
        (let ((obj_shape (cdr (assoc 'shape prev_object_state))))
          (let ((v_prev (cdr (assoc 'v prev_object_state))))
            (let ((a_prev (cdr (assoc 'a_prev prev_object_state))))
              (let ((x_prev (cdr (assoc 'x prev_object_state))))
                (let ((v (get_attribute collision_event 'subject_final_v)))
                  (let ((x (x_next x_prev v 1)))
                    (list
                    (pair 'object_id obj_id)
                    (pair 'object_radius obj_radius)
                    (pair 'shape obj_shape)
                    (pair 'color obj_color)
                    (pair 'mass obj_mass)
                    (pair 'x x)
                    (pair 'f 0)
                    (pair 't (* current_time DELTA_T))
                    (pair 'a_prev 0)
                    (pair 'a 0)
                    (pair 'v_0 0)
                    (pair 'v v))
                    )))))
          ))))
))

(define generate_no_collision_event_state (lambda (current_time obj_id prev_object_state)
  (let ((obj_radius (cdr (assoc 'object_radius prev_object_state))))
      (let ((obj_mass (cdr (assoc 'mass prev_object_state))))
        (let ((obj_color (cdr (assoc 'color prev_object_state))))
        (let ((obj_shape (cdr (assoc 'shape prev_object_state))))
          (let ((v_prev (cdr (assoc 'v prev_object_state))))
            (let ((a_prev_no_friction (cdr (assoc 'a_prev prev_object_state))))
            (let ((a_prev (newtons_second (force_after_friction 0 v_prev obj_shape obj_mass) obj_mass)))
              (let ((x_prev (cdr (assoc 'x prev_object_state))))
                (let ((v (v_next v_prev a_prev DELTA_T)))
                  (let ((x (x_next x_prev v_prev DELTA_T)))
                    (list
                    (pair 'object_id obj_id)
                    (pair 'object_radius obj_radius)
                    (pair 'shape obj_shape)
                    (pair 'color obj_color)
                    (pair 'mass obj_mass)
                    (pair 'x x)
                    (pair 'f (force_after_friction 0 v_prev obj_shape obj_mass))
                    (pair 't (* current_time DELTA_T))
                    (pair 'a_prev a_prev)
                    (pair 'a 0)
                    (pair 'v_0 0)
                    (pair 'v v))
                    )))))
          ))))
)))

(define generate_next_scene_state (lambda (prev_scene_state event_state next_time)
        (map (generate_next_object_state next_time event_state) prev_scene_state)))

(define generate_next_scene_event_state_time (lambda (next_time scene_event_state_for_times)
        (let ((prev_scene_event_state (get_attribute scene_event_state_for_times (- next_time 1))))
        (let ((prev_scene_state (get_attribute prev_scene_event_state 'scene_states)))
        (let ((event_state (get_collision_events (- next_time 1) scene_event_state_for_times)))

        (pair next_time (list
           (pair 'scene_states (generate_next_scene_state prev_scene_state event_state next_time))
           (pair 'event_states event_state)
        ))
)))))

(define generate_next_scene_event_states
     (lambda (current_time prev_scene_event_states_for_times)
     (cons (generate_next_scene_event_state_time current_time prev_scene_event_states_for_times) prev_scene_event_states_for_times)
))

(define generate_scene_event_states_for_times (mem (lambda (scene_id total_objects total_time)
                                                        (if (= total_time 0)
                                                            (list
                                                             (generate_initial_scene_event_state scene_id total_objects)
                                                             )
                                                            (let ((prev_scene_event_states (generate_scene_event_states_for_times scene_id total_objects (- total_time 1))))
                                                              (generate_next_scene_event_states total_time prev_scene_event_states)
)))))

(define max_time 9)

(define base_states_for_times  (generate_scene_event_states_for_times 'this_scene get_num_objects max_time))

;;;;;;;;;;;;;;;;;;;;;;;;;;Derived predicates.
(define objects_in_scene (lambda (base_states_for_times)
        (let ((initial_base_states_at_time (cdr (assoc 0 (cdr base_states_for_times)))))
        (let ((base_state (cdr (assoc 'scene_states initial_base_states_at_time))))
        base_state
      ))
  ))
(define red (list 255 0 0))
(define blue (list 0 0 255))
(define is_color?  (lambda (color) (lambda (object) (equal? (cdr (assoc 'color object)) color))))
(define is_shape?  (lambda (shape) (lambda (object) (equal? (cdr (assoc 'shape object)) shape))))

(define all_objects  (objects_in_scene base_states_for_times))
(define (exists_object predicate)
  (some (map predicate (objects_in_scene base_states_for_times))))

(define (filter_objects predicate)
  (map
  (lambda (o) (get_attribute o 'object_id))
  (filter predicate (objects_in_scene base_states_for_times))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QUICKLY_THRESHOLD 2)
(define SLOWLY_THRESHOLD 2)

  (define is_moving_events (mem (lambda (base_states_for_times)
          (fold (lambda (base_state_for_time these_events)
          (let ((current_time (car base_state_for_time)))
          (let ((base_state (cdr (assoc 'scene_states (cdr base_state_for_time)))))
          (fold (lambda (obj_state these_events)
            (let ((obj_id (cdr (assoc 'object_id obj_state))))
            (let ((obj_velocity (cdr (assoc 'v obj_state))))
            (let ((obj_speed (abs obj_velocity)))
            (if (> obj_speed 0)
              ;;
                (let ((event_predicates
                      (if (> obj_speed QUICKLY_THRESHOLD)
                          (list 'is_moving 'is_quickly)
                          (if (< obj_speed SLOWLY_THRESHOLD)
                              (list 'is_moving 'is_slowly)
                              (list 'is_moving)
                              ))
                       ))
                (cons
                  (list
                  (pair 'event-id  (event_id_gensym))
                  (pair 'event_time  current_time)
                  (pair 'event_predicates event_predicates)
                  (pair 'event_subject obj_id)
                   (pair 'event_speed obj_speed)
                  )
                these_events))
                these_events

                )))))
                these_events base_state))))
() base_states_for_times))))

(define is_resting_events (mem (lambda (base_states_for_times)
          (fold (lambda (base_state_for_time these_events)
          (let ((current_time (car base_state_for_time)))
          (let ((base_state (cdr (assoc 'scene_states (cdr base_state_for_time)))))
          (fold (lambda (obj_state these_events)
            (let ((obj_id (cdr (assoc 'object_id obj_state))))
            (let ((obj_velocity (cdr (assoc 'v obj_state))))
            (let ((obj_speed (abs obj_velocity)))
            (if (= obj_speed 0)
              ;;
                (let ((event_predicates
                      (list 'is_resting)))
                (cons
                  (list
                  (pair 'event-id  (event_id_gensym))
                  (pair 'event_time  current_time)
                  (pair 'event_predicates event_predicates)
                  (pair 'event_subject obj_id)
                   (pair 'event_speed obj_speed)
                  )
                these_events))
                these_events

                )))))
                these_events base_state))))
          () base_states_for_times))))

(define is_colliding_events (mem (lambda (base_states_for_times)
        (fold (lambda (base_state_for_time these_events)
        (let ((current_time (car base_state_for_time)))
        (let ((event_states (cdr (assoc 'event_states (cdr base_state_for_time)))))
        (fold (lambda (event_state these_events)
                (let ((subject_initial_speed (abs (get_attribute event_state 'subject_initial_v))))
                (let ((subject_final_speed (abs (get_attribute event_state 'subject_final_v))))
                (let ((object_initial_speed (abs (get_attribute event_state 'object_initial_v))))
                (let ((cause_subject_object_event (and (> subject_initial_speed 0) (= object_initial_speed 0))))
                (let
                ((event_predicates
                      (if (and cause_subject_object_event (eq? subject_final_speed 0))
                          (list 'is_launching 'is_hitting 'is_colliding)
                          (if (> subject_initial_speed 0)
                              (list 'is_hitting 'is_colliding)
                              (list 'is_colliding)
                              )
                       )))

                (cons (list
                  (pair 'event-id  (get_attribute event_state 'event-id))
                  (pair 'event_time (get_attribute event_state 'event_time))
                  (pair 'event_predicates event_predicates)
                  (pair 'event_subject (get_attribute event_state 'event_subject))
                  (pair 'event_object (get_attribute event_state 'event_object))
                  (pair 'subject_initial_v (get_attribute event_state 'subject_initial_v ))
                  (pair 'subject_final_v (get_attribute event_state 'subject_final_v ))
                  (pair 'object_initial_v (get_attribute event_state 'object_initial_v ))
                  ) these_events))))))
                ) these_events event_states)
         )))
        () base_states_for_times)

)))



(define events_in_scene (concatenate
                                  (is_colliding_events base_states_for_times)
                                  (concatenate
                                  (is_moving_events base_states_for_times)
                                  (is_resting_events base_states_for_times))))


(define is_event? (lambda (event_predicate event) (member? event_predicate (get_attribute event 'event_predicates))))

(define is_subject_of_event? (lambda (event object ) (equal?
    (get_attribute event 'event_subject)
    (get_attribute object 'object_id)
  )))

(define is_object_of_event? (lambda (event object ) (equal?
    (get_attribute event 'event_object)
    (get_attribute object 'object_id)
  )))

(define event_subject_is? (lambda (event predicate) (member?
    (get_attribute event 'event_subject)
    (filter_objects predicate)
  )))
(define event_object_is? (lambda (event predicate) (member?
    (get_attribute event 'event_object)
    (filter_objects predicate)
  )))

(define (exists_event predicate)
    (some (map predicate events_in_scene)))

(define (filter_events predicate)
    (filter predicate events_in_scene))