;; Consciousness Pattern NFT Contract

(define-non-fungible-token consciousness-pattern uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  uint
  {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    creator: principal,
    pattern-hash: (buff 32),
    achievement-type: (string-ascii 50),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))

(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (pattern-hash (buff 32)) (achievement-type (string-ascii 50)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? consciousness-pattern token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        name: name,
        description: description,
        creator: tx-sender,
        pattern-hash: pattern-hash,
        achievement-type: achievement-type,
        timestamp: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (recipient principal))
  (nft-transfer? consciousness-pattern token-id tx-sender recipient)
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

