# `Knob` Class Documentation

**Extends:** `Node2D` 

A custom 2D component representing a multi-state rotary knob. It handles discrete rotation states, looping, and smooth animation for its inner sprite.

## Scene Requirements
* The node requires a child `Sprite2D` named `inner`. The script specifically rotates this inner sprite.

## Signals
* **`state_changed(new_state: int)`**
  Emitted whenever the knob successfully changes to a new state.

## Constants
* **`STATES`** (`Array[float]`): Defines the 6 discrete rotation angles in degrees: `[0.0, 36.0, 72.0, 108.0, 144.0, 180.0]`.

## Exported Properties
* **`current_state`** (`int`): Sets the starting state in the inspector (range: `0` to `5`).
* **`anim_duration`** (`float`): The length of the rotation animation in seconds. Default is `0.3`.
* **`custom_curve`** (`Curve`): An optional curve to visually control the easing/speed of the animation.
* **`fallback_transition`** (`Tween.TransitionType`): The built-in tween easing used if no `custom_curve` is assigned. Default is `TRANS_SINE`.

## Public Methods

* **`set_state(new_state: int, animate: bool = true) -> void`**
  Forces the knob to a specific state. The state safely loops using modulo if an out-of-bounds number is passed. Optionally animates the transition.

* **`step_forward() -> void`**
  Increases the current state by 1. Automatically loops back to state `0` if it exceeds the maximum state.

* **`step_backward() -> void`**
  Decreases the current state by 1. Automatically loops to the maximum state if it goes below `0`.
