# roact-floating-ui

This package is a port of [floating-ui](https://floating-ui.com/). It is for positioning <u>floating elements</u> and creating interactions for them.
You can create elements such as include tooltips, dropdowns, popovers, and more!

# Why

Floating UI solves quite a few problems:

- Collision from absolute position

  Absolute positioning elements can cause problems when an element gets too close to the edge of the viewport (i.e., from `Workspace.CurrentCamera`) or a similar clipping element such as a `ScrollingFrame`. When a collision occurs, we adjust the position to ensure that the floating element remains visible.

- Complex Interactivity

  Floating elements are often interactive. This can introduce further complexity when designing user interactions (e.g., through a Popover.).

# Install
