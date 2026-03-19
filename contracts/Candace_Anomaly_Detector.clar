;; ============================================================
;; Candace Anomaly Detector
;; ============================================================
;; Detects behavioral anomalies by comparing new activity
;; metrics against historical baselines.
;;
;; Features:
;; - Baseline tracking
;; - Deviation-based anomaly detection
;; - Configurable tolerance
;; - Flagging system
;; - Resolution mechanism
;; - Transparent read-only access
;; ============================================================

;; ========================
;; Error Codes
;; ========================

(define-constant err-unauthorized (err u100))
(define-constant err-user-not-found (err u101))
(define-constant err-invalid-metric (err u102))
(define-constant err-no-anomaly (err u103))
(define-constant err-already-flagged (err u104))

;; ========================
;; Contract Owner
;; ========================

(define-data-var contract-owner principal tx-sender)

;; ========================
;; Configurable Parameters
;; ========================

;; Allowed deviation percentage (default 30%)
(define-data-var deviation-threshold uint u30)

;; Minimum samples required before anomaly detection activates
(define-data-var minimum-samples uint u3)

;; ========================
;; Data Maps
;; ========================

;; Stores behavioral baseline and statistics
(define-map user-metrics
  { user: principal }
  {
    total-score: uint,
    sample-count: uint,
    baseline: uint,
    last-score: uint,
    flagged: bool
  }
)

;; ========================
;; Internal Utilities
;; ========================

(define-private (is-owner (caller principal))
  (is-eq caller (var-get contract-owner))
)

(define-private (calculate-baseline (total uint) (count uint))
  (if (> count u0)
      (/ total count)
      u0
  )
)

(define-private (absolute-difference (a uint) (b uint))
  (if (>= a b)
      (- a b)
      (- b a)
  )
)

(define-private (is-anomalous (new-score uint) (baseline uint))
  (let
    (
      (threshold (var-get deviation-threshold))
      (difference (absolute-difference new-score baseline))
      (allowed-deviation (/ (* baseline threshold) u100))
    )
    (> difference allowed-deviation)
  )
)

;; ========================
;; Admin Controls
;; ========================

(define-public (set-deviation-threshold (new-threshold uint))
  (begin
    (asserts! (is-owner tx-sender) err-unauthorized)
    (var-set deviation-threshold new-threshold)
    (ok true)
  )
)

(define-public (set-minimum-samples (new-minimum uint))
  (begin
    (asserts! (is-owner tx-sender) err-unauthorized)
    (var-set minimum-samples new-minimum)
    (ok true)
  )
)

;; ========================
;; Record Activity Metric
;; ========================

(define-public (record-metric (score uint))
  (let
    (
      (existing (map-get? user-metrics { user: tx-sender }))
    )

    (asserts! (> score u0) err-invalid-metric)

    (match existing
      ;; Existing user
      data
        (let
          (
            (new-total (+ (get total-score data) score))
            (new-count (+ (get sample-count data) u1))
          )
          (begin
            (map-set user-metrics
              { user: tx-sender }
              {
                total-score: new-total,
                sample-count: new-count,
                baseline: (calculate-baseline new-total new-count),
                last-score: score,
                flagged: false
              }
            )
            (ok true)
          )
        )

      ;; New user - no data found
      (begin
        (map-set user-metrics
          { user: tx-sender }
          {
            total-score: score,
            sample-count: u1,
            baseline: u0,
            last-score: score,
            flagged: false
          }
        )
        (ok true)
      )
    )
  )
)
