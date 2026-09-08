# Procedural Animals

A collection of small, asset-free animal animations implemented in different
languages and creative-coding frameworks. Each top-level directory identifies
the language, and each animal is kept in its own source file.

## Lua / LÖVE2D

The Lua sketch includes a person, snake, dog, and spider built from interchangeable visual
models and movement modules. The included movement types are biped, quadruped,
octopod, and slither.

It has two control modes:

- **Mouse mode** — the snake follows the pointer.
- **WASD mode** — move with `W`, `A`, `S`, and `D`.

Press `Tab`, `M`, `1`, or `2` to switch modes. Press `H` for the person, `N` for
the snake, `Q` for the dog, `8` for the spider, `V` to cycle
normal/zombie/skeleton variants, `R` to reset, and `Esc` to quit.

### Demo videos

| Character | Movement | Video |
| --- | --- | --- |
| Person / relic mage | Biped | [Watch person demo](Videos/human.webm) |
| Snake | Slither | [Watch snake demo](Videos/snake.webm) |
| Dog | Quadruped | [Watch dog demo](Videos/dog.webm) |
| Spider | Octopod | [Watch spider demo](Videos/spider.webm) |

### Character art direction

The person is a **relic mage** from a world where technology is so advanced
that it looks like magic. Machinery is concealed in woven materials and jewelry:
a gold-edged indigo mantle carries luminous conduits, a chest jewel powers
geometric light constructs, and a suspended halo acts as a field interface.
Wrist sigils and an orbiting familiar suggest spellwork without exposed screens,
wires, or gears. The mantle sways with the gait; the halo and familiar drift
even at rest. Normal, zombie, and skeleton variants use mint, acidic green,
and lilac energy respectively, sharing the same visual language.

### Movement framework

An actor is composed from two independent parts:

```lua
local actor = Actor.new(x, y, Biped.new({ maxSpeed = 180 }), RobotModel)
```

- A movement module owns velocity, facing, animation timing, and pose data.
- A model draws that pose and declares the movement type it supports.
- Model variants change palette and anatomy details without duplicating movement.
- `Actor` exposes the common `updateToward`, `updateDirected`, and `draw` API.

To add another biped, create a model with `movementKind = "biped"` and a
`draw(actor, pose)` function, then compose it with `Biped.new()`. The same model
contract applies to `quadruped` and `slither`. Optional settings such as speed,
acceleration, turn rate, segment count, and margins are passed to a movement
constructor, keeping them out of visual model code.

### Run it

Install [LÖVE 11.x](https://love2d.org/), then run:

```sh
love lua
```

## Layout

```text
ProceduralAnimations/
├── lua/
│   ├── actor.lua              # Composition and shared actor API
│   ├── movements/
│   │   ├── ground.lua         # Shared directed ground movement
│   │   ├── biped.lua          # Two-leg gait and pose
│   │   ├── quadruped.lua      # Four-leg trot gait and pose
│   │   ├── octopod.lua        # Alternating eight-leg gait and pose
│   │   └── slither.lua        # Turning and segment-chain simulation
│   ├── models/
│   │   ├── person.lua         # Biped visuals
│   │   ├── dog.lua            # Quadruped visuals
│   │   ├── spider.lua         # Octopod visuals
│   │   └── snake.lua          # Slither visuals
│   ├── actors/
│   │   ├── person.lua         # Person composition factory
│   │   ├── dog.lua            # Dog composition factory
│   │   ├── spider.lua         # Spider composition factory
│   │   └── snake.lua          # Snake composition factory
│   ├── conf.lua               # LÖVE window configuration
│   └── main.lua               # Sketch lifecycle, registry, and UI
└── README.md
```

Future language folders can follow the same idea: one runnable entry point and
one source file per animal.
