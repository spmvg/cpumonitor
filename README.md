* Monitor CPU usage.
* Send message to Slack if CPU usage is above threshold.
    * A webhook URL (like `https://hooks.slack.com/services/...`) is necessary. The webhook URL should be treated confidentially.
* Log the output of `top` to `/var/log/cpumonitor`, sorted by CPU usage.
* Discard logs after a month.

#### Test
Set the warning threshold to `0.0` and check that messages are received in Slack.

#### Requirements
* `curl`
