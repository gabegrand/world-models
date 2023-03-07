;; Condition: There's a blue thing.
(condition (> (length ((filter-color blue) (objects-in-scene 'this-scene))) 0))

;; Condition: There's at least two blue plates.
(condition  (>=  (length
        ((filter-color blue)
        ((filter-shape 'plate)
        (objects-in-scene 'scene))))
2))

;; Condition: There's many blue plates.
(condition  (>=  (length
        ((filter-color blue)
        ((filter-shape 'plate)
        (objects-in-scene 'scene))))
5))

;; Condition: There's exactly two plates and there's also a yellow thing.
(condition
    (and (= (length ((filter-shape 'plate) (objects-in-scene 'scene))) 2)
    (> (length ((filter-color yellow) (objects-in-scene 'scene))) 0)))

;; Query: Is there a mug?
(query (> (length ((filter-shape 'mug) (objects-in-scene 'this-scene))) 0))