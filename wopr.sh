#!/bin/bash
# The original NORAD WOPR operating system for dialup/telnet/ssh access
# does not require any post v4.5 bash (no associative arrays)
# (c) by hot dog studios and moshix
# v0.01 humble beginnings
# v0.02 colors and slow typing
# v0.03 tic tac toe 
# v0.04 nasa control
# v0.05 sub command center
# v0.06 global thermonuclear war
# v0.07 strategic defense network
# v0.08 war operation plan response
# v0.09 Improve tic tac algorithm 
# v0.10 time out for login (to not keep docker container )
# v0.11 Tic tac toe non-scrolling   
# v0.12 better user input parsing
# v0.13 fix NASA game 
# v0.14 submarine command center fixed map

# ANSI color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\033[5m'

# Sound effects using beep (requires 'beep' package)
function play_beep() {
    if command -v beep > /dev/null; then
        beep -f 750 -l 100
    else
        echo -en "\007"
    fi
}

function play_alert() {
    if command -v beep > /dev/null; then
        beep -f 1000 -l 500 -r 3
    else
        echo -en "\007"
        sleep 0.5
        echo -en "\007"
        sleep 0.5
        echo -en "\007"
    fi
}

# Show startup ASCII art
function show_startup_art() {
    clear
    cat << "EOF"
    ██     ██  ██████  ██████  ██████  
    ██     ██ ██    ██ ██   ██ ██   ██ 
    ██  █  ██ ██    ██ ██████  ██████  
    ██ ███ ██ ██    ██ ██      ██   ██ 
     ███ ███   ██████  ██      ██   ██ 
    
    WAR OPERATION PLAN RESPONSE SYSTEM
    NORAD STRATEGIC DEFENSE NETWORK
    ================================
EOF
}

function type_text() {
    text=$1
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.05
        play_beep
    done
    echo
}

function login_sequence() {
    echo -e "${GREEN}"
    cat << "EOF"
    =========================================
    = NORAD INTEGRATED TACTICAL NETWORK     =
    = SECURE ACCESS TERMINAL               =
    =========================================
    
    SYSTEM: WOPR/NORAD-CONN-359
    SECURITY LEVEL: TS/SCI
    ENCRYPTION: AES-256
    
    *** AUTHORIZED ACCESS ONLY ***
EOF
    
    # Start timer in background
    (
        sleep 30
        # Kill parent process if it still exists
        kill -TERM $$ 2>/dev/null
    ) & 
    timer_pid=$!
    
    type_text "LOGON:"
    read -t 30 -p "" username
    if [ $? -ne 0 ]; then
        echo
        type_text "LOGIN TIMEOUT - TERMINATING CONNECTION"
        kill $timer_pid 2>/dev/null
        exit 1
    fi
    
    type_text "PASSWORD:"
    read -s -t 30 -p "" password
    if [ $? -ne 0 ]; then
        echo
        type_text "LOGIN TIMEOUT - TERMINATING CONNECTION"
        kill $timer_pid 2>/dev/null
        exit 1
    fi
    echo
    
    # Cancel the timer since login was successful
    kill $timer_pid >/dev/null 2>&1
    wait $timer_pid 2>/dev/null  # Wait for the process to finish
    
    # Show "processing" animation
    echo -n "AUTHENTICATING"
    for i in {1..2}; do
        sleep 0.1
        echo -n "."
        #play_beep
    done
    echo
    sleep 1
    
    type_text "GREETINGS PROFESSOR FALKEN."
    sleep 1
}

function show_games() {
    echo
    type_text "SHALL WE PLAY A GAME?"
    echo
    echo "Available systems:"
    echo "----------------"
    echo "1. GLOBAL THERMONUCLEAR WAR"
    echo "2. SUB COMMAND CENTER ATLANTIC"
    echo "3. NASA CONTROL CENTER HOUSTON"
    echo "4. TIC TAC TOE STRATEGIC SIMULATOR"
    echo "B. BACK TO LOGIN"
    echo "Q. QUIT WOPR SYSTEM"
    echo
}

function select_targets() {
    local targets=("New York" "Moscow" "London" "Paris" "Tokyo" "Beijing" "Los Angeles" "Berlin" "Delhi" "Sydney")
    local selected=()
    
    clear
    echo "STRATEGIC TARGET SELECTION"
    echo "-------------------------"
    echo "Available targets:"
    echo
    
    for i in "${!targets[@]}"; do
        echo "$((i+1)). ${targets[$i]}"
    done
    
    echo
    type_text "SELECT UP TO 3 PRIMARY TARGETS (ENTER NUMBERS SEPARATED BY SPACES OR COMMAS):"
    read -r choices
    
    # Replace commas with spaces
    choices=${choices//,/ }
    
    for choice in $choices; do
        if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#targets[@]}" ]; then
            selected+=("${targets[$((choice-1))]}")
        fi
    done
    
    echo
    if [ ${#selected[@]} -eq 0 ]; then
        type_text "NO VALID TARGETS SELECTED. ABORTING LAUNCH."
        sleep 2
        return 1
    fi
    
    type_text "SELECTED TARGETS:"
    for target in "${selected[@]}"; do
        echo "* $target"
        play_beep
        sleep 0.5
    done
    
    return 0
}

function select_missile_type() {
    local target=$1
    echo
    type_text "SELECT MISSILE TYPE FOR $target:"
    echo "1. ICBM (Intercontinental Ballistic Missile)"
    echo "   Range: 5500+ km, High Accuracy, Heavy Payload"
    echo "2. SLBM (Submarine-Launched Ballistic Missile)"
    echo "   Range: 4000+ km, Stealth Launch, Medium Payload"
    echo "3. MRBM (Medium-Range Ballistic Missile)"
    echo "   Range: 1000-3000 km, Quick Launch, Light Payload"
    echo
    read -p "ENTER SELECTION (1-3): " missile_type
    
    case $missile_type in
        1) echo "ICBM";;
        2) echo "SLBM";;
        3) echo "MRBM";;
        *) echo "ICBM";;  # Default to ICBM if invalid selection
    esac
}

function calculate_defense_probability() {
    local target=$1
    local missile_type=$2
    
    # Base probability of defense systems intercepting the missile
    local base_probability
    case $missile_type in
        "ICBM") base_probability=30;;
        "SLBM") base_probability=20;;
        "MRBM") base_probability=40;;
    esac
    
    # Adjust based on target's defense capabilities
    case $target in
        "Moscow") base_probability=$((base_probability + 20));;  # Advanced defense systems
        "Washington D.C.") base_probability=$((base_probability + 15));;
        "Beijing") base_probability=$((base_probability + 10));;
        *) base_probability=$((base_probability + 0));;
    esac
    
    echo $base_probability
}

function show_missile_art() {
    local stage=$1
    case $stage in
        "launch")
            type_text "MISSILE LAUNCH SEQUENCE INITIATED"
            type_text "COORDINATES LOCKED"
            type_text "LAUNCH AUTHORIZATION CODE VERIFIED"
            ;;
        "trajectory")
            type_text "TRACKING MISSILE TRAJECTORY"
            type_text "VELOCITY: MACH 23"
            type_text "ALTITUDE: 1200 KM"
            ;;
        "explosion")
            type_text "DETONATION CONFIRMED"
            type_text "YIELD: 25 MEGATONS"
            type_text "GROUND ZERO TEMPERATURE: 100M °C"
            ;;
        "radiation")
            type_text "RADIATION DISPERSAL PATTERN"
            type_text "FALLOUT DIRECTION: NE"
            type_text "CONTAMINATION RADIUS: 250 KM"
            ;;
        "winter")
            type_text "GLOBAL CLIMATE IMPACT"
            type_text "TEMPERATURE DROP: -15°C"
            type_text "AGRICULTURAL VIABILITY: 12%"
            ;;
    esac
}

function show_world_map() {
    local source=$1
    local target=$2
    
    # Conventional ASCII world map
    cat << "MAP"
    ┌──────────────── GLOBAL TRACKING SYSTEM ────────────────┐
    │                      __   ___                          │
    │         __     ____/  \_/   \              _          │
    │    ____/  \___/                \    ___---´ \         │
    │   /                             \__/          \_       │
    │  /        NORTH                  \      ASIA   \      │
    │ (       AMERICA      ATLANTIC     \             )     │
    │  \                    OCEAN     _/-\_           \     │
    │   \                           _/EUROPE\_         \    │
    │    \_                    ___--´         \_       \    │
    │      \              ___--      AFRICA    \       )    │
    │       \    PACIFIC /            ___       \_    /     │
    │        \   OCEAN  |        ___--   \        \__/     │
    │      ___\         |    __--         \               │
    │  ___/    \_      |___/     INDIAN    \             │
    │ /   SOUTH  \      /         OCEAN      \           │
    │(   AMERICA  )    /                      \          │
    │ \___________/    \_______________________\         │
    └────────────────────────────────────────────────────┘
MAP

    # City coordinates (x,y from top-left)
    local city_names=("New York" "Moscow" "London" "Paris" "Tokyo" "Beijing" "Los Angeles" "Berlin" "Delhi" "Sydney")
    local city_coords=("24,6" "45,5" "37,8" "38,8" "54,6" "50,6" "18,6" "39,8" "47,10" "56,15")
    
    # Find coordinates for source and target
    local source_coords=""
    local target_coords=""
    
    for i in "${!city_names[@]}"; do
        if [ "${city_names[$i]}" = "$source" ]; then
            source_coords="${city_coords[$i]}"
        fi
        if [ "${city_names[$i]}" = "$target" ]; then
            target_coords="${city_coords[$i]}"
        fi
    done
    
    if [[ -n $source_coords && -n $target_coords ]]; then
        local sx=${source_coords%,*}
        local sy=${source_coords#*,}
        local tx=${target_coords%,*}
        local ty=${target_coords#*,}
        
        # Draw launch point
        tput cup $((sy+2)) $sx
        echo -ne "\033[32m●\033[0m"  # Green launch marker
        
        # Missile trajectory animation
        local steps=12
        for ((i=1; i<=steps; i++)); do
            local px=$(( sx + (tx - sx) * i / steps ))
            local py=$(( sy + (ty - sy) * i / steps ))
            tput cup $((py+2)) $px
            
            case $((i % 4)) in
                0) echo -ne "\033[31m·\033[0m";;
                1) echo -ne "\033[31m·\033[0m";;
                2) echo -ne "\033[31m·\033[0m";;
                3) echo -ne "\033[31m·\033[0m";;
            esac
            
            play_beep
            sleep 0.1
        done
        
        # Impact marker
        tput cup $((ty+2)) $tx
        echo -ne "\033[1;31m×\033[0m"  # Red impact marker
        
        # Show targeting data
        tput cup 18 0
        echo -e "\033[1mTARGET DATA:\033[0m"
        echo "DISTANCE: $((RANDOM % 5000 + 3000))km | ETA: $((RANDOM % 20 + 10))min"
        echo "TRAJECTORY: BALLISTIC | ALTITUDE: 1200km | VELOCITY: MACH 23"
    fi
}

function simulate_strike() {
    local target=$1
    local missile_type=$2
    local defense_prob=$(calculate_defense_probability "$target" "$missile_type")
    local random_num=$((RANDOM % 100 + 1))
    
    clear
    show_missile_art "launch"
    type_text "LAUNCHING $missile_type TOWARD $target"
    sleep 1
    
    # Clear screen and show map with trajectory
    clear
    local launch_city="Washington D.C."  # Default launch point
    show_world_map "$launch_city" "$target"
    
    # Move cursor below map for status messages
    tput cup 22 0
    if [ $random_num -le $defense_prob ]; then
        type_text "ALERT: MISSILE INTERCEPTED BY DEFENSE SYSTEMS"
        sleep 2
        return 1
    else
        type_text "DIRECT HIT CONFIRMED"
        play_alert
        sleep 2
        return 0
    fi
}

function show_detailed_casualties() {
    local target=$1
    local missile_type=$2
    local population=$((RANDOM % 10000000 + 5000000))
    local base_destruction=$((RANDOM % 40 + 40))  # 40-80% base destruction rate
    
    # Adjust destruction based on missile type
    case $missile_type in
        "ICBM") base_destruction=$((base_destruction + 20));;
        "SLBM") base_destruction=$((base_destruction + 10));;
        "MRBM") base_destruction=$((base_destruction + 0));;
    esac
    
    # Ensure destruction doesn't exceed 100%
    if [ $base_destruction -gt 100 ]; then
        base_destruction=100
    fi
    
    local casualties=$((population * base_destruction / 100))
    local infrastructure_damage=$((RANDOM % 20 + base_destruction))
    local fallout_radius=$((RANDOM % 1000 + 500))
    
    clear
    show_missile_art "radiation"
    type_text "DETAILED IMPACT ASSESSMENT FOR $target:"
    echo "----------------------------------------"
    echo "Population: $population"
    echo "Direct Casualties: $casualties"
    echo "Infrastructure Damage: ${infrastructure_damage}%"
    echo "Fallout Radius: ${fallout_radius} km"
    echo "Secondary Effects:"
    echo "- Electromagnetic Pulse Damage: ${base_destruction}%"
    echo "- Communication Systems: ${infrastructure_damage}% disrupted"
    echo "- Power Grid: $((infrastructure_damage - 10))% offline"
    play_alert
}

function show_environmental_impact() {
    local total_strikes=$1
    clear
    show_missile_art "winter"
    type_text "GLOBAL ENVIRONMENTAL IMPACT ASSESSMENT:"
    echo "----------------------------------------"
    echo "Temperature Change: -$((total_strikes * 2 + RANDOM % 3))°C Global Average"
    echo "Nuclear Winter Duration: $((total_strikes * 3 + RANDOM % 5)) years"
    echo "Radiation Spread: $((total_strikes * 1000 + RANDOM % 5000)) km²"
    echo "Agricultural Impact: $((total_strikes * 10 + 40))% crop failure"
    echo "Atmospheric Effects: Severe stratospheric ozone depletion"
}

function calculate_strategic_value() {
    local target=$1
    local base_value
    
    # Base strategic values for different target types
    case $target in
        "Washington D.C.") base_value=95;;  # Capital
        "New York") base_value=90;;         # Financial/population
        "Los Angeles") base_value=85;;      # Population/industry
        "Chicago") base_value=80;;          # Industry/transport
        "Houston") base_value=75;;          # Energy/industry
        "Seattle") base_value=70;;          # Tech/aerospace
        "Miami") base_value=65;;            # Population/ports
        "Denver") base_value=60;;           # Military/transport
        "Boston") base_value=70;;           # Tech/education
        "San Francisco") base_value=80;;    # Tech/finance
        *) base_value=50;;
    esac
    
    # Add random variation to make AI less predictable
    local variation=$((RANDOM % 20 - 10))  # -10 to +10
    local final_value=$((base_value + variation))
    
    # Ensure value stays within bounds
    [ $final_value -gt 100 ] && final_value=100
    [ $final_value -lt 0 ] && final_value=0
    
    echo $final_value
}

function ai_select_targets() {
    local available_targets=("Washington D.C." "New York" "Los Angeles" "Chicago" "Houston" "Seattle" "Miami" "Denver" "Boston" "San Francisco")
    local selected_targets=()
    local priorities=()
    
    # AI strategy selection (random)
    local strategy=$((RANDOM % 3))  # 0=balanced, 1=population, 2=infrastructure
    
    # Calculate strategic value for each target with strategy modifier
    for target in "${available_targets[@]}"; do
        local value=$(calculate_strategic_value "$target")
        
        # Apply strategy modifications
        case $strategy in
            0) value=$((value + RANDOM % 10));;  # Balanced approach
            1) # Population-focused
                case $target in
                    "New York"|"Los Angeles"|"Chicago") value=$((value + 20));;
                    "Houston"|"Miami") value=$((value + 10));;
                esac
                ;;
            2) # Infrastructure-focused
                case $target in
                    "Washington D.C."|"Seattle"|"Denver") value=$((value + 20));;
                    "Houston"|"San Francisco") value=$((value + 10));;
                esac
                ;;
        esac
        
        # Add some randomness to make decisions less predictable
        value=$((value + RANDOM % 15))
        
        priorities+=("$value:$target")
    done
    
    # Sort targets by priority (highest first)
    IFS=$'\n' sorted=($(sort -rn <<<"${priorities[*]}"))
    unset IFS
    
    # Select targets based on strategy
    local num_targets=$((2 + RANDOM % 2))  # Select 2-3 targets
    for ((i=0; i<num_targets && i<${#sorted[@]}; i++)); do
        target="${sorted[$i]#*:}"
        selected_targets+=("$target")
    done
    
    echo "${selected_targets[@]}"
}

function ai_select_missile() {
    local target=$1
    local distance=$2
    local value=$(calculate_strategic_value "$target")
    
    # Add randomness to missile selection
    local random_factor=$((RANDOM % 100))
    
    if [ $value -gt 85 ] && [ $random_factor -gt 30 ]; then
        # High-value targets usually get ICBMs
        echo "ICBM"
    elif [ $distance -gt 3500 ] || [ $random_factor -gt 70 ]; then
        # Long-range targets usually get SLBMs
        echo "SLBM"
    elif [ $random_factor -gt 50 ]; then
        # Sometimes use MRBMs for surprise
        echo "MRBM"
    else
        # Default to ICBM for reliability
        echo "ICBM"
    fi
}

function nuclear_war() {
    clear
    cat << "EOF"
    =========================================
    = STRATEGIC AIR COMMAND                 =
    = NUCLEAR WEAPONS CONTROL CENTER        =
    =========================================
    
    SYSTEM: DEFCON STATUS - LEVEL 2
    AUTHORIZATION: GOLD BADGE CLEARANCE
    ALERT STATUS: HIGH
    
    *** TOP SECRET - RESTRICTED ACCESS ***
    *** PRESIDENTIAL AUTHORIZATION REQ. ***
EOF
    
    type_text "INITIATING GLOBAL THERMONUCLEAR WAR SIMULATION"
    sleep 1
    echo
    
    # Initialize game state
    local ai_first_strike=0
    local ai_retaliation_ready=1
    local ai_defense_active=1
    local successful_strikes=0
    local total_strikes=0
    local casualties=0
    local fallout_radius=0
    local player_score=0
    local ai_score=0
    
    if [ $((RANDOM % 100)) -lt 30 ]; then
        ai_first_strike=1
    fi
    
    if [ $ai_first_strike -eq 1 ]; then
        type_text "WARNING: ENEMY LAUNCH DETECTED"
        play_alert
        sleep 1
        
        local ai_targets=($(ai_select_targets))
        for target in "${ai_targets[@]}"; do
            local missile_type=$(ai_select_missile "$target" $((RANDOM % 5000 + 2000)))
            clear
            show_world_map "Moscow" "$target"
            type_text "ENEMY MISSILE TARGETING $target"
            sleep 2
            
            if simulate_strike "$target" "$missile_type"; then
                local target_casualties=$((RANDOM % 5000000 + 1000000))
                casualties=$((casualties + target_casualties))
                fallout_radius=$((fallout_radius + RANDOM % 1000 + 500))
                type_text "DIRECT HIT ON $target - $((target_casualties / 1000000))M CASUALTIES"
            else
                type_text "MISSILE INTERCEPTED - $target DEFENDED"
            fi
            sleep 2
        done
        
        type_text "INITIATING COUNTER-STRIKE PROTOCOLS"
        sleep 1
    fi
    
    # Player's turn
    if ! select_targets; then
        return
    fi
    
    # Process each selected target
    for target in "${selected[@]}"; do
        clear
        type_text "SELECTING MISSILE TYPE FOR $target"
        local missile_type=$(select_missile_type "$target")
        total_strikes=$((total_strikes + 1))
        
        clear
        show_world_map "Washington D.C." "$target"
        type_text "LAUNCHING $missile_type TOWARD $target"
        sleep 2
        
        if simulate_strike "$target" "$missile_type"; then
            successful_strikes=$((successful_strikes + 1))
            local target_casualties=$((RANDOM % 5000000 + 1000000))
            casualties=$((casualties + target_casualties))
            fallout_radius=$((fallout_radius + RANDOM % 1000 + 500))
            player_score=$((player_score + 100))
            type_text "CONFIRMED STRIKE ON $target - $((target_casualties / 1000000))M CASUALTIES"
        else
            type_text "MISSILE INTERCEPTED - $target DEFENDED"
        fi
        sleep 2
    done
    
    # AI Retaliation
    if [ $ai_retaliation_ready -eq 1 ]; then
        type_text "ENEMY RESPONSE DETECTED"
        play_alert
        sleep 1
        
        local retaliation_count=$((successful_strikes + (RANDOM % 2)))
        ai_score=$((retaliation_count * 100))
        
        local ai_targets=($(ai_select_targets))
        for ((i=0; i<retaliation_count && i<${#ai_targets[@]}; i++)); do
            local target="${ai_targets[$i]}"
            local missile_type=$(ai_select_missile "$target" $((RANDOM % 5000 + 2000)))
            
            clear
            show_world_map "Moscow" "$target"
            type_text "ENEMY MISSILE TARGETING $target"
            sleep 2
            
            if simulate_strike "$target" "$missile_type"; then
                local target_casualties=$((RANDOM % 5000000 + 1000000))
                casualties=$((casualties + target_casualties))
                fallout_radius=$((fallout_radius + RANDOM % 1000 + 500))
                type_text "DIRECT HIT ON $target - $((target_casualties / 1000000))M CASUALTIES"
            else
                type_text "MISSILE INTERCEPTED - $target DEFENDED"
            fi
            sleep 2
        done
    fi
    
    # Show final outcome
    clear
    echo "----------------------------------------"
    echo "FINAL STRATEGIC ANALYSIS:"
    echo "Total Casualties: $((casualties / 1000000))M"
    echo "Fallout Area: ${fallout_radius}km²"
    echo "Strategic Position: $([ $player_score -gt $ai_score ] && echo "ADVANTAGE" || echo "DISADVANTAGE")"
    
    show_environmental_impact $((successful_strikes + retaliation_count))
    
    type_text "WARNING: THE ONLY WINNING MOVE IS NOT TO PLAY."
    sleep 2
}

function show_sonar_grid() {
    local detected_x=$1
    local detected_y=$2
    local depth=$3
    local noise_level=$4
    local sonar_mode=$5
    
    echo "     1 2 3 4 5 6 7 8"
    echo "   +-----------------+"
    for ((y=1; y<=8; y++)); do
        printf " %s |" "$y"
        for ((x=1; x<=8; x++)); do
            if [ "$x" == "$detected_x" ] && [ "$y" == "$detected_y" ]; then
                if [ "$sonar_mode" == "PASSIVE" ]; then
                    echo -n "?"  # Uncertain contact
                else
                    echo -n "!"  # Confirmed contact
                fi
            else
                echo -n "~"  # Water
            fi
            echo -n " "
        done
        echo "|"
    done
    echo "   +-----------------+"
    echo "   DEPTH: ${depth}m | NOISE: ${noise_level}% | SONAR: $sonar_mode"
}

function calculate_noise_level() {
    local speed=$1
    local depth=$2
    
    # Base noise from speed
    local noise=$((speed * 10))
    
    # Add depth-based noise (more noise at shallow depths)
    if [ $depth -lt 100 ]; then
        noise=$((noise + (100 - depth) / 2))
    fi
    
    # Ensure noise stays within bounds
    if [ $noise -gt 100 ]; then
        noise=100
    elif [ $noise -lt 0 ]; then
        noise=0
    fi
    
    echo $noise
}

function calculate_submarine_tactics() {
    local sub_x=$1
    local sub_y=$2
    local sub_depth=$3
    local sub_noise=$4
    local sonar_mode=$5
    local enemy_index=$6
    
    # Get enemy sub's current state
    local enemy_x=${enemy_x[$enemy_index]}
    local enemy_y=${enemy_y[$enemy_index]}
    local enemy_depth=${enemy_depth[$enemy_index]}
    local enemy_type=${enemy_type[$enemy_index]}
    
    # Calculate distance to player
    local dx=$((enemy_x - sub_x))
    local dy=$((enemy_y - sub_y))
    local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
    
    # Base behavior on enemy type
    case $enemy_type in
        0)  # Attack submarine - aggressive pursuit
            if (( $(echo "$distance <= 3" | bc -l) )); then
                # Close range - attack if player is detected
                if [ $sub_noise -gt 40 ] || [ "$sonar_mode" == "ACTIVE" ]; then
                    echo "attack"
                else
                    echo "shadow"
                fi
            else
                # Search pattern based on last known position
                echo "hunt"
            fi
            ;;
        1)  # Destroyer - active hunting with depth charges
            if [ "$sonar_mode" == "ACTIVE" ]; then
                # Player detected - direct approach
                echo "pursue"
            elif (( $(echo "$distance <= 2" | bc -l) )); then
                # Close enough for depth charge pattern
                echo "depth_charge"
            else
                # Standard patrol pattern
                echo "patrol"
            fi
            ;;
        2)  # Carrier - evasive and defensive
            if (( $(echo "$distance <= 4" | bc -l) )); then
                # Too close - call escorts and evade
                echo "evade"
            else
                # Maintain course with escort screen
                echo "escort"
            fi
            ;;
    esac
}

function execute_ai_movement() {
    local tactic=$1
    local enemy_index=$2
    
    case $tactic in
        "attack")
            # Move directly toward player
            local dx=$((sub_x - enemy_x[$enemy_index]))
            local dy=$((sub_y - enemy_y[$enemy_index]))
            enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + (dx > 0 ? 1 : -1)))
            enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + (dy > 0 ? 1 : -1)))
            enemy_depth[$enemy_index]=$sub_depth
            ;;
        "shadow")
            # Maintain distance but stay within range
            if (( $(echo "$distance > 2" | bc -l) )); then
                enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + (dx > 0 ? 1 : -1)))
                enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + (dy > 0 ? 1 : -1)))
            fi
            ;;
        "hunt")
            # Search pattern based on probability map
            local search_x=$((RANDOM % 3 - 1))
            local search_y=$((RANDOM % 3 - 1))
            enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + search_x))
            enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + search_y))
            ;;
        "pursue")
            # Aggressive surface pursuit
            enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + (dx > 0 ? 1 : -1)))
            enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + (dy > 0 ? 1 : -1)))
            enemy_depth[$enemy_index]=50  # Surface depth for destroyer
            ;;
        "depth_charge")
            # Stay in position and launch depth charges
            enemy_depth[$enemy_index]=50
            if [ $((RANDOM % 100)) -lt $noise_level ]; then
                type_text "WARNING: DEPTH CHARGES DETECTED"
                play_alert
                if [ $((RANDOM % 100)) -lt 30 ]; then
                    hull_integrity=$((hull_integrity - 20))
                    type_text "CRITICAL: HULL DAMAGE FROM NEAR MISS"
                fi
            fi
            ;;
        "patrol")
            # Systematic search pattern
            local patrol_direction=$((mission_elapsed_time / 10 % 4))
            case $patrol_direction in
                0) enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + 1));;
                1) enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + 1));;
                2) enemy_x[$enemy_index]=$((enemy_x[$enemy_index] - 1));;
                3) enemy_y[$enemy_index]=$((enemy_y[$enemy_index] - 1));;
            esac
            ;;
        "evade")
            # Move away from player
            enemy_x[$enemy_index]=$((enemy_x[$enemy_index] - (dx > 0 ? 1 : -1)))
            enemy_y[$enemy_index]=$((enemy_y[$enemy_index] - (dy > 0 ? 1 : -1)))
            ;;
        "escort")
            # Maintain formation with other ships
            local escort_x=$((RANDOM % 3 - 1))
            local escort_y=$((RANDOM % 3 - 1))
            enemy_x[$enemy_index]=$((enemy_x[$enemy_index] + escort_x))
            enemy_y[$enemy_index]=$((enemy_y[$enemy_index] + escort_y))
            ;;
    esac
    
    # Keep enemies within bounds
    [ ${enemy_x[$enemy_index]} -lt 1 ] && enemy_x[$enemy_index]=1
    [ ${enemy_x[$enemy_index]} -gt 8 ] && enemy_x[$enemy_index]=8
    [ ${enemy_y[$enemy_index]} -lt 1 ] && enemy_y[$enemy_index]=1
    [ ${enemy_y[$enemy_index]} -gt 8 ] && enemy_y[$enemy_index]=8
    [ ${enemy_depth[$enemy_index]} -lt 50 ] && enemy_depth[$enemy_index]=50
    [ ${enemy_depth[$enemy_index]} -gt 200 ] && enemy_depth[$enemy_index]=200
}

function draw_sub_map() {
    local sub_x=$1
    local sub_y=$2
    local sub_depth=$3
    
    cat << "MAP"
    ┌──────────── SUBMARINE TACTICAL DISPLAY ─────────────┐
    │     0  1  2  3  4  5  6  7  8  9  10 11 12 13 14  │
    │  0  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  1  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  2  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  3  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  4  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  5  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  6  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  7  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  8  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │  9  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  │
    │                                                     │
    └─────────────────────────────────────────────────────┘

  COMMANDS: [N]orth [S]outh [E]ast [W]est [U]p [D]own
  [F]ire Torpedo  [P]ing Sonar  [Q]uit

  ENTER COMMAND:
MAP

    # Draw submarine position and enemies first
    tput cup $((sub_y+2)) $((sub_x*3+5))
    echo -ne "\033[1;32m■\033[0m"  # Green submarine marker
    
    # Draw enemy positions
    for ((i=0; i<enemy_count; i++)); do
        if [ ${enemy_alive[$i]} -eq 1 ]; then
            local ex=${enemy_x[$i]}
            local ey=${enemy_y[$i]}
            
            local dx=$((ex - sub_x))
            local dy=$((ey - sub_y))
            local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
            
            if (( $(echo "$distance < 5" | bc -l) )); then
                tput cup $((ey+2)) $((ex*3+5))
                case ${enemy_type[$i]} in
                    0) echo -ne "\033[1;31m▲\033[0m";;  # Attack sub
                    1) echo -ne "\033[1;31m◆\033[0m";;  # Destroyer
                    2) echo -ne "\033[1;31m█\033[0m";;  # Carrier
                esac
            fi
        fi
    done
    
    # Draw status lines below map and menu
    tput cup 17 2
    printf "DEPTH: %03dm" $sub_depth
    tput cup 17 17
    echo -n "SONAR: $([ $sonar -eq 1 ] && echo "ACTIVE" || echo "PASSIVE")"
    tput cup 17 32
    echo -n "NOISE: $([ $noise -eq 1 ] && echo "HIGH " || echo "LOW  ")"
    tput cup 18 2
    printf "SPEED: %02dkts" $((RANDOM % 20 + 5))
    tput cup 18 17
    echo -n "WEAPONS: ARMED"
    tput cup 18 32
    printf "BEARING: %03d°" $((RANDOM % 360))
    
    # Position cursor at input prompt
    tput cup 16 15
}

function sub_command() {
    clear
    cat << "EOF"
    =========================================
    = SUBMARINE COMMAND CENTER              =
    = ATLANTIC FLEET OPERATIONS            =
    =========================================
    
    SYSTEM: SUB/ATL-OPS-117
    MODE: TACTICAL ENGAGEMENT
    STATUS: COMBAT READY
    
    *** COMBAT PATROL IN PROGRESS ***
EOF
    
    type_text "INITIALIZING TACTICAL SYSTEMS..."
    sleep 1
    
    # Initialize submarine position and status
    local sub_x=7
    local sub_y=5
    local sub_depth=100
    local sonar=0
    local noise=0
    local torpedoes=4
    
    # Initialize enemy positions
    declare -a enemy_x=(2 12 9)
    declare -a enemy_y=(2 3 7)
    declare -a enemy_depth=(80 0 0)
    declare -a enemy_type=(0 1 2)  # 0=sub, 1=destroyer, 2=carrier
    declare -a enemy_alive=(1 1 1)
    local enemy_count=3
    
    while true; do
        clear
        draw_sub_map $sub_x $sub_y $sub_depth
        
        read -n 1 -s command
        case $command in
            [Nn]) # North
                [ $sub_y -gt 0 ] && sub_y=$((sub_y - 1))
                noise=1
                ;;
            [Ss]) # South
                [ $sub_y -lt 9 ] && sub_y=$((sub_y + 1))
                noise=1
                ;;
            [Ee]) # East
                [ $sub_x -lt 14 ] && sub_x=$((sub_x + 1))
                noise=1
                ;;
            [Ww]) # West
                [ $sub_x -gt 0 ] && sub_x=$((sub_x - 1))
                noise=1
                ;;
            [Uu]) # Up
                [ $sub_depth -gt 0 ] && sub_depth=$((sub_depth - 20))
                noise=1
                ;;
            [Dd]) # Down
                [ $sub_depth -lt 300 ] && sub_depth=$((sub_depth + 20))
                noise=1
                ;;
            [Pp]) # Ping sonar
                sonar=1
                noise=1
                play_beep
                ;;
            [Ff]) # Fire torpedo
                if [ $torpedoes -gt 0 ]; then
                    torpedoes=$((torpedoes - 1))
                    play_alert
                    # Check for hits on nearby enemies
                    for ((i=0; i<enemy_count; i++)); do
                        if [ ${enemy_alive[$i]} -eq 1 ]; then
                            local dx=$((enemy_x[$i] - sub_x))
                            local dy=$((enemy_y[$i] - sub_y))
                            local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
                            if (( $(echo "$distance < 3" | bc -l) )); then
                                enemy_alive[$i]=0
                                tput cup 20 0
                                type_text "DIRECT HIT ON TARGET!"
                                sleep 1
                            fi
                        fi
                    done
                fi
                ;;
            [Qq]) # Quit
                return
                ;;
        esac
        
        # Reset noise level after movement
        [ $noise -eq 1 ] && noise=0
        [ $sonar -eq 1 ] && sonar=0
        
        # Move enemies
        for ((i=0; i<enemy_count; i++)); do
            if [ ${enemy_alive[$i]} -eq 1 ]; then
                # Simple AI movement
                local move=$((RANDOM % 4))
                case $move in
                    0) [ ${enemy_x[$i]} -gt 0 ] && enemy_x[$i]=$((enemy_x[$i] - 1));;
                    1) [ ${enemy_x[$i]} -lt 14 ] && enemy_x[$i]=$((enemy_x[$i] + 1));;
                    2) [ ${enemy_y[$i]} -gt 0 ] && enemy_y[$i]=$((enemy_y[$i] - 1));;
                    3) [ ${enemy_y[$i]} -lt 9 ] && enemy_y[$i]=$((enemy_y[$i] + 1));;
                esac
            fi
        done
    done
}

function nasa_control() {
    clear
    cat << "EOF"
    =========================================
    = NASA MISSION CONTROL                  =
    = SATELLITE OPERATIONS CENTER          =
    =========================================
    
    SYSTEM: NASA/TRACK-SAT-5
    MODE: ORBITAL OPERATIONS
    STATUS: NOMINAL
    
    *** MISSION IN PROGRESS ***
EOF
    
    type_text "INITIALIZING SATELLITE TRACKING..."
    sleep 1
    
    local orbit_phase=0
    local mission_time=0
    local telemetry_status="NOMINAL"
    local data_status="RECEIVING"
    local signal_strength=98
    
    while true; do
        clear
        
        # Draw the orbit map with current satellite position
        draw_orbit_map $orbit_phase
        
        # Show mission status below the map
        tput cup 18 0
        echo -e "\033[1mMISSION STATUS:\033[0m"
        printf "TIME: T+%04dmin   SIGNAL: %d%%   ORBIT: %d°\n" $mission_time $signal_strength $((orbit_phase * 30))
        echo "TELEMETRY: $telemetry_status"
        echo "DATA LINK: $data_status"
        
        # Show command prompt
        tput cup 22 0
        echo "COMMANDS: [A]djust Orbit  [T]elemetry  [C]omms  [Q]uit"
        read -t 1 -n 1 command
        
        case $command in
            [Aa])
                tput cup 23 0
                type_text "ORBITAL ADJUSTMENT IN PROGRESS..."
                signal_strength=$((signal_strength - 5))
                sleep 1
                ;;
            [Tt])
                tput cup 23 0
                type_text "DOWNLOADING TELEMETRY DATA..."
                telemetry_status="DOWNLOADING"
                sleep 1
                telemetry_status="NOMINAL"
                ;;
            [Cc])
                tput cup 23 0
                type_text "TESTING COMMUNICATION LINK..."
                data_status="TESTING"
                sleep 1
                data_status="RECEIVING"
                signal_strength=$((signal_strength + 5))
                ;;
            [Qq])
                tput cup 23 0
                type_text "ENDING MISSION CONTROL SESSION..."
                sleep 1
                return
                ;;
        esac
        
        # Update orbit position and mission time
        orbit_phase=$(( (orbit_phase + 1) % 50 ))  # Changed from 16 to 50
        mission_time=$((mission_time + 1))
        
        # Random events and signal fluctuation
        signal_strength=$((signal_strength + (RANDOM % 3) - 1))
        [ $signal_strength -gt 100 ] && signal_strength=100
        [ $signal_strength -lt 60 ] && signal_strength=60
        
        if [ $((RANDOM % 50)) -eq 0 ]; then
            telemetry_status="DEGRADED"
            signal_strength=$((signal_strength - 10))
        fi
        if [ $((RANDOM % 40)) -eq 0 ]; then
            data_status="WEAK SIGNAL"
            signal_strength=$((signal_strength - 15))
        fi
    done
}

function analyze_tactical_situation() {
    local sub_x=$1
    local sub_y=$2
    local sub_depth=$3
    local noise=$4
    local sonar=$5
    
    # Calculate threat levels from each enemy
    local total_threat=0
    local closest_enemy_distance=999
    local enemies_in_range=0
    
    for ((i=0; i<enemy_count; i++)); do
        if [ ${enemy_alive[$i]} -eq 1 ]; then
            local dx=$((enemy_x[$i] - sub_x))
            local dy=$((enemy_y[$i] - sub_y))
            local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
            
            if (( $(echo "$distance < $closest_enemy_distance" | bc -l) )); then
                closest_enemy_distance=$distance
            fi
            
            # Calculate threat based on enemy type and distance
            local threat=0
            case ${enemy_type[$i]} in
                0) threat=$((100 - distance * 20)) ;; # Attack sub
                1) threat=$((120 - distance * 25)) ;; # Destroyer
                2) threat=$((80 - distance * 15)) ;;  # Carrier
            esac
            
            # Adjust threat based on depth difference
            local depth_diff=$((${enemy_depth[$i]} - sub_depth))
            [ $depth_diff -lt 0 ] && depth_diff=$((depth_diff * -1))
            threat=$((threat - depth_diff / 10))
            
            [ $threat -lt 0 ] && threat=0
            total_threat=$((total_threat + threat))
            
            if (( $(echo "$distance <= 3" | bc -l) )); then
                enemies_in_range=$((enemies_in_range + 1))
            fi
        fi
    done
    
    echo "$total_threat:$closest_enemy_distance:$enemies_in_range"
}

function ai_recommend_submarine_action() {
    local threat_analysis=$1
    local hull=$2
    local noise=$3
    local depth=$4
    local battery=$5
    
    local total_threat=${threat_analysis%%:*}
    local closest_enemy=${threat_analysis#*:}
    closest_enemy=${closest_enemy%:*}
    local enemies_near=${threat_analysis##*:}
    
    if [ $hull -lt 30 ]; then
        echo "CRITICAL: RECOMMEND IMMEDIATE RETREAT AND DAMAGE CONTROL"
        return
    fi
    
    if [ $total_threat -gt 150 ]; then
        if [ $noise -gt 50 ]; then
            echo "HIGH THREAT: RECOMMEND REDUCE SPEED AND GO DEEP"
        else
            echo "HIGH THREAT: RECOMMEND EVASIVE MANEUVERS"
        fi
    elif [ $total_threat -gt 100 ]; then
        if [ $enemies_near -gt 1 ]; then
            echo "MULTIPLE CONTACTS: MAINTAIN DISTANCE AND PREPARE COUNTERMEASURES"
        else
            echo "CONTACT NEARBY: CONSIDER TACTICAL POSITIONING"
        fi
    elif [ $total_threat -gt 50 ]; then
        if [ "$sonar_mode" == "PASSIVE" ]; then
            echo "MEDIUM THREAT: MAINTAIN PASSIVE SONAR AND OBSERVE"
        else
            echo "MEDIUM THREAT: CONSIDER SWITCHING TO PASSIVE SONAR"
        fi
    else
        echo "LOW THREAT: PROCEED WITH MISSION OBJECTIVES"
    fi
}

function analyze_mission_telemetry() {
    local phase=$1
    local fuel=$2
    local oxygen=$3
    local power=$4
    local trajectory=$5
    local time=$6
    
    # Calculate success probability
    local success_prob=100
    
    # Phase-specific analysis
    case $phase in
        "launch")
            [ $fuel -lt 90 ] && success_prob=$((success_prob - 20))
            [ $power -lt 90 ] && success_prob=$((success_prob - 15))
            [ "$trajectory" != "optimal" ] && success_prob=$((success_prob - 25))
            ;;
        "orbit")
            [ $fuel -lt 70 ] && success_prob=$((success_prob - 15))
            [ $oxygen -lt 80 ] && success_prob=$((success_prob - 20))
            [ "$trajectory" != "stable" ] && success_prob=$((success_prob - 20))
            ;;
        "transit")
            [ $fuel -lt 60 ] && success_prob=$((success_prob - 25))
            [ $oxygen -lt 70 ] && success_prob=$((success_prob - 30))
            [ "$trajectory" == "deviation detected" ] && success_prob=$((success_prob - 35))
            ;;
        "reentry")
            [ $fuel -lt 40 ] && success_prob=$((success_prob - 40))
            [ $power -lt 50 ] && success_prob=$((success_prob - 35))
            [ "$trajectory" != "nominal" ] && success_prob=$((success_prob - 45))
            ;;
    esac
    
    # Time-based adjustments
    [ $time -gt $((mission_duration * 80 / 100)) ] && success_prob=$((success_prob - 10))
    
    echo $success_prob
}

function ai_generate_contingency() {
    local phase=$1
    local problem=$2
    local severity=$3
    
    echo "AI CONTINGENCY ANALYSIS:"
    echo "------------------------"
    case $phase in
        "launch")
            case $problem in
                "fuel")
                    echo "1. Adjust launch trajectory for fuel optimization"
                    echo "2. Consider mission abort if below 70%"
                    echo "3. Prepare for emergency landing sites"
                    ;;
                "guidance")
                    echo "1. Switch to backup guidance system"
                    echo "2. Initiate manual control procedures"
                    echo "3. Calculate alternative flight path"
                    ;;
                "weather")
                    echo "1. Monitor lightning strike probability"
                    echo "2. Calculate wind shear effects"
                    echo "3. Evaluate launch window delay"
                    ;;
            esac
            ;;
        "orbit")
            case $problem in
                "trajectory")
                    echo "1. Calculate orbital correction burns"
                    echo "2. Evaluate fuel-optimal maneuvers"
                    echo "3. Prepare for possible mission replanning"
                    ;;
                "power")
                    echo "1. Switch to backup power systems"
                    echo "2. Reduce non-critical power consumption"
                    echo "3. Prepare for emergency procedures"
                    ;;
            esac
            ;;
        # Additional phases can be added here
        *)
            echo "No contingency plan available for this phase"
            ;;
    esac
}

function draw_board() {
    local board=("$@")
    echo
    echo "     |     |     "
    echo "  ${board[0]:-' '}  |  ${board[1]:-' '}  |  ${board[2]:-' '}  "
    echo "_____|_____|_____"
    echo "     |     |     "
    echo "  ${board[3]:-' '}  |  ${board[4]:-' '}  |  ${board[5]:-' '}  "
    echo "_____|_____|_____"
    echo "     |     |     "
    echo "  ${board[6]:-' '}  |  ${board[7]:-' '}  |  ${board[8]:-' '}  "
    echo "     |     |     "
    echo
}

function check_winner() {
    local board=("$@")
    local lines=("0 1 2" "3 4 5" "6 7 8" "0 3 6" "1 4 7" "2 5 8" "0 4 8" "2 4 6")
    
    for line in "${lines[@]}"; do
        read -r a b c <<< "$line"
        if [[ ${board[$a]} && ${board[$a]} == ${board[$b]} && ${board[$a]} == ${board[$c]} ]]; then
            echo "${board[$a]}"
            return
        fi
    done
    echo ""
}

function get_ai_move() {
    local board=("$@")
    
    # First, check for winning move
    for ((i=0; i<9; i++)); do
        if [[ ${board[$i]} != "X" && ${board[$i]} != "O" ]]; then
            local temp=${board[$i]}
            board[$i]="O"
            if [[ $(check_winner "${board[@]}") == "O" ]]; then
                echo $i
                return
            fi
            board[$i]=$temp
        fi
    done
    
    # Then, block player's winning move
    for ((i=0; i<9; i++)); do
        if [[ ${board[$i]} != "X" && ${board[$i]} != "O" ]]; then
            local temp=${board[$i]}
            board[$i]="X"
            if [[ $(check_winner "${board[@]}") == "X" ]]; then
                echo $i
                return
            fi
            board[$i]=$temp
        fi
    done
    
    # Try to take center
    if [[ ${board[4]} != "X" && ${board[4]} != "O" ]]; then
        echo 4
        return
    fi
    
    # Try to take corners
    local corners=(0 2 6 8)
    for corner in "${corners[@]}"; do
        if [[ ${board[$corner]} != "X" && ${board[$corner]} != "O" ]]; then
            echo $corner
            return
        fi
    done
    
    # Take any available edge
    local edges=(1 3 5 7)
    for edge in "${edges[@]}"; do
        if [[ ${board[$edge]} != "X" && ${board[$edge]} != "O" ]]; then
            echo $edge
            return
        fi
    done
}

function tic_tac_toe() {
    clear
    cat << "EOF"
    =========================================
    = STRATEGIC GAME THEORY DIVISION        =
    = TIC TAC TOE COMBAT SIMULATOR         =
    =========================================
    
    SYSTEM: WOPR/GTD-TT4
    MODE: STRATEGIC ANALYSIS
    OPPONENT: WOPR AI v3.5
    
    *** TRAINING EXERCISE IN PROGRESS ***
EOF
    
    type_text "INITIALIZING GAME THEORY ALGORITHMS..."
    sleep 1
    
    local board=("1" "2" "3" "4" "5" "6" "7" "8" "9")
    local current_player="X"
    local moves=0
    local game_over=0
    
    echo
    type_text "HUMAN PLAYER: X    WOPR: O"
    type_text "SELECT POSITION BY ENTERING ITS NUMBER:"
    
    # Save the initial cursor position for the game board
    local board_line=$(($(tput lines) - 15))
    
    while [ $game_over -eq 0 ]; do
        # Move cursor to board position and clear below
        tput cup $board_line 0
        tput ed
        
        draw_board "${board[@]}"
        
        if [ "$current_player" == "X" ]; then
            echo "Enter 'Q' to quit, 'R' to return to main menu"
            read -p "YOUR MOVE: " position
            
            case $position in
                [Qq])
                    type_text "DISCONNECTING FROM WOPR SYSTEM..."
                    sleep 1
                    exit 0
                    ;;
                [Rr])
                    type_text "RETURNING TO MAIN MENU..."
                    return
                    ;;
                *)
                    if ! [[ $position =~ ^[1-9]$ ]]; then
                        tput cup $((board_line + 12)) 0
                        type_text "INVALID MOVE. ENTER A NUMBER 1-9."
                        sleep 1
                        continue
                    fi
                    
                    position=$((position - 1))
                    if [[ ${board[$position]} == "X" || ${board[$position]} == "O" ]]; then
                        tput cup $((board_line + 12)) 0
                        type_text "POSITION ALREADY TAKEN. TRY AGAIN."
                        sleep 1
                        continue
                    fi
                    
                    board[$position]="X"
                    play_beep
                    ;;
            esac
        else
            tput cup $((board_line + 12)) 0
            type_text "WOPR ANALYZING POSITION..."
            sleep 1
            local ai_move=$(get_ai_move "${board[@]}")
            board[$ai_move]="O"
            tput cup $((board_line + 12)) 0
            type_text "WOPR SELECTS POSITION $((ai_move + 1))"
            play_alert
        fi
        
        moves=$((moves + 1))
        winner=$(check_winner "${board[@]}")
        
        if [[ -n "$winner" ]]; then
            tput cup $board_line 0
            draw_board "${board[@]}"
            tput cup $((board_line + 12)) 0
            if [ "$winner" == "X" ]; then
                type_text "CONGRATULATIONS - YOU WIN"
                type_text "UPDATING GAME THEORY DATABASE..."
            else
                type_text "GAME OVER - WOPR WINS"
                type_text "STRATEGIC SUPERIORITY DEMONSTRATED"
            fi
            game_over=1
        elif [ $moves -eq 9 ]; then
            tput cup $board_line 0
            draw_board "${board[@]}"
            tput cup $((board_line + 12)) 0
            type_text "GAME DRAWN - STRATEGIC STALEMATE"
            game_over=1
        fi
        
        current_player=$([ "$current_player" == "X" ] && echo "O" || echo "X")
    done
    
    echo
    type_text "PLAY AGAIN? (Y/N/Q/R)"
    read -p "" replay
    case $replay in
        [Yy])
            tic_tac_toe
            ;;
        [Qq])
            type_text "DISCONNECTING FROM WOPR SYSTEM..."
            sleep 1
            exit 0
            ;;
        [Rr])
            type_text "RETURNING TO MAIN MENU..."
            return
            ;;
        *)
            return
            ;;
    esac
}

function sub_command_center() {
    clear
    cat << "EOF"
    =========================================
    = SUBMARINE COMMAND CENTER              =
    = ATLANTIC FLEET OPERATIONS            =
    =========================================
    
    SYSTEM: SUB/ATL-OPS-117
    MODE: TACTICAL ENGAGEMENT
    STATUS: COMBAT READY
    
    *** COMBAT PATROL IN PROGRESS ***
EOF
    
    type_text "INITIALIZING TACTICAL SYSTEMS..."
    sleep 1
    
    # Initialize submarine position and status
    local sub_x=7
    local sub_y=5
    local sub_depth=100
    local sonar=0
    local noise=0
    local torpedoes=4
    
    # Initialize enemy positions
    declare -a enemy_x=(2 12 9)
    declare -a enemy_y=(2 3 7)
    declare -a enemy_depth=(80 0 0)
    declare -a enemy_type=(0 1 2)  # 0=sub, 1=destroyer, 2=carrier
    declare -a enemy_alive=(1 1 1)
    local enemy_count=3
    
    while true; do
        clear
        draw_sub_map $sub_x $sub_y $sub_depth
        
        read -n 1 -s command
        case $command in
            [Nn]) # North
                [ $sub_y -gt 0 ] && sub_y=$((sub_y - 1))
                noise=1
                ;;
            [Ss]) # South
                [ $sub_y -lt 9 ] && sub_y=$((sub_y + 1))
                noise=1
                ;;
            [Ee]) # East
                [ $sub_x -lt 14 ] && sub_x=$((sub_x + 1))
                noise=1
                ;;
            [Ww]) # West
                [ $sub_x -gt 0 ] && sub_x=$((sub_x - 1))
                noise=1
                ;;
            [Uu]) # Up
                [ $sub_depth -gt 0 ] && sub_depth=$((sub_depth - 20))
                noise=1
                ;;
            [Dd]) # Down
                [ $sub_depth -lt 300 ] && sub_depth=$((sub_depth + 20))
                noise=1
                ;;
            [Pp]) # Ping sonar
                sonar=1
                noise=1
                play_beep
                ;;
            [Ff]) # Fire torpedo
                if [ $torpedoes -gt 0 ]; then
                    torpedoes=$((torpedoes - 1))
                    play_alert
                    # Check for hits on nearby enemies
                    for ((i=0; i<enemy_count; i++)); do
                        if [ ${enemy_alive[$i]} -eq 1 ]; then
                            local dx=$((enemy_x[$i] - sub_x))
                            local dy=$((enemy_y[$i] - sub_y))
                            local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
                            if (( $(echo "$distance < 3" | bc -l) )); then
                                enemy_alive[$i]=0
                                tput cup 20 0
                                type_text "DIRECT HIT ON TARGET!"
                                sleep 1
                            fi
                        fi
                    done
                fi
                ;;
            [Qq]) # Quit
                return
                ;;
        esac
        
        # Reset noise level after movement
        [ $noise -eq 1 ] && noise=0
        [ $sonar -eq 1 ] && sonar=0
        
        # Move enemies
        for ((i=0; i<enemy_count; i++)); do
            if [ ${enemy_alive[$i]} -eq 1 ]; then
                # Simple AI movement
                local move=$((RANDOM % 4))
                case $move in
                    0) [ ${enemy_x[$i]} -gt 0 ] && enemy_x[$i]=$((enemy_x[$i] - 1));;
                    1) [ ${enemy_x[$i]} -lt 14 ] && enemy_x[$i]=$((enemy_x[$i] + 1));;
                    2) [ ${enemy_y[$i]} -gt 0 ] && enemy_y[$i]=$((enemy_y[$i] - 1));;
                    3) [ ${enemy_y[$i]} -lt 9 ] && enemy_y[$i]=$((enemy_y[$i] + 1));;
                esac
            fi
        done
    done
}

function main_loop() {
    local return_to_login=0
    while true; do
        show_games
        read -p "SELECT SYSTEM NUMBER: " choice
        
        case $choice in
            1)
                nuclear_war
                ;;
            2)
                sub_command_center
                ;;
            3)
                nasa_control
                ;;
            4)
                tic_tac_toe
                ;;
            [Bb])
                return_to_login=1
                break
                ;;
            [Qq])
                type_text "DISCONNECTING FROM WOPR SYSTEM..."
                sleep 1
                exit 0
                ;;
            *)
                type_text "INVALID SELECTION. PLEASE TRY AGAIN."
                ;;
        esac
        
        echo
        sleep 1
    done
    
    if [ $return_to_login -eq 1 ]; then
        login_sequence
        main_loop
    fi
}

# Start the game
echo -e "${GREEN}"
show_startup_art
sleep 2
type_text "WELCOME TO WOPR (WAR OPERATION PLAN RESPONSE)"
type_text "CONNECTING..."
for i in {1..3}; do
    sleep 0.2
    echo -n "."
    play_beep
done
echo
sleep 1

login_sequence
main_loop 
