# ArchiTotem (Emberveil Edition)
Shaman addon to keep track of totems timers, area of effect and simplify the totem management.

Based on https://github.com/Road-block/ArchiTotem, but with some heavy refactoring, code cleanup and QoL improvements focused on <a href="https://emberveil.org/">Emberveil WoW.</a>

# Features
<ul>
<li>All totems in a single bar.</li>
<li>Fixed totems tooltips and descriptions to match Emberveil WOW 1.12.1</li>
<li>Track totems cooldowns and timers.</li>
<li>Tracks out of range indicator per totems that apply an aura on the player.</li>
</ul>

# Screenshots
<b>Totem bar.</b><br> 
<img width="245" height="83" alt="bar" src="https://github.com/user-attachments/assets/faed932e-4f77-4db2-9a2a-da63947902f7" />

# Installation
<ul>
<li>Download the Latest Release</li>
<li>Unpack the zip file.</li>
<li>Rename the folder to ArchiTotem.</li>
<li>Copy the folder to \Interface\AddOns</li>
<li>Restart Emberveil Client</li>
</ul>

# Commands
You can use either /architotem or /at to run a command
<code>
/at set <earth/fire/water/air> #    Sets the totems shown of that element to #
/at direction <up/down> - Set the direction totems pop up.
/at order <element 1, element 2, element 3, element 4> - Sets the order of the totems, from left to right.
/at scale # - Sets the scale of ArchiTotem, default is 1.
/at showall - Toggles show all mode, displaying all totems on mouseover.
/at bottomcast - Toggles moving totems to the bottom line when cast
/at timers - Toggles showing timers
/at tooltip - Toggles showing tooltips
/at debug - Toggles debuging
</code>

Moving the bar:
<ul>
<li>Ctrl-RightClick and Drag any of the main buttons</li>
<li>Ordering totems of same element:</li>
<ul><li>Ctrl-LeftClick any of the buttons</li></ul>
</ul>

# Known Issues
<ul>
<li>There's no way to down-rank a totem launched by the addon.</li>
</ul>
