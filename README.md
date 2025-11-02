
# Stellar Fang

## About The Project

Stellar Fang is a terminal-based game that simulates a high-stakes scenario aboard a spaceship (the Stellar Fang). The player assumes the role of the astronaut on the V.S.S. Stellar Fang after a critical system failure. The game is a race against time, challenging the player to diagnose and solve the problem using Bash commands in a simulated terminal before a catastrophic failure destroys the ship.

## Gameplay

### Objective

Your primary goal is to identify the damaged ship component, find the necessary repair tools, and execute the repair sequence to save the V.S.S. Stellar Fang. The mission is time-sensitive, and failure to act quickly will result in the loss of the ship.

### How to Play

The game unfolds through a series of logical steps that require you to use your knowledge of terminal commands :

1. **Diagnosis:** Begin by exploring the ship's file system using `ls` and `cd`. 
There are in total 4 `status.txt` files in different system directories. Find and read them to find the one reporting a critical error.
2. **Investigation:** The error message will tell you which components of the broken system need to be replaced. These components are located in the ship's archives. You have to follow the EMERGENCY_REPAIR_GUIDE to repair the parts.
3. **The Puzzle:** Oh no... a virus is preventing you from repairing the spaceship (it's hiding repair_protocol.sh). Identify it, then kill it! 
Once the virus is killed, the repair script should appear.
4. **Repair the ship:** You will find that the repair script, `repairprotocol.sh`, is locked due to file permissions (`chmod 000`). Unlock it.
5. **Resolution:** Execute the script (`./repairprotocol.sh`) to repair the ship and win the game.

### Outcomes

There are three possible outcomes based on your actions :

* **Ideal Win:** You successfully repair the ship before the timer runs out.
* **Alternate Outcome:** If you feel you can't fix the ship in time, you can find the Safety Hatches and initiate a bail-out sequence, saving yourself but sacrificing the ship.
* **Loss:** The timer expires before you can save the ship or yourself.


## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

This game is designed to run in a Unix-like shell environment (like Linux or macOS) that supports Bash scripting.

### Installation

1. Clone the repo

```sh
git clone https://github.com/KhadijaaaaaB/stellar-fang.git
```

2. Navigate to the project directory

```sh
cd StellarFang
```

3. Make the main script executable

```sh
chmod +x stellarfang.sh
```


## Usage

Run the game by executing the main script. You can specify a difficulty level using the `--level` argument.

```sh
./stellarfang.sh --level [easy|hard]
```

* **Easy Mode:** 30-minute timer.
* **Normal Mode:** 20-minute timer. (default)
* **Hard Mode:** 10-minute timer.
The player can check the timer any time by typing `time`

To see a list of authorized commands and a brief explanation of the game's objective, type `help`.

## Project Structure

The project is organized into a modular structure for clarity and manageability :


| File | Description |
| :-- | :-- |
| `stellarfang.sh` | The main executable script. It contains the game loop, parses command-line arguments, and manages the overall game state. |
| `setup.sh` | Handles the creation of the game world. It randomly selects a damaged part and builds the directory structure and clue files. |
| `timer.sh` | Manages the countdown timer based on the selected difficulty. It creates a `TIMEUPFILE` when the timer expires. |
| `cleanup.sh` | Resets the environment after the game ends. It kills the timer process and removes the game directory. |
| `docs/help.txt` | A text file containing a list of allowed commands and a brief overview of the game's objective. |

