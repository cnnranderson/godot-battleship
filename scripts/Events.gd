extends Node

"""
Events Singleton -- used to define events for the entire game.

This allows us to bind events anywhere across the entities used
without having to create complex hierarchies within nodes when
connecting signal subscribers.
"""

# Lobby signals
signal new_matches

# Session signals
signal player_joined
signal player_attacked
signal player_disconnected

# Game State signals
signal game_won
signal ships_locked
signal enemy_ships_locked
signal turn_state_changed(prev_state, state)
signal enemy_attacked(pos)

# Ship signals
signal ship_picked_up(ship)
signal ship_placed(ship)
