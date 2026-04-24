# `Knob` Class Documentation

[cite_start]**Extends:** `Node2D` [cite: 1]

A custom 2D component representing a multi-state rotary knob. [cite_start]It handles discrete rotation states, looping, and smooth animation for its inner sprite[cite: 1].

## Scene Requirements
* [cite_start]The node requires a child `Sprite2D` named `inner`[cite: 1]. The script specifically rotates this inner sprite.

## Signals
* **`state_changed(new_state: int)`**
  [cite_start]Emitted whenever the knob successfully changes to a new state[cite: 1].

## Constants
* [cite_start]**`STATES`** (`Array[float]`): Defines the 6 discrete rotation angles in degrees: `[0.0, 36.0, 72.0, 108.0, 144.0, 180.0]`[cite: 1].

## Exported Properties
* [cite_start]**`current_state`** (`int`): Sets the starting state in the inspector (range: `0` to `5`)[cite: 1].
* **`anim_duration`** (`float`): The length of the rotation animation in seconds. [cite_start]Default is `0.3`[cite: 1].
* [cite_start]**`custom_curve`** (`Curve`): An optional curve to visually control the easing/speed of the animation[cite: 2].
* **`fallback_transition`** (`Tween.TransitionType`): The built-in tween easing used if no `custom_curve` is assigned. [cite_start]Default is `TRANS_SINE`[cite: 2].

## Public Methods

* **`set_state(new_state: int, animate: bool = true) -> void`**
  [cite_start]Forces the knob to a specific state[cite: 2]. [cite_start]The state safely loops using modulo if an out-of-bounds number is passed[cite: 2]. [cite_start]Optionally animates the transition[cite: 2].

* **`step_forward() -> void`**
  [cite_start]Increases the current state by 1[cite: 2]. [cite_start]Automatically loops back to state `0` if it exceeds the maximum state[cite: 2].

* **`step_backward() -> void`**
  [cite_start]Decreases the current state by 1[cite: 2]. [cite_start]Automatically loops to the maximum state if it goes below `0`[cite: 2, 3].
