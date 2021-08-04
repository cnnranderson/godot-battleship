extends Node

"""
Events Singleton -- used to define events for the entire game.

This allows us to bind events anywhere across the entities used
without having to create complex hierarchies within nodes when
connecting signal subscribers.
"""

signal game_won

# Ship Operations
signal ship_picked_up(ship)
signal ship_placed
