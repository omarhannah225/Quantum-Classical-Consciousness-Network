;; Governance System Contract

(define-fungible-token governance-token)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_PROPOSAL (err u404))
(define-constant VOTING_PERIOD u1440) ;; 10 days in blocks (assuming 10-minute block time)

(define-map governance-proposals
  uint
  {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    status: (string-ascii 20)
  }
)

(define-map governance-votes
  { proposal-id: uint, voter: principal }
  { amount: uint, vote: (string-ascii 10) }
)

(define-data-var governance-proposal-count uint u0)

(define-public (create-governance-proposal (title (string-ascii 100)) (description (string-utf8 1000)))
  (let
    (
      (proposal-id (+ (var-get governance-proposal-count) u1))
    )
    (map-set governance-proposals
      proposal-id
      {
        proposer: tx-sender,
        title: title,
        description: description,
        start-block: block-height,
        end-block: (+ block-height VOTING_PERIOD),
        yes-votes: u0,
        no-votes: u0,
        status: "active"
      }
    )
    (var-set governance-proposal-count proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote-on-governance (proposal-id uint) (amount uint) (vote-type (string-ascii 10)))
  (let
    (
      (proposal (unwrap! (map-get? governance-proposals proposal-id) ERR_INVALID_PROPOSAL))
    )
    (asserts! (< block-height (get end-block proposal)) ERR_INVALID_PROPOSAL)
    (asserts! (is-eq (get status proposal) "active") ERR_INVALID_PROPOSAL)
    (asserts! (or (is-eq vote-type "yes") (is-eq vote-type "no")) ERR_INVALID_PROPOSAL)
    (try! (ft-transfer? governance-token amount tx-sender (as-contract tx-sender)))
    (map-set governance-votes
      { proposal-id: proposal-id, voter: tx-sender }
      { amount: amount, vote: vote-type }
    )
    (map-set governance-proposals
      proposal-id
      (merge proposal
        {
          yes-votes: (if (is-eq vote-type "yes")
                        (+ (get yes-votes proposal) amount)
                        (get yes-votes proposal)),
          no-votes: (if (is-eq vote-type "no")
                       (+ (get no-votes proposal) amount)
                       (get no-votes proposal))
        }
      )
    )
    (ok true)
  )
)

(define-public (end-governance-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? governance-proposals proposal-id) ERR_INVALID_PROPOSAL))
    )
    (asserts! (>= block-height (get end-block proposal)) ERR_INVALID_PROPOSAL)
    (asserts! (is-eq (get status proposal) "active") ERR_INVALID_PROPOSAL)
    (ok (map-set governance-proposals
      proposal-id
      (merge proposal {
        status: (if (> (get yes-votes proposal) (get no-votes proposal))
                  "passed"
                  "rejected")
      })
    ))
  )
)

(define-read-only (get-governance-proposal (proposal-id uint))
  (map-get? governance-proposals proposal-id)
)

(define-read-only (get-governance-vote (proposal-id uint) (voter principal))
  (map-get? governance-votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-governance-proposal-count)
  (var-get governance-proposal-count)
)

