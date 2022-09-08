# Goal Oriented Action Planner

What problem does GOAP actually solve? GOAP's intended use it to provide real-time control of autonomous character behavior in games, over traditional approaches such as FSM, BT or plain If structure. By intelligently linking goals and actions together by having a goal state, and actions having effects and preconditions that will be tested to build rich plans.

 - FSM, BT's and If structures all suffer from being hard to manage once you reach a certain level of complexity where you want to avoid repeating yourself.

 This GOAP implementation is based loosely on Jeff Orkin's work on Goal Oriented Action Planning
 - Jeff Orkin's website can be found here [https://alumni.media.mit.edu/](https://alumni.media.mit.edu/~jorkin/goap.html)


### Short low level explanation.
 1. **Goal**: A desired world state.
 2. **Plan**: List of actions.
 3. **Action**: Action the fulfill a precondition to resolve a goal.

 - GOAP planner will evaluate goals based on their current priority, priority ***can*** be static or calculated at runtime.
 - If a goal that is evaluated have a higher priority than the current goal, the planner will switch to a higher priority goal, and find the best plan to execute, a goal can have multiple plans to achieve a given goal.
 - Actions behave in a similar way as goals, actions however have cost of execution, lower cost means that a action has a higher priority to run. 
 - Every time the planner ticks it will evaluate if a plan-and-or-action have a lower cost and will contribute to fulfill the goal and switch between plans and actions.

Goals and Actions both share a similar design pattern with some key differences.
 - Goals 
    - Ticked **every** time we tick the GOAP module.
    - Have priority function/attribute, higher = better.
    - Have a function to specify if the goal can be ran, which is not implemented for actions. This could maybe be useful for actions but I have not seen a use for this at the current time.

 - Actions
    - **Only** ticked when they are active.
    - Have cost function/attribute instead of priority, lower = better.


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