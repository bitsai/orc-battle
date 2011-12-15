# About the game

> In the Orc Battle game, you're a knight surrounded by 12 monsters, engaged in a fight to the death. With your superior wits and your repertoire of swordfighting maneuvers, you must carefully strategize in your battle with orcs, hydras, and other nasty enemies. One wrong move and you may be unable to kill them all before being worn down by their superior numbers.
> -- <cite>[Land of Lisp][1], p.172</cite>

# Playing the game

1. Clone repository

2. In the project directory, run "android update project -p ."

3. Follow these [instructions on how to build and deploy the application](http://per.bothner.com/blog/2010/AndroidHelloScheme/)

IMPORTANT: When building Kawa from source, please use [the latest development sources](http://www.gnu.org/s/kawa/Getting-Kawa.html#Getting-the-development-sources-using-SVN)

# Controls

"S", "D", "R" buttons: Select Stab, Double Swing, or Roundhouse attack.

Numeric button (4th from the left): Select monster to attack.

+/- buttons: Increment/decrement the selection on the numeric button.

# Player stats

Health: When the player's health reaches zero, the player dies.

Agility: Controls how many attacks the player can perform.

Strength: Controls the ferocity of the attacks.

# Player attacks

Stab: The most ferocious attack, can be delivered against a single foe.

Double Swing: Weaker attack, but allows two enemies to be attacked.

Roundhouse: Attack random foes multiple times.

# Monsters

## The Wicked Orc

> The orc is a simple foe. He can deliver a strong attack with his club, but otherwise he is pretty harmless. Every orc has a club with a unique attack level. Orcs are best ignored, unless there are orcs with an unusually powerful club attack that you want to cull from the herd at the beginning of a battle.
> -- <cite>[Land of Lisp][1], p.181</cite>

## The Malicious Hydra

> The hydra is a very nasty enemy. It will attack you with its many heads, which you'll need to chop off to defeat it. The hydra's special power is that it can grow a new head during each round of battle, which means you want to defeat it as early as possible.
> -- <cite>[Land of Lisp][1], p.183</cite>

## The Slimey Slime Mold

> The slime mold is a unique monster. When it attacks you, it will wrap itself around your legs and immobilize you, letting the other bad guys finish you off. It can also squirt goo in your face. You must think quickly in battle to decide if it's better to finish the slime off early in order to maintain your agility, or ignore it to focus on more vicious foes first. (Remember that by lowering your agility, the slime mold will decrease the number of attacks you can deliver in later rounds of battle.)
> -- <cite>[Land of Lisp][1], p.184</cite>

## The Cunning Brigand

> The brigand is the smartest of all your foes. He can use his whip or slingshot and will try to neutralize your best assets. His attacks are not powerful, but they are a consistent two points for every round.
> -- <cite>[Land of Lisp][1], p.185</cite>

[1]:http://landoflisp.com/
