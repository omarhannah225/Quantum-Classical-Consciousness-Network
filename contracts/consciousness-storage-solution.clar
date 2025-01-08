;; Consciousness Storage Solution Contract

(define-map storage-solutions
  uint
  {
    provider: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    capacity: uint,
    used-capacity: uint,
    status: (string-ascii 20)
  }
)

(define-data-var solution-count uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_SOLUTION (err u404))
(define-constant ERR_INSUFFICIENT_CAPACITY (err u405))

(define-public (register-storage-solution (name (string-ascii 100)) (description (string-utf8 1000)) (capacity uint))
  (let
    (
      (solution-id (+ (var-get solution-count) u1))
    )
    (map-set storage-solutions
      solution-id
      {
        provider: tx-sender,
        name: name,
        description: description,
        capacity: capacity,
        used-capacity: u0,
        status: "active"
      }
    )
    (var-set solution-count solution-id)
    (ok solution-id)
  )
)

(define-public (update-storage-usage (solution-id uint) (usage-change int))
  (let
    (
      (solution (unwrap! (map-get? storage-solutions solution-id) ERR_INVALID_SOLUTION))
    )
    (asserts! (is-eq tx-sender (get provider solution)) ERR_NOT_AUTHORIZED)
    (asserts! (>= (to-int (get capacity solution)) (+ (to-int (get used-capacity solution)) usage-change)) ERR_INSUFFICIENT_CAPACITY)
    (ok (map-set storage-solutions
      solution-id
      (merge solution { used-capacity: (+ (get used-capacity solution) usage-change) })
    ))
  )
)

(define-read-only (get-storage-solution (solution-id uint))
  (map-get? storage-solutions solution-id)
)

(define-read-only (get-solution-count)
  (var-get solution-count)
)

