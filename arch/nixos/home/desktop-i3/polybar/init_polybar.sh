killall -q polybar
killall -q .polybar-wrappe
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar -q top &
polybar -q bottom &
