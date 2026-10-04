# Racecar Evolution
Genetic evolution algorithm to train 2D race cars to complete a race track in Godot 4.

<video src="demo.mp4" autoplay loop muted playsinline width="50%" ></video>

## How it works

### Neural Network
Each car is given **7** inputs:
- 5 raycasts, pointing from left to right
- Current throttle
- Current direction.

Inputs are passed through one layer of weights and through a `tanh` activation function to output throttle and direction. (two separate weight layers exist for throttle and direction)

### Genetic/Fitness
Cars die upon crashing or making no progress for 3 seconds. When all cars die, or when the timer hits 0 and the user opts to cut the round short, the most fit car is chosen.
Fitness is determined by (in order):
1. Passing the starting line
2. Getting to the furthest checkpoint
3. Completing a lap
4. Completing a lap in the least amount of time

The next generation consists of the chosen car, as well as mutated versions of that car.

Each weight has a `mutation_rate` chance of being mutated. If it gets mutated, the weight gets modified by a random number between `-mutation_magnitude` and `mutation_magnitude`.

## Customization
Some constants are designed to be modified freely.
**In world.gd:**
1. `gen_size` Controls the number of cars in each generation
2. `mutation_rate` Controls the chance (decimal percentage) of mutation for each weight
3. `mutation_magnitude` Controls the highest magnitude in change of one weight in one mutation

**In car.gd:**
1. `SPEED` Controls the base speed of the car
2. `friction` Controls the velocity decay of the car
3. `max_throttle` Controls the maximum SPEED multiplier
4. `direction_steps` Controls the direction change multiplier

# Usage
Play with it online at:

Or clone the repository and open with Godot 4.7.1

## Controls
* Camera Pan: WASD or Arrow keys
* Camera Zoom: Mouse scroll
* Simulation Speed: Adjust the dropdown to set speed (0.25x to 16x)
* Generations: Click the top-left button to move to next generation, or check the `auto` box.
* Reset: Click the top-right `Extinction Event` button to reset generations and genetics.

# Next Up
* Adding more layers to the neural network
* Commenting and style
