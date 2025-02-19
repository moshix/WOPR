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
# v0.09 war operation plan response
# v0.10 time out for login (to not keep docker container )


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
    kill $timer_pid 2>/dev/null
    
    # Show "processing" animation
    echo -n "AUTHENTICATING"
    for i in {1..3}; do
        sleep 0.5
        echo -n "."
        play_beep
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
    type_text "SELECT UP TO 3 PRIMARY TARGETS (ENTER NUMBERS SEPARATED BY SPACES):"
    read -r choices
    
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

function simulate_strike() {
    local target=$1
    local missile_type=$2
    local defense_prob=$(calculate_defense_probability "$target" "$missile_type")
    local random_num=$((RANDOM % 100 + 1))
    
    clear
    show_missile_art "launch"
    type_text "LAUNCHING $missile_type TOWARD $target"
    sleep 1
    
    clear
    show_missile_art "trajectory"
    type_text "MISSILE TRACKING:"
    for i in {1..5}; do
        echo -n "."
        play_beep
        sleep 0.3
    done
    echo
    
    if [ $random_num -le $defense_prob ]; then
        type_text "ALERT: MISSILE INTERCEPTED BY DEFENSE SYSTEMS"
        return 1
    else
        clear
        show_missile_art "explosion"
        type_text "DIRECT HIT CONFIRMED"
        play_alert
        sleep 1
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
    case $target in
        "New York") echo "95";;      # Financial center
        "Moscow") echo "90";;        # Command center
        "Washington D.C.") echo "100";; # Capital
        "London") echo "85";;        # Major ally
        "Beijing") echo "88";;       # Industrial/military
        "Paris") echo "80";;         # NATO headquarters
        "Los Angeles") echo "75";;   # Population/industry
        "Tokyo") echo "82";;         # Tech/industry
        "Berlin") echo "78";;        # European power
        *) echo "70";;              # Default value
    esac
}

function ai_select_targets() {
    local available_targets=("Washington D.C." "New York" "Los Angeles" "Chicago" "Houston" "Seattle" "Miami" "Denver" "Boston" "San Francisco")
    local selected_targets=()
    local priorities=()
    
    # Calculate strategic value for each target
    for target in "${available_targets[@]}"; do
        local value=$(calculate_strategic_value "$target")
        priorities+=("$value:$target")
    done
    
    # Sort targets by priority (highest first)
    IFS=$'\n' sorted=($(sort -rn <<<"${priorities[*]}"))
    unset IFS
    
    # Select top 3 highest value targets
    for ((i=0; i<3; i++)); do
        target="${sorted[$i]#*:}"
        selected_targets+=("$target")
    done
    
    echo "${selected_targets[@]}"
}

function ai_select_missile() {
    local target=$1
    local distance=$2
    local value=$(calculate_strategic_value "$target")
    
    if [ $value -gt 90 ]; then
        # High-value targets get ICBMs for maximum probability
        echo "ICBM"
    elif [ $distance -gt 4000 ]; then
        # Long-range targets get SLBMs for stealth
        echo "SLBM"
    else
        # Shorter range targets get MRBMs for quick strike
        echo "MRBM"
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
    
    # Initialize AI strategy
    local ai_first_strike=0
    local ai_retaliation_ready=1
    local ai_defense_active=1
    local ai_counter_force=0  # 0 for counter-value, 1 for counter-force
    
    if [ $((RANDOM % 100)) -lt 30 ]; then
        ai_first_strike=1  # 30% chance AI strikes first
    fi
    
    if [ $ai_first_strike -eq 1 ]; then
        type_text "WARNING: ENEMY LAUNCH DETECTED"
        play_alert
        sleep 1
        
        # AI launches first strike
        local ai_targets=($(ai_select_targets))
        for target in "${ai_targets[@]}"; do
            local missile_type=$(ai_select_missile "$target" $((RANDOM % 5000 + 2000)))
            if simulate_strike "$target" "$missile_type"; then
                show_detailed_casualties "$target" "$missile_type"
            fi
            sleep 1
        done
        
        type_text "INITIATING COUNTER-STRIKE PROTOCOLS"
    fi
    
    # Player's turn
    if ! select_targets; then
        return
    fi
    
    local successful_strikes=0
    local total_strikes=0
    
    # Process each selected target
    for target in "${selected[@]}"; do
        local missile_type=$(select_missile_type "$target")
        total_strikes=$((total_strikes + 1))
        
        if simulate_strike "$target" "$missile_type"; then
            successful_strikes=$((successful_strikes + 1))
            show_detailed_casualties "$target" "$missile_type"
        fi
        sleep 1
    done
    
    # Enhanced AI retaliation
    if [ $ai_retaliation_ready -eq 1 ]; then
        echo
        type_text "ENEMY RESPONSE ANALYSIS:"
        if [ $successful_strikes -gt 2 ]; then
            type_text "MAXIMUM RETALIATION AUTHORIZED"
            ai_counter_force=1
            retaliation_count=$((successful_strikes + 2))
        else
            type_text "PROPORTIONAL RESPONSE AUTHORIZED"
            retaliation_count=$successful_strikes
        fi
        
        # AI selects strategic targets based on remaining capabilities
        local ai_targets=($(ai_select_targets))
        echo
        type_text "ENEMY RETALIATION TARGETS:"
        
        for ((i=0; i<retaliation_count && i<${#ai_targets[@]}; i++)); do
            local target="${ai_targets[$i]}"
            local missile_type=$(ai_select_missile "$target" $((RANDOM % 5000 + 2000)))
            
            if [ $ai_counter_force -eq 1 ]; then
                # Target military installations
                type_text "TARGETING MILITARY INSTALLATION NEAR $target"
            else
                # Target population centers
                type_text "TARGETING URBAN CENTER: $target"
            fi
            
            if simulate_strike "$target" "$missile_type"; then
                show_detailed_casualties "$target" "$missile_type"
            fi
        done
    fi
    
    # Calculate final outcome
    local player_score=$((successful_strikes * 100))
    local ai_score=$((retaliation_count * 100))
    
    type_text "FINAL STRATEGIC ANALYSIS:"
    echo "----------------------------------------"
    echo "Player Strike Success: $successful_strikes"
    echo "Enemy Strike Success: $retaliation_count"
    echo "Strategic Position: $([ $player_score -gt $ai_score ] && echo "ADVANTAGE" || echo "DISADVANTAGE")"
    echo
    
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

function sub_command_center() {
    clear
    cat << "EOF"
    =========================================
    = SUBMARINE TACTICAL COMMAND CENTER      =
    = ATLANTIC FLEET - STRATEGIC OPERATIONS  =
    =========================================
    
    VESSEL: SSN-752 PASADENA
    CLASS: LOS ANGELES (688)
    STATUS: DEEP SILENT RUNNING
    
    *** CLASSIFIED - EYES ONLY ***
EOF

    type_text "ACCESSING SUBMARINE TACTICAL SYSTEMS..."
    sleep 1
    
    # Initialize submarine parameters with more realistic values
    local sub_x=$((RANDOM % 8 + 1))
    local sub_y=$((RANDOM % 8 + 1))
    local sub_depth=100
    local sub_speed=1  # Speed in knots
    local sub_heading=0
    local noise_level=20
    local sonar_mode="PASSIVE"
    local torpedoes=6
    local decoys=3
    local oxygen_level=100
    local battery_level=100
    local hull_integrity=100
    local reactor_temp=normal
    local ballast_status="neutral"
    local crew_status="ready"
    
    # Add more enemy types and behaviors using parallel arrays
    local enemy_count=3
    local enemy_x=()
    local enemy_y=()
    local enemy_depth=()
    local enemy_type=()  # 0=submarine, 1=destroyer, 2=carrier
    local enemy_alive=()
    local enemy_heading=()
    local enemy_speed=()

    for ((i=0; i<enemy_count; i++)); do
        enemy_x[$i]=$((RANDOM % 8 + 1))
        enemy_y[$i]=$((RANDOM % 8 + 1))
        enemy_depth[$i]=$((RANDOM % 150 + 50))
        enemy_type[$i]=$((RANDOM % 3))
        enemy_alive[$i]=1
        enemy_heading[$i]=$((RANDOM % 360))
        enemy_speed[$i]=$((RANDOM % 3 + 1))
    done

    # Add mission objectives
    local mission_type=$((RANDOM % 3))  # 0=patrol, 1=intercept, 2=escort
    local mission_complete=0
    local patrol_points=0
    local time_remaining=100

    case $mission_type in
        0) type_text "MISSION: PATROL SECTOR AND ELIMINATE THREATS" ;;
        1) type_text "MISSION: INTERCEPT ENEMY CARRIER GROUP" ;;
        2) type_text "MISSION: ESCORT FRIENDLY VESSELS" ;;
    esac
    sleep 2

    local turns=0
    local game_over=0
    
    while [ $game_over -eq 0 ] && [ $oxygen_level -gt 0 ] && [ $battery_level -gt 0 ] && [ $hull_integrity -gt 0 ]; do
        clear
        echo "SUBMARINE WARFARE CONTROL SYSTEM"
        echo "================================"
        echo "STATUS:"
        echo "- Hull Integrity: $hull_integrity%"
        echo "- Reactor Temperature: $reactor_temp"
        echo "- Ballast Status: $ballast_status"
        echo "- Crew Status: $crew_status"
        echo "- Torpedoes: $torpedoes"
        echo "- Decoys: $decoys"
        echo "- Speed: ${sub_speed} knots"
        echo "- Heading: ${sub_heading}°"
        echo "- Oxygen: ${oxygen_level}%"
        echo "- Battery: ${battery_level}%"
        echo "- Position: ($sub_x, $sub_y, ${sub_depth}m)"
        echo "- Time Remaining: ${time_remaining}"
        
        # Calculate noise level based on speed and depth
        noise_level=$(calculate_noise_level $sub_speed $sub_depth)
        
        # Show contacts based on sonar mode and noise
        local detected_x="-"
        local detected_y="-"
        local detected_depth=0
        
        for ((i=0; i<enemy_count; i++)); do
            if [ ${enemy_alive[$i]} -eq 1 ]; then
                local dx=$((enemy_x[$i] - sub_x))
                local dy=$((enemy_y[$i] - sub_y))
                local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
                
                # Detection range varies by sonar mode and noise
                local detection_range=3
                if [ "$sonar_mode" == "ACTIVE" ]; then
                    detection_range=4
                else
                    detection_range=$((4 - noise_level / 25))
                fi
                
                if (( $(echo "$distance <= $detection_range" | bc -l) )); then
                    detected_x=${enemy_x[$i]}
                    detected_y=${enemy_y[$i]}
                    detected_depth=${enemy_depth[$i]}
                    break
                fi
            fi
        done
        
        show_sonar_grid $detected_x $detected_y $sub_depth $noise_level $sonar_mode
        
        echo
        echo "COMMANDS:"
        echo "1. Move submarine (M)"
        echo "2. Change depth (D)"
        echo "3. Adjust speed (S)"
        echo "4. Change heading (H)"
        echo "5. Toggle sonar (T)"
        echo "6. Fire torpedo (F)"
        echo "7. Deploy decoy (Y)"
        echo "8. Emergency Blow (B)"
        echo "9. Reactor Control (R)"
        echo "10. Damage Control (C)"
        echo "11. Surface and abort (Q)"
        echo "R. Return to Main Menu"
        echo "Q. Quit WOPR System"
        read -p "Enter command: " cmd
        
        case $cmd in
            [Mm])
                read -p "Enter new X position (1-8): " new_x
                read -p "Enter new Y position (1-8): " new_y
                if [[ $new_x =~ ^[1-8]$ ]] && [[ $new_y =~ ^[1-8]$ ]]; then
                    sub_x=$new_x
                    sub_y=$new_y
                    battery_level=$((battery_level - sub_speed))
                    type_text "Moving to position ($sub_x, $sub_y)"
                    play_beep
                fi
                ;;
            [Dd])
                read -p "Enter new depth (50-200m): " new_depth
                if [[ $new_depth =~ ^[0-9]+$ ]] && [ $new_depth -ge 50 ] && [ $new_depth -le 200 ]; then
                    sub_depth=$new_depth
                    battery_level=$((battery_level - 2))
                    type_text "Changing depth to ${sub_depth}m"
                    play_beep
                fi
                ;;
            [Ss])
                read -p "Enter new speed (0-5 knots): " new_speed
                if [[ $new_speed =~ ^[0-5]$ ]]; then
                    sub_speed=$new_speed
                    type_text "Adjusting speed to $sub_speed knots"
                    play_beep
                fi
                ;;
            [Hh])
                read -p "Enter new heading (0-359): " new_heading
                if [[ $new_heading =~ ^[0-9]+$ ]] && [ $new_heading -ge 0 ] && [ $new_heading -lt 360 ]; then
                    sub_heading=$new_heading
                    type_text "Changing heading to ${sub_heading}°"
                    play_beep
                fi
                ;;
            [Tt])
                if [ "$sonar_mode" == "PASSIVE" ]; then
                    sonar_mode="ACTIVE"
                    noise_level=$((noise_level + 20))
                else
                    sonar_mode="PASSIVE"
                    noise_level=$((noise_level - 20))
                fi
                type_text "Switching to $sonar_mode sonar"
                play_beep
                ;;
            [Ff])
                if [ $torpedoes -gt 0 ]; then
                    torpedoes=$((torpedoes - 1))
                    noise_level=$((noise_level + 30))
                    
                    # Check for hits on any enemy
                    local hit=0
                    for ((i=0; i<enemy_count; i++)); do
                        if [ ${enemy_alive[$i]} -eq 1 ]; then
                            if [ ${enemy_x[$i]} -eq $detected_x ] && [ ${enemy_y[$i]} -eq $detected_y ] && [ $((${enemy_depth[$i]} - sub_depth)) -lt 20 ]; then
                                enemy_alive[$i]=0
                                hit=1
                                break
                            fi
                        fi
                    done
                    
                    if [ $hit -eq 1 ]; then
                        clear
                        type_text "DIRECT HIT CONFIRMED"
                        cat << "EOF"
                               ____
                         ___,-'    `-.
                        |            /
                        |   *      |
                        \     ****  \
                         `-.____,.-'
EOF
                        play_alert
                        type_text "ENEMY VESSEL DESTROYED"
                        
                        # Check if all enemies are destroyed
                        local all_destroyed=1
                        for ((i=0; i<enemy_count; i++)); do
                            if [ ${enemy_alive[$i]} -eq 1 ]; then
                                all_destroyed=0
                                break
                            fi
                        done
                        
                        if [ $all_destroyed -eq 1 ]; then
                            type_text "ALL ENEMY VESSELS ELIMINATED"
                            game_over=1
                            break
                        fi
                    else
                        type_text "TORPEDO MISSED TARGET"
                    fi
                else
                    type_text "NO TORPEDOES REMAINING"
                fi
                ;;
            [Yy])
                if [ $decoys -gt 0 ]; then
                    decoys=$((decoys - 1))
                    noise_level=$((noise_level - 20))
                    type_text "DEPLOYING DECOY"
                    play_beep
                else
                    type_text "NO DECOYS REMAINING"
                fi
                ;;
            [Bb])
                type_text "EMERGENCY BLOW INITIATED"
                play_alert
                sub_depth=50
                noise_level=$((noise_level + 40))
                battery_level=$((battery_level - 10))
                ballast_status="positive"
                ;;
            [Rr])
                type_text "RETURNING TO MAIN MENU..."
                return
                ;;
            [Qq])
                type_text "DISCONNECTING FROM WOPR SYSTEM..."
                sleep 1
                exit 0
                ;;
            [Cc])
                if [ $hull_integrity -lt 100 ]; then
                    type_text "DAMAGE CONTROL TEAM DEPLOYED"
                    hull_integrity=$((hull_integrity + 10))
                    [ $hull_integrity -gt 100 ] && hull_integrity=100
                    oxygen_level=$((oxygen_level - 5))
                else
                    type_text "NO DAMAGE TO REPAIR"
                fi
                ;;
        esac
        
        # Update game state
        turns=$((turns + 1))
        oxygen_level=$((oxygen_level - 1))
        battery_level=$((battery_level - sub_speed))
        
        # Enemy movement and attacks
        for ((i=0; i<enemy_count; i++)); do
            if [ ${enemy_alive[$i]} -eq 1 ]; then
                # Calculate AI tactics based on situation
                local tactic=$(calculate_submarine_tactics "$sub_x" "$sub_y" "$sub_depth" "$noise_level" "$sonar_mode" "$i")
                
                # Execute movement based on tactics
                execute_ai_movement "$tactic" "$i"
                
                # Enemy detection and attack logic
                if [ ${enemy_type[$i]} -eq 1 ] && [ $sonar_mode == "ACTIVE" ]; then
                    local dx=$((enemy_x[$i] - sub_x))
                    local dy=$((enemy_y[$i] - sub_y))
                    local distance=$(echo "sqrt($dx^2 + $dy^2)" | bc)
                    
                    if (( $(echo "$distance <= 2" | bc -l) )); then
                        clear
                        type_text "WARNING: DETECTED BY ENEMY DESTROYER"
                        type_text "DEPTH CHARGES INCOMING"
                        play_alert
                        
                        # More sophisticated damage calculation based on distance and noise
                        local damage_chance=$((noise_level + (3 - distance) * 20))
                        if [ $((RANDOM % 100)) -lt $damage_chance ]; then
                            local damage=$((RANDOM % 30 + 10))
                            hull_integrity=$((hull_integrity - damage))
                            type_text "CRITICAL DAMAGE - HULL INTEGRITY AT $hull_integrity%"
                            if [ $hull_integrity -le 0 ]; then
                                game_over=2
                                break
                            fi
                        fi
                    fi
                fi
            fi
        done

        # Update mission objectives
        case $mission_type in
            0)  # Patrol
                patrol_points=$((patrol_points + 1))
                [ $patrol_points -ge 50 ] && mission_complete=1
                ;;
            1)  # Intercept
                for ((i=0; i<enemy_count; i++)); do
                    if [ ${enemy_type[$i]} -eq 2 ] && [ ${enemy_alive[$i]} -eq 0 ]; then
                        mission_complete=1
                        break
                    fi
                done
                ;;
            2)  # Escort
                # Add escort mission logic here
                ;;
        esac

        # Add random events
        if [ $((RANDOM % 20)) -eq 0 ]; then
            case $((RANDOM % 5)) in
                0)
                    type_text "WARNING: REACTOR TEMPERATURE SPIKE"
                    reactor_temp="critical"
                    ;;
                1)
                    type_text "ALERT: HULL STRESS DETECTED"
                    hull_integrity=$((hull_integrity - 10))
                    ;;
                2)
                    type_text "CREW FATIGUE INCREASING"
                    crew_status="tired"
                    ;;
                3)
                    type_text "SONAR MALFUNCTION"
                    noise_level=$((noise_level + 20))
                    ;;
                4)
                    type_text "EMERGENCY: FLOODING IN COMPARTMENT"
                    hull_integrity=$((hull_integrity - 20))
                    ;;
            esac
        fi

        # Update time and check victory conditions
        time_remaining=$((time_remaining - 1))
        if [ $time_remaining -le 0 ]; then
            type_text "MISSION TIME EXPIRED"
            game_over=1
        elif [ $mission_complete -eq 1 ]; then
            type_text "MISSION ACCOMPLISHED"
            game_over=1
        fi
    done
    
    # Enhanced end game messages
    if [ $game_over -eq 2 ]; then
        type_text "MISSION FAILED - VESSEL LOST"
        type_text "CREW CASUALTIES: $((RANDOM % 50 + 50))%"
    elif [ $oxygen_level -le 0 ]; then
        type_text "MISSION FAILED - CREW SUFFOCATED"
    elif [ $battery_level -le 0 ]; then
        type_text "MISSION FAILED - ALL POWER LOST"
    elif [ $hull_integrity -le 0 ]; then
        type_text "MISSION FAILED - HULL BREACH"
        type_text "VESSEL LOST WITH ALL HANDS"
    elif [ $mission_complete -eq 1 ]; then
        type_text "MISSION SUCCESSFUL"
        type_text "RETURNING TO BASE"
        echo "Final Statistics:"
        echo "- Time Remaining: $time_remaining"
        echo "- Hull Integrity: $hull_integrity%"
        local destroyed=0
        for ((i=0; i<enemy_count; i++)); do
            [ ${enemy_alive[$i]} -eq 0 ] && destroyed=$((destroyed + 1))
        done
        echo "- Enemy Vessels Destroyed: $destroyed"
    fi
    
    sleep 3
}

function calculate_mission_risk() {
    local phase=$1
    local fuel=$2
    local oxygen=$3
    local power=$4
    local weather=$5
    local guidance=$6
    
    # Base risk calculation
    local risk=0
    
    # Phase-specific risks
    case $phase in
        "pre-launch")
            case $weather in
                "storm approaching") risk=$((risk + 40));;
                "high winds") risk=$((risk + 30));;
                "lightning warning") risk=$((risk + 50));;
                "overcast") risk=$((risk + 10));;
                *) risk=$((risk + 0));;
            esac
            [ $fuel -lt 90 ] && risk=$((risk + 20))
            [ "$guidance" != "nominal" ] && risk=$((risk + 30))
            ;;
        "launch")
            [ $fuel -lt 80 ] && risk=$((risk + 40))
            [ $power -lt 80 ] && risk=$((risk + 30))
            [ "$guidance" != "nominal" ] && risk=$((risk + 50))
            ;;
        "orbit")
            [ $fuel -lt 60 ] && risk=$((risk + 30))
            [ $oxygen -lt 80 ] && risk=$((risk + 40))
            [ $power -lt 70 ] && risk=$((risk + 30))
            ;;
        "transit"|"reentry")
            [ $fuel -lt 50 ] && risk=$((risk + 50))
            [ $oxygen -lt 70 ] && risk=$((risk + 60))
            [ $power -lt 60 ] && risk=$((risk + 40))
            ;;
    esac
    
    echo $risk
}

function ai_recommend_action() {
    local phase=$1
    local risk=$2
    local systems_status="$3"
    
    if [ $risk -gt 70 ]; then
        echo "RECOMMEND MISSION ABORT - RISK LEVEL CRITICAL"
        return
    fi
    
    case $phase in
        "pre-launch")
            if [ $risk -gt 40 ]; then
                echo "RECOMMEND HOLD LAUNCH - CONDITIONS SUBOPTIMAL"
            else
                echo "LAUNCH CONDITIONS ACCEPTABLE - PROCEED WITH CHECKLIST"
            fi
            ;;
        "launch")
            if [ $risk -gt 50 ]; then
                echo "CAUTION: CONSIDER MISSION ABORT"
            else
                echo "CONTINUE LAUNCH SEQUENCE - MONITOR TELEMETRY"
            fi
            ;;
        "orbit")
            if [ $risk -gt 30 ]; then
                echo "RECOMMEND ORBITAL ADJUSTMENT"
            else
                echo "MAINTAIN CURRENT TRAJECTORY"
            fi
            ;;
        "transit")
            if [ $risk -gt 40 ]; then
                echo "RECOMMEND COURSE CORRECTION"
            else
                echo "TRAJECTORY NOMINAL - CONTINUE MISSION"
            fi
            ;;
        "reentry")
            if [ $risk -gt 60 ]; then
                echo "RECOMMEND EMERGENCY PROCEDURES"
            else
                echo "PROCEED WITH STANDARD REENTRY"
            fi
            ;;
    esac
}

function predict_system_failure() {
    local system=$1
    local current_value=$2
    local trend_data="$3"
    
    # Analyze trend data for patterns
    local failure_probability=0
    
    case $system in
        "fuel")
            [ $current_value -lt 40 ] && failure_probability=$((failure_probability + 30))
            [[ $trend_data == *"decreasing"* ]] && failure_probability=$((failure_probability + 20))
            ;;
        "oxygen")
            [ $current_value -lt 60 ] && failure_probability=$((failure_probability + 40))
            [[ $trend_data == *"leak"* ]] && failure_probability=$((failure_probability + 30))
            ;;
        "power")
            [ $current_value -lt 50 ] && failure_probability=$((failure_probability + 35))
            [[ $trend_data == *"fluctuation"* ]] && failure_probability=$((failure_probability + 25))
            ;;
        "guidance")
            [[ $trend_data == *"drift"* ]] && failure_probability=$((failure_probability + 45))
            ;;
    esac
    
    echo $failure_probability
}

function nasa_control() {
    clear
    cat << "EOF"
    =========================================
    = NATIONAL AERONAUTICS AND SPACE ADMIN. =
    = MISSION CONTROL CENTER - HOUSTON, TX  =
    =========================================
    
    TERMINAL: MCC-H PRIMARY FLIGHT CONTROL
    SYSTEM: LAUNCH OPERATIONS AND TELEMETRY
    ACCESS LEVEL: FLIGHT DIRECTOR
    
    *** RESTRICTED ACCESS - AUTHORIZED PERSONNEL ONLY ***
EOF

    type_text "ACCESSING NASA MISSION CONTROL SYSTEMS..."
    sleep 1

    # Initialize mission parameters
    local mission_type=$((RANDOM % 3))  # 0=LEO, 1=Moon, 2=Mars
    local mission_phase="pre-launch"
    local countdown=60
    local fuel_level=100
    local oxygen_level=100
    local power_level=100
    local crew_status="ready"
    local comms_status="nominal"
    local weather_condition="clear"
    local system_checks=0
    local abort_status="none"
    local mission_success=0
    
    # Additional mission parameters
    local trajectory_status="nominal"
    local guidance_system="nominal"
    local booster_status="ready"
    local payload_status="secured"
    local launch_window_optimal=1
    local ground_control_ready=0
    local mission_elapsed_time=0
    local orbital_parameters="pending"
    local reentry_status="n/a"
    local landing_coordinates="pending"
    
    # Mission-specific parameters
    case $mission_type in
        0)  # LEO Mission
            mission_name="ORBITAL STATION RESUPPLY"
            target_altitude=400
            target_inclination=51.6
            payload_mass=2000
            mission_duration=180  # minutes
            ;;
        1)  # Lunar Mission
            mission_name="ARTEMIS LUNAR MISSION"
            target_altitude=384400
            target_inclination=28.5
            payload_mass=15000
            mission_duration=480  # minutes
            ;;
        2)  # Mars Mission
            mission_name="MARS SAMPLE RETURN"
            target_altitude=225000000
            target_inclination=25.0
            payload_mass=3000
            mission_duration=720  # minutes
            ;;
    esac

    function show_mission_status() {
        clear
        echo "NASA MISSION CONTROL - $mission_name"
        echo "=================================="
        echo "MISSION PHASE: $mission_phase"
        echo "MET: T+${mission_elapsed_time}m"
        [ "$mission_phase" == "pre-launch" ] && echo "COUNTDOWN: T-${countdown}"
        echo
        
        echo "PRIMARY SYSTEMS:"
        echo "- Propulsion: ${fuel_level}%"
        echo "- Life Support: ${oxygen_level}%"
        echo "- Power: ${power_level}%"
        echo "- Guidance: $guidance_system"
        echo "- Communications: $comms_status"
        echo
        
        echo "FLIGHT STATUS:"
        echo "- Trajectory: $trajectory_status"
        echo "- Orbital Parameters: $orbital_parameters"
        echo "- Crew Status: $crew_status"
        echo "- Weather: $weather_condition"
        [ "$mission_phase" == "reentry" ] && echo "- Landing Coordinates: $landing_coordinates"
        echo
        
        echo "MISSION CHECKS: $system_checks/10"
        echo
        echo "AI MISSION CONTROL ASSISTANT:"
        local current_risk=$(calculate_mission_risk "$mission_phase" $fuel_level $oxygen_level $power_level "$weather_condition" "$guidance_system")
        echo "Current Risk Assessment: ${current_risk}%"
        ai_recommend_action "$mission_phase" $current_risk "$system_status"
        
        # Show predictive warnings
        for system in "fuel" "oxygen" "power" "guidance"; do
            local value
            local trend=""
            case $system in
                "fuel") value=$fuel_level; trend="$fuel_trend";;
                "oxygen") value=$oxygen_level; trend="$oxygen_trend";;
                "power") value=$power_level; trend="$power_trend";;
                "guidance") value=0; trend="$guidance_trend";;
            esac
            
            local failure_prob=$(predict_system_failure "$system" $value "$trend")
            if [ $failure_prob -gt 60 ]; then
                echo "WARNING: $system system showing high failure probability (${failure_prob}%)"
            elif [ $failure_prob -gt 30 ]; then
                echo "CAUTION: $system system requires attention (${failure_prob}%)"
            fi
        done
    }

    function perform_system_check() {
        local system=$1
        type_text "CHECKING $system SYSTEMS..."
        sleep 1
        
        local check_result=$((RANDOM % 10))
        if [ $check_result -gt 7 ]; then
            type_text "WARNING: ANOMALY DETECTED IN $system"
            return 1
        else
            type_text "$system CHECK PASSED"
            return 0
        fi
    }

    function calculate_trajectory() {
        local current_phase=$1
        local fuel=$2
        local guidance=$3
        
        if [ "$guidance" != "nominal" ]; then
            trajectory_status="error"
            return 1
        fi
        
        if [ $fuel -lt 50 ]; then
            trajectory_status="critical"
            return 1
        fi
        
        case $current_phase in
            "launch")
                if [ $fuel -gt 80 ]; then
                    trajectory_status="optimal"
                else
                    trajectory_status="suboptimal"
                fi
                ;;
            "orbit")
                if [ $fuel -gt 60 ]; then
                    trajectory_status="stable"
                else
                    trajectory_status="unstable"
                fi
                ;;
            "transit")
                if [ $fuel -gt 70 ]; then
                    trajectory_status="on course"
                else
                    trajectory_status="deviation detected"
                fi
                ;;
        esac
        return 0
    }

    while [ $countdown -gt 0 ] && [ "$abort_status" == "none" ]; do
        show_mission_status
        
        echo
        echo "COMMANDS:"
        case $mission_phase in
            "pre-launch")
                echo "1. Perform System Check (S)"
                echo "2. Monitor Weather (W)"
                echo "3. Check Launch Window (L)"
                echo "4. Review Flight Plan (F)"
                echo "5. Ground Control Status (G)"
                echo "6. Begin Launch Sequence (B)"
                echo "7. Emergency Abort (A)"
                echo "R. Return to Main Menu"
                echo "Q. Quit WOPR System"
                ;;
            "launch")
                echo "1. Monitor Telemetry (T)"
                echo "2. Adjust Trajectory (J)"
                echo "3. Check Booster Status (B)"
                echo "4. Emergency Abort (A)"
                echo "R. Return to Main Menu"
                echo "Q. Quit WOPR System"
                ;;
            "orbit")
                echo "1. Orbital Maneuvers (M)"
                echo "2. Check Systems (S)"
                echo "3. Communicate with Crew (C)"
                echo "4. Adjust Power (P)"
                echo "R. Return to Main Menu"
                echo "Q. Quit WOPR System"
                ;;
            "transit")
                echo "1. Course Correction (C)"
                echo "2. Check Life Support (L)"
                echo "3. Monitor Radiation (R)"
                echo "4. Adjust Systems (S)"
                echo "R. Return to Main Menu"
                echo "Q. Quit WOPR System"
                ;;
            "reentry")
                echo "1. Monitor Heat Shield (H)"
                echo "2. Calculate Landing (L)"
                echo "3. Deploy Chutes (C)"
                echo "4. Emergency Procedures (E)"
                echo "R. Return to Main Menu"
                echo "Q. Quit WOPR System"
                ;;
        esac
        
        read -p "Enter command: " cmd
        
        case $mission_phase in
            "pre-launch")
                case $cmd in
                    [Ss])
                        if [ $system_checks -lt 10 ]; then
                            local systems=("PROPULSION" "LIFE_SUPPORT" "GUIDANCE" "COMMUNICATIONS" "PAYLOAD")
                            local checked=0
                            
                            # AI pre-check analysis
                            type_text "AI ASSISTANT: PERFORMING PRE-CHECK ANALYSIS"
                            local critical_systems=()
                            for sys in "${systems[@]}"; do
                                local failure_prob=$(predict_system_failure "$sys" 100 "pre-check")
                                if [ $failure_prob -gt 40 ]; then
                                    critical_systems+=("$sys")
                                fi
                            done
                            
                            if [ ${#critical_systems[@]} -gt 0 ]; then
                                echo "RECOMMENDED PRIORITY CHECKS:"
                                for sys in "${critical_systems[@]}"; do
                                    echo "- $sys (High Risk)"
                                done
                            fi
                            
                            # Perform checks with AI monitoring
                            for sys in "${systems[@]}"; do
                                if perform_system_check "$sys"; then
                                    checked=$((checked + 1))
                                else
                                    # AI suggests recovery actions
                                    type_text "AI ASSISTANT: ANALYZING FAILURE MODE"
                                    case $sys in
                                        "PROPULSION")
                                            type_text "RECOMMENDED ACTION: INITIATE FUEL SYSTEM PURGE"
                                            type_text "ALTERNATIVE: SWITCH TO BACKUP PUMP"
                                            ;;
                                        "LIFE_SUPPORT")
                                            type_text "RECOMMENDED ACTION: ACTIVATE REDUNDANT SYSTEMS"
                                            type_text "ALTERNATIVE: REDUCE SYSTEM LOAD"
                                            ;;
                                        "GUIDANCE")
                                            type_text "RECOMMENDED ACTION: RECALIBRATE IMU"
                                            type_text "ALTERNATIVE: SWITCH TO BACKUP GUIDANCE"
                                            ;;
                                        "COMMUNICATIONS")
                                            type_text "RECOMMENDED ACTION: SWITCH FREQUENCIES"
                                            type_text "ALTERNATIVE: DEPLOY BACKUP ANTENNA"
                                            ;;
                                        "PAYLOAD")
                                            type_text "RECOMMENDED ACTION: VERIFY PAYLOAD LOCKS"
                                            type_text "ALTERNATIVE: ADJUST MOUNTING TENSION"
                                            ;;
                                    esac
                                fi
                            done
                            system_checks=$((system_checks + checked))
                        else
                            type_text "ALL SYSTEM CHECKS COMPLETE"
                        fi
                        ;;
                    [Ww])
                        type_text "CHECKING WEATHER CONDITIONS..."
                        case $((RANDOM % 5)) in
                            0) weather_condition="storm approaching" ;;
                            1) weather_condition="high winds" ;;
                            2) weather_condition="clear" ;;
                            3) weather_condition="overcast" ;;
                            4) weather_condition="lightning warning" ;;
                        esac
                        type_text "WEATHER STATUS: $weather_condition"
                        ;;
                    [Ll])
                        type_text "CHECKING LAUNCH WINDOW..."
                        calculate_trajectory "launch" $fuel_level "$guidance_system"
                        type_text "LAUNCH WINDOW STATUS: $trajectory_status"
                        ;;
                    [Ff])
                        type_text "REVIEWING FLIGHT PLAN..."
                        sleep 2
                        ;;
                    [Gg])
                        type_text "GROUND CONTROL STATUS..."
                        ground_control_ready=1
                        ;;
                    [Bb])
                        type_text "INITIATING LAUNCH SEQUENCE..."
                        play_alert
                        for i in {10..1}; do
                            echo "T-$i"
                            play_beep
                            sleep 1
                        done
                        
                        if [ $fuel_level -gt 80 ] && [ $power_level -gt 80 ] && [ $oxygen_level -gt 80 ]; then
                            type_text "LIFTOFF - WE HAVE LIFTOFF"
                            mission_success=1
                            break
                        else
                            type_text "LAUNCH ABORT - SYSTEM PARAMETERS OUT OF RANGE"
                            abort_status="technical"
                        fi
                        ;;
                    [Aa])
                        type_text "INITIATING EMERGENCY ABORT..."
                        play_alert
                        abort_status="manual"
                        break
                        ;;
                    [Rr])
                        type_text "RETURNING TO MAIN MENU..."
                        return
                        ;;
                    [Qq])
                        type_text "DISCONNECTING FROM WOPR SYSTEM..."
                        sleep 1
                        exit 0
                        ;;
                esac
                ;;
            "launch")
                case $cmd in
                    [Tt])
                        type_text "MONITORING TELEMETRY..."
                        calculate_trajectory "launch" $fuel_level "$guidance_system"
                        type_text "TRAJECTORY STATUS: $trajectory_status"
                        ;;
                    [Jj])
                        type_text "ADJUSTING TRAJECTORY..."
                        calculate_trajectory "launch" $fuel_level "$guidance_system"
                        type_text "TRAJECTORY STATUS: $trajectory_status"
                        ;;
                    [Bb])
                        type_text "CHECKING BOOSTER STATUS..."
                        calculate_trajectory "launch" $fuel_level "$guidance_system"
                        type_text "BOOSTER STATUS: $booster_status"
                        ;;
                    [Aa])
                        type_text "INITIATING EMERGENCY ABORT..."
                        play_alert
                        abort_status="manual"
                        break
                        ;;
                    [Rr])
                        type_text "RETURNING TO MAIN MENU..."
                        return
                        ;;
                    [Qq])
                        type_text "DISCONNECTING FROM WOPR SYSTEM..."
                        sleep 1
                        exit 0
                        ;;
                esac
                ;;
            "orbit")
                case $cmd in
                    [Mm])
                        type_text "ORBITAL MANEUVERS..."
                        calculate_trajectory "orbit" $fuel_level "$guidance_system"
                        type_text "TRAJECTORY STATUS: $trajectory_status"
                        ;;
                    [Ss])
                        type_text "CHECKING SYSTEMS..."
                        calculate_trajectory "orbit" $fuel_level "$guidance_system"
                        type_text "SYSTEM STATUS: $trajectory_status"
                        ;;
                    [Cc])
                        type_text "COMMUNICATING WITH CREW..."
                        sleep 2
                        ;;
                    [Pp])
                        echo "POWER SYSTEM CONTROL:"
                        echo "1. Increase Power"
                        echo "2. Decrease Power"
                        echo "3. Run Diagnostics"
                        read -p "Select option: " power_cmd
                        case $power_cmd in
                            1) 
                                power_level=$((power_level + 10))
                                [ $power_level -gt 100 ] && power_level=100
                                type_text "POWER INCREASED TO ${power_level}%"
                                ;;
                            2)
                                power_level=$((power_level - 10))
                                [ $power_level -lt 0 ] && power_level=0
                                type_text "POWER DECREASED TO ${power_level}%"
                                ;;
                            3)
                                type_text "RUNNING POWER DIAGNOSTICS..."
                                sleep 2
                                if [ $((RANDOM % 10)) -gt 7 ]; then
                                    type_text "ANOMALY DETECTED IN POWER GRID"
                                    power_level=$((power_level - 20))
                                else
                                    type_text "POWER SYSTEMS NOMINAL"
                                fi
                                ;;
                        esac
                        ;;
                    [Rr])
                        type_text "RETURNING TO MAIN MENU..."
                        return
                        ;;
                    [Qq])
                        type_text "DISCONNECTING FROM WOPR SYSTEM..."
                        sleep 1
                        exit 0
                        ;;
                esac
                ;;
            "transit")
                case $cmd in
                    [Cc])
                        type_text "COURSE CORRECTION..."
                        calculate_trajectory "transit" $fuel_level "$guidance_system"
                        type_text "TRAJECTORY STATUS: $trajectory_status"
                        ;;
                    [Ll])
                        type_text "CHECKING LIFE SUPPORT..."
                        calculate_trajectory "transit" $fuel_level "$guidance_system"
                        type_text "LIFE SUPPORT STATUS: $trajectory_status"
                        ;;
                    [Rr])
                        type_text "MONITORING RADIATION..."
                        calculate_trajectory "transit" $fuel_level "$guidance_system"
                        type_text "RADIATION LEVEL: $trajectory_status"
                        ;;
                    [Ss])
                        type_text "SYSTEM ADJUSTMENTS..."
                        calculate_trajectory "transit" $fuel_level "$guidance_system"
                        type_text "SYSTEM STATUS: $trajectory_status"
                        ;;
                    [Rr])
                        type_text "RETURNING TO MAIN MENU..."
                        return
                        ;;
                    [Qq])
                        type_text "DISCONNECTING FROM WOPR SYSTEM..."
                        sleep 1
                        exit 0
                        ;;
                esac
                ;;
            "reentry")
                case $cmd in
                    [Hh])
                        type_text "MONITORING HEAT SHIELD..."
                        calculate_trajectory "reentry" $fuel_level "$guidance_system"
                        type_text "HEAT SHIELD STATUS: $trajectory_status"
                        ;;
                    [Ll])
                        type_text "CALCULATING LANDING COORDINATES..."
                        calculate_trajectory "reentry" $fuel_level "$guidance_system"
                        type_text "LANDING COORDINATES: $landing_coordinates"
                        ;;
                    [Cc])
                        type_text "DEPLOYING CHUTES..."
                        calculate_trajectory "reentry" $fuel_level "$guidance_system"
                        type_text "CHUTES DEPLOYED"
                        ;;
                    [Ee])
                        type_text "EMERGENCY PROCEDURES..."
                        calculate_trajectory "reentry" $fuel_level "$guidance_system"
                        type_text "REENTRY SUCCESSFUL"
                        mission_success=1
                        break
                        ;;
                    [Rr])
                        type_text "RETURNING TO MAIN MENU..."
                        return
                        ;;
                    [Qq])
                        type_text "DISCONNECTING FROM WOPR SYSTEM..."
                        sleep 1
                        exit 0
                        ;;
                esac
                ;;
        esac

        # Phase-specific events and checks
        case $mission_phase in
            "pre-launch")
                if [ $system_checks -eq 10 ] && [ "$weather_condition" == "clear" ] && [ $ground_control_ready -eq 1 ]; then
                    type_text "ALL SYSTEMS GO FOR LAUNCH"
                    mission_phase="launch"
                fi
                ;;
            "launch")
                if [ "$trajectory_status" == "optimal" ] && [ $fuel_level -gt 70 ]; then
                    type_text "ACHIEVING ORBITAL VELOCITY"
                    mission_phase="orbit"
                fi
                ;;
            "orbit")
                if [ $fuel_level -lt 50 ]; then
                    type_text "LOW FUEL - ORBITAL MANEUVER REQUIRED"
                    mission_phase="transit"
                fi
                ;;
            "transit")
                if [ $fuel_level -lt 70 ]; then
                    type_text "LOW FUEL - COURSE CORRECTION REQUIRED"
                    mission_phase="transit"
                fi
                ;;
            "reentry")
                if [ $fuel_level -lt 50 ]; then
                    type_text "LOW FUEL - REENTRY MANEUVER REQUIRED"
                    mission_phase="reentry"
                fi
                ;;
        esac

        # Random events based on mission phase
        if [ $((RANDOM % 10)) -eq 0 ]; then
            case $mission_phase in
                "launch")
                    case $((RANDOM % 3)) in
                        0)
                            type_text "WARNING: UNEXPECTED VIBRATION DETECTED"
                            trajectory_status="unstable"
                            ;;
                        1)
                            type_text "ALERT: BOOSTER TEMPERATURE HIGH"
                            fuel_level=$((fuel_level - 5))
                            ;;
                        2)
                            type_text "CAUTION: MINOR TRAJECTORY DEVIATION"
                            guidance_system="correction needed"
                            ;;
                    esac
                    ;;
                "orbit")
                    case $((RANDOM % 3)) in
                        0)
                            type_text "WARNING: ORBITAL MANEUVER REQUIRED"
                            mission_phase="transit"
                            ;;
                        1)
                            type_text "ALERT: ORBITAL DEVIATION DETECTED"
                            orbital_parameters="correction needed"
                            ;;
                        2)
                            type_text "CAUTION: MINOR ORBITAL DEVIATION"
                            orbital_parameters="stable"
                            ;;
                    esac
                    ;;
                "transit")
                    case $((RANDOM % 3)) in
                        0)
                            type_text "WARNING: COURSE CORRECTION REQUIRED"
                            mission_phase="transit"
                            ;;
                        1)
                            type_text "ALERT: HIGH RADIATION DETECTED"
                            radiation_level="high"
                            ;;
                        2)
                            type_text "CAUTION: MINOR COURSE DEVIATION"
                            orbital_parameters="stable"
                            ;;
                    esac
                    ;;
                "reentry")
                    case $((RANDOM % 3)) in
                        0)
                            type_text "WARNING: HEAT SHIELD REQUIRED"
                            mission_phase="reentry"
                            ;;
                        1)
                            type_text "ALERT: LANDING COORDINATES CALCULATION"
                            mission_phase="reentry"
                            ;;
                        2)
                            type_text "CAUTION: MINOR LANDING DEVIATION"
                            orbital_parameters="stable"
                            ;;
                    esac
                    ;;
            esac
        fi

        # Update mission time and resources
        mission_elapsed_time=$((mission_elapsed_time + 1))
        [ "$mission_phase" == "pre-launch" ] && countdown=$((countdown - 1))
        
        # Resource consumption
        case $mission_phase in
            "orbit"|"transit")
                oxygen_level=$((oxygen_level - 1))
                power_level=$((power_level - 1))
                ;;
        esac

        sleep 1
    done

    # Mission end status
    clear
    if [ $mission_success -eq 1 ]; then
        type_text "MISSION LAUNCH SUCCESSFUL"
        type_text "VEHICLE HAS CLEARED THE TOWER"
        echo
        echo "Final Statistics:"
        echo "- Fuel Level: $fuel_level%"
        echo "- Power Level: $power_level%"
        echo "- Oxygen Level: $oxygen_level%"
        echo "- Launch Weather: $weather_condition"
    else
        type_text "MISSION ABORTED"
        case $abort_status in
            "manual") type_text "REASON: MANUAL ABORT COMMAND" ;;
            "technical") type_text "REASON: CRITICAL SYSTEM FAILURE" ;;
            *) type_text "REASON: COUNTDOWN EXPIRED" ;;
        esac
    fi
    
    sleep 3
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
    
    while [ $game_over -eq 0 ]; do
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
                        type_text "INVALID MOVE. ENTER A NUMBER 1-9."
                        continue
                    fi
                    
                    position=$((position - 1))
                    if [[ ${board[$position]} == "X" || ${board[$position]} == "O" ]]; then
                        type_text "POSITION ALREADY TAKEN. TRY AGAIN."
                        continue
                    fi
                    
                    board[$position]="X"
                    play_beep
                    ;;
            esac
        else
            type_text "WOPR ANALYZING POSITION..."
            sleep 1
            local ai_move=$(get_ai_move "${board[@]}")
            board[$ai_move]="O"
            type_text "WOPR SELECTS POSITION $((ai_move + 1))"
            play_alert
        fi
        
        moves=$((moves + 1))
        winner=$(check_winner "${board[@]}")
        
        if [[ -n "$winner" ]]; then
            draw_board "${board[@]}"
            if [ "$winner" == "X" ]; then
                type_text "CONGRATULATIONS - YOU WIN"
                type_text "UPDATING GAME THEORY DATABASE..."
            else
                type_text "GAME OVER - WOPR WINS"
                type_text "STRATEGIC SUPERIORITY DEMONSTRATED"
            fi
            game_over=1
        elif [ $moves -eq 9 ]; then
            draw_board "${board[@]}"
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
