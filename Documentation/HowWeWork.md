
# How we work

This project is being developed by Zuhlke developers, so the rest of this document assumes you are an internal contributor. If you’re an external contributor and would like to help, we welcome your suggestions. Please send us a pull request.  

## Context

This project is lead by the engineering team and has limited delivery pressure. At the same time, we’re also conscious of engineers’ desire for perfection.

Our way of working takes both of these into account: It’s designed to minimise compromises made when shipping a product. At the same time, we don’t want to end up with an elegant code that doesn’t actually deliver any value.

There will of course always be exceptions to what is described here, but this is a good baseline to help us get started. Please feel free to express your opinion and help improve our process. 

## Backlog

We have a Trello board to manage our backlog. We will refine the cards incrementally as we know more about them or want to work on them. There are two noteworthy features to our backlog:

* Any bugs discovered immediately moves to the top of the backlog. This is a luxury we have given we don’t have much external commitment. If the quality of the product drops it’s on us.
* Before moving anything to “Done”, we will review its shortcomings and add them to the “Tech Debts” list. We can _always_ find something to improve – tests, performance, the bikeshed’s colour. When we’re “happy enough” about something, we can move it over, but we should capture our thoughts about how we can improve it. This way we will remember them. It also helps newjoiners distinguish our intentional coding patterns from tech debt.

## Branch management

Pretty much the only rule is that the `master` branch is our stable branch.

Contributors are welcome to commit directly on `master`, but they can also make pull requests if they want to discuss their changes before it’s merged in.

We highly discourage long-living branches – unless they’re experimental and we don’t expect to merge them in.

## Cross-cutting concerns

Any feature added must consider the following:

* Security
* Privacy
* Accessibility (and inclusiveness)

## Compatibility

Given that all our customers are internal, we will have aggressive minimum-OS and device requirements (usually the latest version only).

On the other hand, we will keep a reasonable backwards compatibility with older versions of our own app. This is both to ensure a good experience for our customers, and also as an exercise for us so we don’t just forget about it.
