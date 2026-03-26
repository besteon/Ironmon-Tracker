#!/usr/bin/env python3

# Usage:
# To use this script, git "check out" the repo for the desired game's code base.
# Pass the root directory as an argument to this script.
# Optionally, you can also provide the output path to which the generated data will be written.
#
# Example script usage:
#
# python ironmon_tracker/Debug/parse-trainer.py --frlg-path /path/to/pokefirered/ -o FRLGTrainerRouteData.lua
# python ironmon_tracker/Debug/parse-trainer.py --emerald-path /path/to/pokeemerald/ -o EmeraldTrainerRouteData.lua
# python ironmon_tracker/Debug/parse-trainer.py --ruby-path /path/to/pokeruby/ -o RSTrainerRouteData.lua
#
# Git Repos:
# - FireRed/LeafGreen:	https://github.com/pret/pokefirered/
# - Emerald:			https://github.com/pret/pokeemerald/
# - Ruby/Sapphire: 		https://github.com/pret/pokeruby/

import re
import sys
import json
import logging
from pathlib import Path
from argparse import ArgumentParser

log = None

def init_logging(log_level):
    formatter = logging.Formatter(fmt='%(levelname)s - %(filename)s:%(lineno)s - %(msg)s')
    handler = logging.StreamHandler()
    handler.setFormatter(formatter)
    handler.setLevel(log_level)

    logger = logging.getLogger(__name__)
    logger.setLevel(log_level)
    logger.addHandler(handler)

    logger.debug('Logging initialized')
    return logger

# Movement types that never leave their initial tile.
STATIONARY_TYPES = {
    "MOVEMENT_TYPE_NONE",
    "MOVEMENT_TYPE_LOOK_AROUND",
    "MOVEMENT_TYPE_FACE_UP",
    "MOVEMENT_TYPE_FACE_DOWN",
    "MOVEMENT_TYPE_FACE_LEFT",
    "MOVEMENT_TYPE_FACE_RIGHT",
    "MOVEMENT_TYPE_FACE_DOWN_AND_UP",
    "MOVEMENT_TYPE_FACE_LEFT_AND_RIGHT",
    "MOVEMENT_TYPE_FACE_UP_AND_LEFT",
    "MOVEMENT_TYPE_FACE_UP_AND_RIGHT",
    "MOVEMENT_TYPE_FACE_DOWN_AND_LEFT",
    "MOVEMENT_TYPE_FACE_DOWN_AND_RIGHT",
    "MOVEMENT_TYPE_FACE_DOWN_UP_AND_LEFT",
    "MOVEMENT_TYPE_FACE_DOWN_UP_AND_RIGHT",
    "MOVEMENT_TYPE_FACE_UP_LEFT_AND_RIGHT",
    "MOVEMENT_TYPE_FACE_DOWN_LEFT_AND_RIGHT",
    "MOVEMENT_TYPE_ROTATE_COUNTERCLOCKWISE",
    "MOVEMENT_TYPE_ROTATE_CLOCKWISE",
    "MOVEMENT_TYPE_WALK_IN_PLACE_DOWN",
    "MOVEMENT_TYPE_WALK_IN_PLACE_UP",
    "MOVEMENT_TYPE_WALK_IN_PLACE_LEFT",
    "MOVEMENT_TYPE_WALK_IN_PLACE_RIGHT",
    "MOVEMENT_TYPE_WALK_IN_PLACE_FAST_DOWN",
    "MOVEMENT_TYPE_WALK_IN_PLACE_FAST_UP",
    "MOVEMENT_TYPE_WALK_IN_PLACE_FAST_LEFT",
    "MOVEMENT_TYPE_WALK_IN_PLACE_FAST_RIGHT",
    "MOVEMENT_TYPE_JOG_IN_PLACE_DOWN",
    "MOVEMENT_TYPE_JOG_IN_PLACE_UP",
    "MOVEMENT_TYPE_JOG_IN_PLACE_LEFT",
    "MOVEMENT_TYPE_JOG_IN_PLACE_RIGHT",
    "MOVEMENT_TYPE_RAISE_HAND_AND_STOP",
    "MOVEMENT_TYPE_RAISE_HAND_AND_JUMP",
    "MOVEMENT_TYPE_RAISE_HAND_AND_SWIM",
    "MOVEMENT_TYPE_BERRY_TREE_GROWTH",
    "MOVEMENT_TYPE_INVISIBLE",
    "MOVEMENT_TYPE_BURIED",
    "MOVEMENT_TYPE_TREE_DISGUISE",
    "MOVEMENT_TYPE_MOUNTAIN_DISGUISE",
}

# Walk back-and-forth along a single axis.  The first direction in the name is
# the initial heading; the NPC walks from its origin to the range boundary in
# that direction, then reverses back to origin.  It never crosses past origin.
LINEAR_UP = {"MOVEMENT_TYPE_WALK_UP_AND_DOWN"}
LINEAR_DOWN = {"MOVEMENT_TYPE_WALK_DOWN_AND_UP"}
LINEAR_LEFT = {"MOVEMENT_TYPE_WALK_LEFT_AND_RIGHT"}
LINEAR_RIGHT = {"MOVEMENT_TYPE_WALK_RIGHT_AND_LEFT"}
LINEAR_VERTICAL_TYPES = LINEAR_UP | LINEAR_DOWN
LINEAR_HORIZONTAL_TYPES = LINEAR_LEFT | LINEAR_RIGHT

# Wander types prefer one axis but can step on the other within range.
WANDER_VERTICAL_TYPES = {
    "MOVEMENT_TYPE_WANDER_UP_AND_DOWN",
    "MOVEMENT_TYPE_WANDER_DOWN_AND_UP",
}

WANDER_HORIZONTAL_TYPES = {
    "MOVEMENT_TYPE_WANDER_LEFT_AND_RIGHT",
    "MOVEMENT_TYPE_WANDER_RIGHT_AND_LEFT",
}

# Full bounding box wander.
WANDER_BOX_TYPES = {
    "MOVEMENT_TYPE_WANDER_AROUND",
    "MOVEMENT_TYPE_WANDER_AROUND_SLOWER",
}

# WALK_SEQUENCE directions: each tuple is the 4 directions walked in order.
# (dx, dy) per cardinal: N=(0,-1), S=(0,1), W=(-1,0), E=(1,0)
_DIR = {"UP": (0, -1), "DOWN": (0, 1), "LEFT": (-1, 0), "RIGHT": (1, 0)}

def _parse_walk_sequence_dirs(name):
    """Extract the 4 direction keywords from a WALK_SEQUENCE movement type name."""
    # e.g. "MOVEMENT_TYPE_WALK_SEQUENCE_RIGHT_DOWN_LEFT_UP" -> [RIGHT, DOWN, LEFT, UP]
    suffix = name.replace("MOVEMENT_TYPE_WALK_SEQUENCE_", "")
    parts = suffix.split("_")
    return [_DIR[p] for p in parts]

# Pre-build the set of all WALK_SEQUENCE type names.
_WALK_SEQ_DIRS = ["UP", "DOWN", "LEFT", "RIGHT"]
WALK_SEQUENCE_TYPES = set()
for a in _WALK_SEQ_DIRS:
    for b in _WALK_SEQ_DIRS:
        for c in _WALK_SEQ_DIRS:
            for d in _WALK_SEQ_DIRS:
                name = f"MOVEMENT_TYPE_WALK_SEQUENCE_{a}_{b}_{c}_{d}"
                WALK_SEQUENCE_TYPES.add(name)


class Trainer:
    num = None
    x = None
    y = None
    range_x = None
    range_y = None
    movement_type = None
    script = None
    t_id = None

    def __init__(self, event):

        if "script" in event:
            self.script = event["script"]

        self.x = int(event["x"])
        self.y = int(event["y"])

        self.movement_type = event.get("movement_type", "MOVEMENT_TYPE_NONE")

        # ROM uses movement_range values as-is for the bounding box check.
        # For ranged movement types, range 0 is auto-bumped to 1 at spawn.
        self.range_x = int(event.get("movement_range_x", 0))
        self.range_y = int(event.get("movement_range_y", 0))

        is_ranged = (
            self.movement_type in WANDER_BOX_TYPES
            or self.movement_type in WANDER_VERTICAL_TYPES
            or self.movement_type in WANDER_HORIZONTAL_TYPES
            or self.movement_type in LINEAR_VERTICAL_TYPES
            or self.movement_type in LINEAR_HORIZONTAL_TYPES
            or self.movement_type in WALK_SEQUENCE_TYPES
        )
        if is_ranged:
            if self.range_x == 0:
                self.range_x = 1
            if self.range_y == 0:
                self.range_y = 1

    def __repr__(self):
        trainer_name = self.script.split("_")[-1]
        return f"{trainer_name}: ({self.x}, {self.y}) -> {self.t_id} ({self.num})"

    def get_tiles(self):
        """Return the set of (x, y) tiles this trainer can occupy."""
        mt = self.movement_type

        if mt in STATIONARY_TYPES:
            return [(self.x, self.y)]

        if mt in LINEAR_UP:
            # Walks from origin upward to range boundary, then back to origin.
            return [(self.x, y)
                    for y in range(self.y - self.range_y, self.y + 1)]

        if mt in LINEAR_DOWN:
            # Walks from origin downward to range boundary, then back to origin.
            return [(self.x, y)
                    for y in range(self.y, self.y + self.range_y + 1)]

        if mt in LINEAR_LEFT:
            # Walks from origin leftward to range boundary, then back to origin.
            return [(x, self.y)
                    for x in range(self.x - self.range_x, self.x + 1)]

        if mt in LINEAR_RIGHT:
            # Walks from origin rightward to range boundary, then back to origin.
            return [(x, self.y)
                    for x in range(self.x, self.x + self.range_x + 1)]

        if mt in WANDER_VERTICAL_TYPES:
            # Random vertical steps within full bounding box range.
            return [(self.x, y)
                    for y in range(self.y - self.range_y, self.y + self.range_y + 1)]

        if mt in WANDER_HORIZONTAL_TYPES:
            # Random horizontal steps within full bounding box range.
            return [(x, self.y)
                    for x in range(self.x - self.range_x, self.x + self.range_x + 1)]

        if mt in WALK_SEQUENCE_TYPES:
            return self._walk_sequence_tiles(mt)

        # WANDER_AROUND, WANDER_*_AND_*, COPY_PLAYER, FOLLOW_PLAYER, or unknown:
        # full bounding box is the safe approximation.
        return [(x, y)
                for x in range(self.x - self.range_x, self.x + self.range_x + 1)
                for y in range(self.y - self.range_y, self.y + self.range_y + 1)]

    def _walk_in_dir(self, sx, sy, dx, dy):
        """Walk from (sx, sy) in direction (dx, dy) until hitting the range boundary.
        Returns the list of tiles visited (excluding the start) and the final position."""
        tiles = []
        cx, cy = sx, sy
        while True:
            nx, ny = cx + dx, cy + dy
            if self.range_x != 0 and (nx < self.x - self.range_x or nx > self.x + self.range_x):
                break
            if self.range_y != 0 and (ny < self.y - self.range_y or ny > self.y + self.range_y):
                break
            cx, cy = nx, ny
            tiles.append((cx, cy))
        return tiles, cx, cy

    def _walk_sequence_tiles(self, mt):
        """Trace the rectangle-perimeter path for WALK_SEQUENCE movement types.

        The ROM walks 4 direction phases in order.  One phase has a skip
        condition: when the NPC returns to its initial coordinate on the
        movement axis of that phase, it jumps to the next phase instead of
        continuing to the range boundary.  All other phases walk to the range
        boundary.  Together the 4 phases trace the perimeter of a rectangle
        (which degenerates to an L when range is 0 on one axis).

        If d0/d1 share an axis: skip fires at phase 1 (return on that axis).
        If d0/d1 differ:       skip fires at phase 2 (return on d0's axis)."""
        dirs = _parse_walk_sequence_dirs(mt)
        d0, d1 = dirs[0], dirs[1]
        same_axis = (d0[0] != 0 and d1[0] != 0) or (d0[1] != 0 and d1[1] != 0)
        skip_idx = 1 if same_axis else 2

        tiles = {(self.x, self.y)}
        cx, cy = self.x, self.y

        for phase in range(4):
            dx, dy = dirs[phase]
            if phase == skip_idx:
                # Walk until returning to initial coord on this direction's axis.
                while True:
                    nx, ny = cx + dx, cy + dy
                    if self.range_x != 0 and (nx < self.x - self.range_x or nx > self.x + self.range_x):
                        break
                    if self.range_y != 0 and (ny < self.y - self.range_y or ny > self.y + self.range_y):
                        break
                    cx, cy = nx, ny
                    tiles.add((cx, cy))
                    if dx != 0 and cx == self.x:
                        break
                    if dy != 0 and cy == self.y:
                        break
            elif phase == 3:
                # Final phase: walk until back at start (ROM resets cycle there).
                while True:
                    nx, ny = cx + dx, cy + dy
                    if self.range_x != 0 and (nx < self.x - self.range_x or nx > self.x + self.range_x):
                        break
                    if self.range_y != 0 and (ny < self.y - self.range_y or ny > self.y + self.range_y):
                        break
                    cx, cy = nx, ny
                    tiles.add((cx, cy))
                    if cx == self.x and cy == self.y:
                        break
            else:
                # Walk to range boundary.
                leg, cx, cy = self._walk_in_dir(cx, cy, dx, dy)
                tiles.update(leg)

        return sorted(tiles)


def resolve_script_calls(script_lines):
    """Build a mapping from script labels to the trainer ID they (transitively) battle.

    Handles both direct trainerbattle_ commands and call/goto indirection."""
    re_label = re.compile(r"^(\S+)::\s*(?:@.*)?$")
    re_trainerbattle = re.compile(r"^\s+trainerbattle_\S+ (?P<encounter>[^,]+),")
    re_call = re.compile(r"^\s+(?:call|goto)\s+(\S+)")
    re_end = re.compile(r"^\s+(?:end|return)\s*$")

    # First pass: for each label, collect direct trainerbattle IDs and call/goto targets.
    label_battles = {}   # label -> trainer ID (direct)
    label_calls = {}     # label -> set of called labels

    curr_label = None
    for line in script_lines:
        label_match = re_label.match(line)
        if label_match:
            curr_label = label_match.group(1)
            continue

        if curr_label is None:
            continue

        battle_match = re_trainerbattle.match(line)
        if battle_match:
            trainer_id = battle_match.group("encounter")
            if curr_label not in label_battles:
                label_battles[curr_label] = trainer_id
            continue

        call_match = re_call.match(line)
        if call_match:
            target = call_match.group(1)
            label_calls.setdefault(curr_label, set()).add(target)
            continue

        if re_end.match(line):
            curr_label = None

    # Second pass: resolve call/goto chains (one level of indirection is sufficient
    # for all known patterns, but we'll do a small BFS to be safe).
    scripts = dict(label_battles)
    for label, targets in label_calls.items():
        if label in scripts:
            continue
        # BFS through call targets to find a trainerbattle.
        visited = set()
        queue = list(targets)
        while queue:
            target = queue.pop(0)
            if target in visited:
                continue
            visited.add(target)
            if target in label_battles:
                scripts[label] = label_battles[target]
                break
            if target in label_calls:
                queue.extend(label_calls[target])

    return scripts


def parse_map(area, scripts, trainer_ids, layout_ids):
    map_data = {}
    with open(f"{area}/map.json") as f:
        map_data = json.load(f)

    events = map_data.get("object_events", [])
    trainers = []
    for e in events:
        t = Trainer(e)
        if t.script in scripts:
            t.t_id = scripts[t.script]
            if t.t_id in trainer_ids:
                log.debug(f"Trainer {t.t_id} is #{trainer_ids[t.t_id]}")
                t.num = trainer_ids[t.t_id]
                trainers.append(t)
            else:
                log.warning(f"Unknown trainer constant: {t.t_id}")

    layout_id = layout_ids[map_data["layout"]]
    return layout_id, trainers

def parse_script(area, shared_script_files=None):
    script_lines = []
    with open(f"{area}/scripts.inc") as f:
        script_lines = f.read().split('\n')

    for path in (shared_script_files or []):
        with open(path) as f:
            script_lines += f.read().split('\n')

    return resolve_script_calls(script_lines)

def parse_header(header, rex):
    objects = {}
    lines = []
    with open(header) as f:
        lines = f.read().split('\n')

    for line in lines:
        match = rex.match(line)
        if match:
            objects[match.group(1)] = int(match.group(2))

    return objects

def parse_layouts_json(layouts_json_path):
    """Parse RSE-style layouts.json, returning {LAYOUT_NAME: index} mapping."""
    with open(layouts_json_path) as f:
        data = json.load(f)
    layout_ids = {}
    for i, layout in enumerate(data["layouts"]):
        layout_ids[layout["id"]] = i
    return layout_ids


def process_rom(code_root):
    """Process a single ROM tree and return {layout_id: [Trainer, ...]} map data."""
    trainer_constants = f"{code_root}/include/constants/opponents.h"
    re_trainer = re.compile(r"^#define\s+(TRAINER_\S+)\s+(\d+)\s*$")
    trainer_ids = parse_header(trainer_constants, re_trainer)

    # FRLG uses include/constants/layouts.h; RSE uses data/layouts/layouts.json.
    layouts_header = Path(f"{code_root}/include/constants/layouts.h")
    layouts_json = Path(f"{code_root}/data/layouts/layouts.json")
    if layouts_header.exists():
        re_layout = re.compile(r"^#define\s+(LAYOUT_\S+)\s+(\d+)\s*$")
        layout_ids = parse_header(str(layouts_header), re_layout)
    elif layouts_json.exists():
        layout_ids = parse_layouts_json(str(layouts_json))
    else:
        log.error(f"No layout constants found in {code_root}")
        return {}

    # FRLG has a shared trainers.inc; RSE keeps all scripts in per-map files.
    shared_scripts = []
    shared_trainers_inc = Path(f"{code_root}/data/scripts/trainers.inc")
    if shared_trainers_inc.exists():
        shared_scripts.append(str(shared_trainers_inc))

    map_data = {}
    maps_root = Path(f"{code_root}/data/maps")
    for m in maps_root.iterdir():
        if m.is_dir():
            scripts_inc = m / "scripts.inc"
            if not scripts_inc.exists():
                continue
            log.debug(f"Entering {m.name}")
            scripts = parse_script(m, shared_scripts)

            area, trainers = parse_map(m, scripts, trainer_ids, layout_ids)
            map_data[area] = trainers
            trainer_ids_debug = ", ".join([ str(t.num) for t in trainers ])
            log.debug(f"Area {m.name} (#{area}): {trainer_ids_debug}")
            log.debug(f"Leaving {m.name}")

    return map_data


def output_data_file(map_data, out):
    """Output a standalone Lua data file that returns the routeData table."""
    out.write("-- Generated by /Debug/parse-trainerdata.py\n")
    out.write("local routeData = {\n")
    for area, trainers in sorted(map_data.items()):
        if not len(trainers):
            continue

        out.write(f"\t[{area}] = {{\n")
        for trainer in sorted(trainers, key=lambda t: t.num):
            for x, y in trainer.get_tiles():
                out.write(f"\t\t{{ x = {x}, y = {y}, id = {trainer.num} }},\n")
        out.write(f"\t}},\n")
    out.write("}\n")
    out.write("\nreturn routeData\n")


def main():
    global log
    parser = ArgumentParser(__file__, description="Extract trainer map tile data from pokeemerald/pokefirered ROM source trees.")
    parser.add_argument("-v", action="store_true", dest="verbose", help="Enable verbose logging")
    parser.add_argument("-o", "--out", default=None, help="Output file path (default: stdout)")
    parser.add_argument("--frlg-path", default=None, help="Path to pokefirered code root")
    parser.add_argument("--ruby-path", default=None, help="Path to pokeruby code root")
    parser.add_argument("--emerald-path", default=None, help="Path to pokeemerald code root")
    args = parser.parse_args()

    if not args.frlg_path and not args.ruby_path and not args.emerald_path:
        parser.error("At least one of --frlg-path, --ruby-path, or --emerald-path is required")

    log_level = logging.DEBUG if args.verbose else logging.WARNING
    log = init_logging(log_level)

    import sys as _sys
    out = open(args.out, "w") if args.out else _sys.stdout

    all_data = {}
    if args.frlg_path:
        all_data.update(process_rom(args.frlg_path))
    if args.ruby_path:
        all_data.update(process_rom(args.ruby_path))
    if args.emerald_path:
        all_data.update(process_rom(args.emerald_path))

    output_data_file(all_data, out)

    if args.out:
        out.close()

    return 0

if __name__ == "__main__":
    sys.exit(main())
