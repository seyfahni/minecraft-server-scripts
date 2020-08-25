#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# defaults
LOG_LEVEL="${LOG_LEVEL:-1}"
LOG_DIRECTORY="${LOG_DIRECTORY:-../logs}"
TIMEZONE="${TIMEZONE:-"$(date +%:z)"}"

# helper methods
print_log() {
  printf '[%s] %s\n' "$1" "$2" >&2
}

log_debug() {
  if [[ "$LOG_LEVEL" -le 0 ]]; then
    print_log DEBUG "$1"
  fi
}

log_info() {
  if [[ "$LOG_LEVEL" -le 1 ]]; then
    print_log INFO "$1"
  fi
}

log_warning() {
  if [[ "$LOG_LEVEL" -le 2 ]]; then
    print_log WARNING "$1"
  fi
}

log_severe() {
  if [[ "$LOG_LEVEL" -le 3 ]]; then
    print_log SEVERE "$1"
  fi
}

log() {
  case "$1" in
  0 | DEBUG | debug)
    log_debug "$2"
    ;;
  1 | INFO | info)
    log_info "$2"
    ;;
  2 | WARNING | warning)
    log_warning "$2"
    ;;
  3 | SEVERE | severe)
    log_severe "$2"
    ;;
  *)
    log_severe "Unknown log level: $1 ; Suppressed message: $2"
    ;;
  esac
}

# argument parsing
log_directory="${1:-"$LOG_DIRECTORY"}"
log_directory="${log_directory%/}"

log debug "Reading logfiles from ${log_directory}/"

# internal methods
start_datafile() {
  datafile="${date}-${run}.csv"
  log info "Started new datafile: ${datafile}"
  echo 'date,player,action' >"$datafile"
}

# execution
lastdate=''

is_started='1'  # false
was_stopped='0' # true
while IFS= read -d $'\0' -r identifier; do
  basefile="${identifier}.log.gz"
  file="${log_directory}/${basefile}"
  date="${identifier%-*}"
  run="$(printf '%02d' "${identifier#*-*-*-}")"

  if [[ "$lastdate" != "$date" ]]; then
    if [[ -n "$lastdate" ]]; then
      log info ''
    fi
    lastdate="$date"
    log info "Working on log files from ${date}:"
  fi
  log info "Working on server run ${run}, analyzing log file: ${basefile}"

  set +e
  zgrep -qE '^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\] \[Server thread/INFO\]: Starting [M|m]inecraft server' "$file"
  is_started="$?"
  set -e
  log debug "Startup flag for ${basefile}: ${is_started}"

  if [[ "$was_stopped" -eq 0 ]]; then
    start_datafile
    if [[ "$is_started" -eq 0 ]]; then
      log debug "Server was previously stopped and now started in ${identifier}, creating new datafile."
    else
      log severe "Server startup missing in ${identifier}, negative statistics possible!"
    fi
  else
    if [[ "$is_started" -eq 0 ]]; then
      start_datafile
      log warning "Server shutdown missing in ${identifier}, did the server crash?"
    else
      log debug "Server was neither previously stopped nor now started in ${identifier}, keeping current datafile."
    fi
  fi

  set +e
  zgrep -qE '^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\] \[Server thread/INFO\]: Stopping (the )?server' "$file"
  was_stopped="$?"
  set -e
  log debug "Shutdown flag for ${basefile}: ${was_stopped}"

  log debug "Starting analysis, current data file: ${datafile}"
  { zgrep -E '^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\] \[Server thread/INFO\]: [a-zA-Z_]{1,16}(\[/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|([a-f0-9:]+:+)+[a-f0-9]+)(%0)?:[0-9]+\])? (logged in|lost connection)' "$file" || true; } | sed -E 's/^\[([0-9]{2}:[0-9]{2}:[0-9]{2})\] \[Server thread\/INFO\]: ([a-zA-Z_]{1,16})(\[\/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|([a-f0-9:]+:+)+[a-f0-9]+)(%0)?:[0-9]+\])? (logged in|lost connection).*$/'"$date"'T\1'"$TIMEZONE"',\2,\7/' >>"$datafile"
  log debug "Finished analysis for ${basefile}."
done < <(basename -zs '.log.gz' "$log_directory"/*.log.gz | sort -zV)
