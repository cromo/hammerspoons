(require "work-timer")

(local {:hotkey {: bind} :alert {:show alert}} hs)

(global config-watcher
        (: (hs.pathwatcher.new (.. (os.getenv :HOME) "/.hammerspoon/")
                               (fn reload-config [files]
                                 (alert "path watcher called")
                                 (var should-reload false)
                                 (each [_ file (pairs files)]
                                       (let [extension (file:sub -4)]
                                         (when (or (= extension ".lua")
                                                   (= extension ".fnl"))
                                           (set should-reload true))))
                                 (when should-reload (hs.reload))))
           :start))

(alert "Hammerspoon config reloaded" 0.6)