;; Consciousness Data Management Contract

(define-data-var consciousness-data-count uint u0)

(define-map consciousness-data
  uint
  {
    owner: principal,
    data-hash: (buff 32),
    timestamp: uint,
    status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_DATA (err u404))

(define-public (register-consciousness-data (data-hash (buff 32)))
  (let
    (
      (data-id (+ (var-get consciousness-data-count) u1))
    )
    (map-set consciousness-data
      data-id
      {
        owner: tx-sender,
        data-hash: data-hash,
        timestamp: block-height,
        status: "registered"
      }
    )
    (var-set consciousness-data-count data-id)
    (ok data-id)
  )
)

(define-public (update-consciousness-data-status (data-id uint) (new-status (string-ascii 20)))
  (let
    (
      (data (unwrap! (map-get? consciousness-data data-id) ERR_INVALID_DATA))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get owner data))) ERR_NOT_AUTHORIZED)
    (ok (map-set consciousness-data
      data-id
      (merge data { status: new-status })
    ))
  )
)

(define-read-only (get-consciousness-data (data-id uint))
  (map-get? consciousness-data data-id)
)

(define-read-only (get-consciousness-data-count)
  (var-get consciousness-data-count)
)

