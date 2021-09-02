;; This is the key that is used to persist the start time in hs.settings
(local start-time-key :work-day-start)

;; Pulls the start time from storage if it's there, otherwise uses the current
;; time. This lets the timer continue to update relative to the start time
;; through reloads of the hammerspoon config, so I can edit my config and not
;; lose my start time for the day.
(fn get-initial-time []
  (let [start-time (hs.settings.get start-time-key)]
    (if (= start-time nil)
      (let [now (os.time)]
        (hs.settings.setDate start-time-key now)
        now)
      start-time)))

;; This is the reference point from which the time elapsed is calculated. It
;; gets loaded from hs.settings on startup and persisted when reset.
(global work-day-start (get-initial-time))

;; The menu in the menubar that displays the current elapsed time and houses the
;; dropdown that shows start and stop times along with the reset option.
(global timer-menu (hs.menubar.new))

;; Changes the menu title to the current time elapsed since the start time in
;; hours to two decimal places. This is because time is logged in Financial
;; Force by hours, so this gives a fairly accurate time logging for that.
(fn update-time-elapsed-display []
  (let [now (os.time)
        difference-seconds (os.difftime now work-day-start)
        difference-hours (/ difference-seconds (* 60 60))]
    (timer-menu:setTitle (string.format "%.2f" difference-hours))))

;; Sets the reference (start) time to now, persists it in hs.settings, and
;; refreshes the elapsed display.
(fn reset-start-time []
  (let [now (os.time)]
    (hs.settings.setDate start-time-key now)
    (global work-day-start now)
    (update-time-elapsed-display)))

;; TODO(cromo): This might house a bug where the start and end times don't
;; update on a reset. Haven't tested it yet, but it's something to keep an eye
;; out for. At least the title should always be correct.
(fn update-menu []
  (timer-menu:setMenu [{:title (os.date "%T" work-day-start)
                        :disabled true}
                       ;; This math is technically undefined, but macOS returns
                       ;; UNIX time from os.time, so I can just add 8 hours to
                       ;; it to get the end of my day.
                       {:title (os.date "%T" (+ work-day-start (* 60 60 8)))
                        :disabled true}
                       {:title "Reset"
                        :menu [{:title "Confirm"
                                :fn #(do (reset-start-time)
                                         (update-menu))}]}]))
(update-menu)
(update-time-elapsed-display)
(global work-day-updater (hs.timer.doEvery (* 0.6 60) update-time-elapsed-display))
