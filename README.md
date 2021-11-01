# word-game-ruiner

Takes the fun out of the word game.

## Word game?

A cooperative game wherein players create chains of words. Each word in the chain must have an edit distance of exactly 1 from the previous word, and words may not be repeated.

## Usage

First, create a next-words file from a wordlist. Ideally, the input wordlist will be the set of legal words for your game.

```
word-game-ruiner generate -w /usr/share/dict/words -o nexts.json
```

Find all legal next words from a given game state:

```
word-game-ruiner next -n nexts.json -g fun,fan,fin,fine
```

Find legal word with the greatest number of following words:

```
word-game-ruiner next --maximize -n nexts.json -g fun,fan,fin,fine
```

Find legal words, if any, that have no legal following words:

```
word-game-ruiner next --terminate -n nexts.json -g fun,fan,fin,fine
```
