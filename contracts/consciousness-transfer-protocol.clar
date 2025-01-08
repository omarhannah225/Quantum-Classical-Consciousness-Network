;; Consciousness Transfer Protocol Contract

(define-map transfer-protocols
  uint
  {
    creator: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    version: (string-ascii 20),
    status: (string-ascii 20)
  }
)

(define-data-var protocol-count uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_PROTOCOL (err u404))

(define-public (register-transfer-protocol (name (string-ascii 100)) (description (string-utf8 1000)) (version (string-ascii 20)))
  (let
    (
      (protocol-id (+ (var-get protocol-count) u1))
    )
    (map-set transfer-protocols
      protocol-id
      {
        creator: tx-sender,
        name: name,
        description: description,
        version: version,
        status: "proposed"
      }
    )
    (var-set protocol-count protocol-id)
    (ok protocol-id)
  )
)

(define-public (update-protocol-status (protocol-id uint) (new-status (string-ascii 20)))
  (let
    (
      (protocol (unwrap! (map-get? transfer-protocols protocol-id) ERR_INVALID_PROTOCOL))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set transfer-protocols
      protocol-id
      (merge protocol { status: new-status })
    ))
  )
)

(define-read-only (get-transfer-protocol (protocol-id uint))
  (map-get? transfer-protocols protocol-id)
)

(define-read-only (get-protocol-count)
  (var-get protocol-count)
)

