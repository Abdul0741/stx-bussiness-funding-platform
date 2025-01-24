
;; business-funding-platform

(define-map charities
  {charity-id: uint}
  {name: (string-ascii 50), description: (string-ascii 200), wallet: principal, total-donations: uint, total-matched: uint, is-approved: bool})


(define-map donations
  {charity-id: uint, donor: principal}
  {amount: uint})


(define-data-var matching-fund uint 0)
(define-data-var next-charity-id uint 1)


;; Register a new charity
(define-public (register-charity (name (string-ascii 50)) (description (string-ascii 200)) (wallet principal))
  (let ((charity-id (var-get next-charity-id)))
    (begin
      ;; Register the charity
      (map-set charities
        {charity-id: charity-id}
        {name: name, description: description, wallet: wallet, total-donations: u0, total-matched: u0, is-approved: false})


      ;; Increment the next-charity-id
      (var-set next-charity-id (+ charity-id u1))


      (ok charity-id))))


;; Approve a charity (admin only)
(define-public (approve-charity (charity-id uint))
  (begin
    (asserts! (is-eq tx-sender 'SPADMINADDRESS) (err u100)) ;; Replace with the admin address
    (let ((charity (map-get? charities {charity-id: charity-id})))
      (match charity
        none (err u101) ;; Charity not found
        some charity-details
          (begin
            (map-set charities
              {charity-id: charity-id}
              {name: (get name charity-details),
               description: (get description charity-details),
               wallet: (get wallet charity-details),
               total-donations: (get total-donations charity-details),
               total-matched: (get total-matched charity-details),
               is-approved: true})


            (ok true))))))


;; Donate to a charity
(define-public (donate (charity-id uint) (amount uint))
  (let ((charity (map-get? charities {charity-id: charity-id})))
    (match charity
      none (err u101) ;; Charity not found
      some charity-details
        (let ((is-approved (get is-approved charity-details)))
          (begin
            ;; Ensure the charity is approved
            (asserts! is-approved (err u102))


            ;; Transfer the donation to the contract
            (stx-transfer? amount tx-sender (as-contract tx-sender))


            ;; Update the donations map
            (map-set donations
              {charity-id: charity-id, donor: tx-sender}
              {amount: (+ (default-to u0 (get amount (map-get? donations {charity-id: charity-id, donor: tx-sender}))) amount)})


            ;; Update the charity total donations and matched funds
            (let ((matched-amount (min amount (var-get matching-fund))))
              (map-set charities
                {charity-id: charity-id}
                {name: (get name charity-details),
                 description: (get description charity-details),
                 wallet: (get wallet charity-details),
                 total-donations: (+ (get total-donations charity-details) amount),
                 total-matched: (+ (get total-matched charity-details) matched-amount),
                 is-approved: is-approved})


              ;; Deduct from matching fund
              (var-set matching-fund (- (var-get matching-fund) matched-amount))


              (ok matched-amount)))))))


;; Add to the matching fund
(define-public (add-matching-fund (amount uint))
  (begin
    ;; Transfer the amount to the contract
    (stx-transfer? amount tx-sender (as-contract tx-sender))


    ;; Update the matching fund balance
    (var-set matching-fund (+ (var-get matching-fund) amount))


    (ok (var-get matching-fund))))


;; Claim funds for a charity
(define-public (claim-funds (charity-id uint))
  (let ((charity (map-get? charities {charity-id: charity-id})))
    (match charity
      none (err u101) ;; Charity not found
      some charity-details
        (let ((wallet (get wallet charity-details))
              (total-donations (get total-donations charity-details))
              (total-matched (get total-matched charity-details)))
          (begin
            ;; Ensure there are funds to claim
            (asserts! (> (+ total-donations total-matched) u0) (err u103))


            ;; Transfer funds to the charity's wallet
            (stx-transfer? (+ total-donations total-matched) (as-contract tx-sender) wallet)


            ;; Reset total donations and matched funds
            (map-set charities
              {charity-id: charity-id}
              {name: (get name charity-details),
               description: (get description charity-details),
               wallet: wallet,
               total-donations: u0,
               total-matched: u0,
               is-approved: (get is-approved charity-details)})


            (ok true))))))


;; View details of a charity
(define-read-only (get-charity (charity-id uint))
  (let ((charity (map-get? charities {charity-id: charity-id})))
    (match charity
      none (err u101) ;; Charity not found
      some charity-details (ok charity-details))))


;; View all donations by a donor
(define-read-only (get-donor-donations (donor principal))
  (map-filter
    (lambda (key value)
      (is-eq (get donor key) donor))
    donations))


