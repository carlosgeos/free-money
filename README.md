# Free Money

Optimal matched betting using freebets.

**UPDATE:** On September 2024 Belgium tightened its ban on gambling advertising, which included sign up bonuses and freebets. However Belgian bookies are used in this example WLOG, since any bookie offering freebets is valid. The freebet amounts were real numbers I gathered back in 2019.

## Usage

Install `glpk` and:

```sh
$ make
```

## Features

- Up to `N` different bookies can be chosen. Each offering a freebet of up to `f`.
- `f` can be zero: a bookie that isn't offering freebets could have great odds and still be useful (betting with cash).
- Qualifying bets (cash) and freebets can have a minimum odds constraint.

## Not implemented

- Sign up bonuses (with rollovers).
- Other convoluted incentive programs that bookies sometimes come up with.
