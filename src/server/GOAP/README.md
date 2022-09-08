# Goal Oriented Action Planner

What exactly does GOAP solve? GOAP's intended use it to provide NPC's a much improved AI, in a much simpler way than traditional Finite State Machine, Behavior Tree, Relationship Graphs or even nested if statement structure, by intelligently linking goals and actions together, I think anyone who have done this know exactly how messy this gets.

There are two approaches to GOAP that is 'commonly' used.
    - Evaluate all goals and relevant actions on each frame, where each goal and action then holds the piece of code that is run. This is what this library focuses on.
    - Using GOAP purely as a complex Finite State Machine, tho not inteded use by this library it could most certainly be used this way.



## Getting Started
To build the place from scratch, use:

```bash
rojo build -o "Goal Oriented Action Planner.rbxlx"
```

Next, open `Goal Oriented Action Planner.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).