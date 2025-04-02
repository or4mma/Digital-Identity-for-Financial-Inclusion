;; Identity Creation Contract
;; Establishes digital IDs for unbanked populations

(define-data-var next-id uint u0)

;; Data structure for a digital identity
(define-map identities
  { id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    created-at: uint,
    active: bool
  }
)

;; Create a new digital identity
(define-public (create-identity (name (string-utf8 100)))
  (let
    (
      (new-id (var-get next-id))
      (caller tx-sender)
    )
    ;; Increment the ID counter
    (var-set next-id (+ new-id u1))

    ;; Add the new identity to the map
    (map-set identities
      { id: new-id }
      {
        owner: caller,
        name: name,
        created-at: block-height,
        active: true
      }
    )

    ;; Return the new ID
    (ok new-id)
  )
)

;; Get identity details
(define-read-only (get-identity (id uint))
  (map-get? identities { id: id })
)

;; Check if an identity exists and is active
(define-read-only (is-identity-active (id uint))
  (match (map-get? identities { id: id })
    identity (get active identity)
    false
  )
)

;; Deactivate an identity (only the owner can do this)
(define-public (deactivate-identity (id uint))
  (let
    (
      (identity (unwrap! (map-get? identities { id: id }) (err u1)))
      (owner (get owner identity))
    )
    ;; Check that the caller is the owner
    (asserts! (is-eq tx-sender owner) (err u2))

    ;; Update the identity to be inactive
    (map-set identities
      { id: id }
      (merge identity { active: false })
    )

    (ok true)
  )
)

;; Reactivate an identity (only the owner can do this)
(define-public (reactivate-identity (id uint))
  (let
    (
      (identity (unwrap! (map-get? identities { id: id }) (err u1)))
      (owner (get owner identity))
    )
    ;; Check that the caller is the owner
    (asserts! (is-eq tx-sender owner) (err u2))

    ;; Update the identity to be active
    (map-set identities
      { id: id }
      (merge identity { active: true })
    )

    (ok true)
  )
)
