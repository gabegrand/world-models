;; Condition: The objects are all balls.
(condition (all (map (lambda (o) ((is_shape? 'sphere) o)) all_objects)))

;; Condition: Everything is a ball.
(condition (all (map (lambda (o) ((is_shape? 'sphere) o)) all_objects)))

;; Condition: Imagine the red thing is a block, and is somewhat heavy.
(condition (exists_object (lambda (object)
            (and
            ((is_color? red) object)
            ((is_shape? 'cube) object)
            (> (get_attribute object 'mass) 2)
            ))))

;; Condition: There is a blue ball, and it is quite heavy.
(condition (exists_object (lambda (object)
            (and
            ((is_color? blue) object)
            ((is_shape? 'sphere) object)
            (> (get_attribute object 'mass) 3.5)
            ))))

;; Condition: Now, the red block is very light.
(condition (exists_object (lambda (object)
            (and
            ((is_color? red) object)
            ((is_shape? 'cube) object)
            (< (get_attribute object 'mass) 1)
            ))))

;; Condition: A blue ball is somewhat light.
(condition (exists_object (lambda (object)
            (and
            ((is_color? red) object)
            ((is_shape? 'cube) object)
            (< (get_attribute object 'mass) 2)
            ))))

;; Condition: Imagine the red block gets pushed lightly to the right.
(condition (exists_object (lambda (object)
            (and
            ((is_color? red) object)
            ((is_shape? 'cube) object)
            (< (get_attribute object 'initial_push_force) 2)
            ))))

;; Condition: Now, imagine a red ball is pushed hard to the right.
(condition (exists_object (lambda (object)
            (and
            ((is_color? red) object)
            ((is_shape? 'sphere) object)
            (> (get_attribute object 'initial_push_force) 6)
            ))))

;; Condition: A red block hits a blue block.
(condition
(exists_object (lambda (object_1)
(exists_object (lambda (object_2)
(exists_event (lambda (event)
                    (and
                        ((is_color? red) object_1)
                        ((is_shape? 'cube) object_1)
                        ((is_color? blue) object_2)
                        ((is_shape? 'cube) object_2)
                        (is_subject_of_event? event object_1)
                        (is_object_of_event? event object_2)
                        (is_event? 'is_hitting event))
                        )))))))

;; Query: What's the final velocity of the red block after it is hit?
(query (last (map
(lambda (event) (get_attribute event 'subject_final_v))
(filter_events
(lambda (e)
(and
(is_event? 'is_colliding e)
(event_subject_is? e (lambda (o)
                    (and
                     ((is_color? red) o)
                     ((is_shape? 'cube) o))))))))))