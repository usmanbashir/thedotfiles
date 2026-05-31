#!/usr/bin/env bash
# Tests for bin/unmd — the Markdown -> plain-text stripper used by tts/narrate.
#
# Pure bash, no framework. Each case feeds input to unmd and compares stdout to
# an expected string. Run: tests/unmd_test.sh   (exits non-zero on any failure)
#
# $(...) strips trailing newlines from the captured output, so expectations are
# compared without a trailing newline — inner blank lines are still significant.
set -u

DIR="$(cd "$(dirname "$0")/.." && pwd)"
UNMD="$DIR/bin/unmd"

pass=0
fail=0

# run_case NAME INPUT EXPECTED  — INPUT piped via stdin.
run_case() {
    local name=$1 input=$2 expected=$3 got
    got="$(printf '%s' "$input" | "$UNMD")"
    if [ "$got" = "$expected" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        printf 'FAIL: %s\n  input:    %q\n  expected: %q\n  got:      %q\n' \
            "$name" "$input" "$expected" "$got"
    fi
}

# run_args NAME EXPECTED ARG...  — input passed as arguments instead of stdin.
run_args() {
    local name=$1 expected=$2 got
    shift 2
    got="$("$UNMD" "$@")"
    if [ "$got" = "$expected" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        printf 'FAIL: %s\n  expected: %q\n  got:      %q\n' "$name" "$expected" "$got"
    fi
}

run_case "atx heading"            $'# Hello World'                 $'Hello World'
run_case "atx closing hashes"     $'## Title ##'                   $'Title'
run_case "hashtag word kept"      $'a #hashtag here'               $'a #hashtag here'
run_case "emphasis asterisks"     $'This is **bold**, *italic*, ~~gone~~.' \
                                  $'This is bold, italic, gone.'
run_case "bold-italic combo"      $'***wow***'                     $'wow'
run_case "underscore emphasis"    $'_italic_ word'                 $'italic word'
run_case "underscore identifier"  $'keep some_long_name intact'    $'keep some_long_name intact'
run_case "inline code"            $'Run `make test` now.'          $'Run make test now.'
run_case "fenced code dropped"    $'Before.\n```sh\nrm -rf /\n```\nAfter.' \
                                  $'Before.\nAfter.'
run_case "tilde fence dropped"    $'A\n~~~\ncode\n~~~\nB'          $'A\nB'
run_case "inline link"            $'See [the docs](https://example.com/x) please.' \
                                  $'See the docs please.'
run_case "image dropped"          $'Logo: ![alt](logo.png) end.'   $'Logo: end.'
run_case "reference link + def"   $'Read [the guide][g] today.\n\n[g]: https://example.com' \
                                  $'Read the guide today.'
run_case "autolink dropped"       $'Visit <https://example.com> now.' \
                                  $'Visit now.'
run_case "blockquote"             $'> Quoted line'                 $'Quoted line'
run_case "nested blockquote"      $'> > deep'                      $'deep'
run_case "unordered list"         $'- one\n* two\n+ three'         $'one\ntwo\nthree'
run_case "ordered list"           $'1. first\n2. second'           $'first\nsecond'
run_case "horizontal rule"        $'Above\n\n***\n\nBelow'         $'Above\n\nBelow'
run_case "setext heading"         $'Title\n=====\n\nBody'          $'Title\n\nBody'
run_case "html tags stripped"     $'A <strong>bold</strong> and <br/> tag.' \
                                  $'A bold and tag.'
run_case "plain text unchanged"   $'Just a normal sentence.'       $'Just a normal sentence.'
run_case "collapse blank lines"   $'Para one.\n\n\n\nPara two.'    $'Para one.\n\nPara two.'
run_case "only markup -> empty"   $'***'                           $''
run_args "args form"              $'Hi there'                      '# Hi there'

# HTML entities -> their characters
run_case "entity amp/lt/gt"       $'Tom &amp; Jerry, 5 &lt; 10 &gt; 3' $'Tom & Jerry, 5 < 10 > 3'
run_case "entity quot/apos/num"   $'&quot;hi&quot; it&#39;s'        $'"hi" it\'s'
run_case "entity nbsp -> space"   $'a&nbsp;&nbsp;b'                 $'a b'
run_case "entity em dash"         $'a &mdash; b'                    $'a — b'
run_case "entity numeric hellip"  $'wait&#8230;'                    $'wait…'
run_case "entity hex"             $'&#x41;&#x42;'                   $'AB'
run_case "entity unknown kept"    $'A &foobar; B'                   $'A &foobar; B'
run_case "entity double amp"      $'&amp;lt;'                       $'&lt;'
run_case "utf8 passthrough"       $'café résumé —'                  $'café résumé —'

# Bare URLs -> host
run_case "bare url with path"     $'See https://example.com/foo/bar for details.' \
                                  $'See example.com for details.'
run_case "bare url trailing dot"  $'Go to https://example.com.'    $'Go to example.com.'
run_case "bare url in parens"     $'(see https://example.com/p) ok' $'(see example.com) ok'
run_case "bare url no path"       $'Visit https://github.com now'   $'Visit github.com now'

# Task-list checkboxes
run_case "task list checkboxes"   $'- [ ] todo\n- [x] done\n- [X] also' \
                                  $'todo\ndone\nalso'

echo "-----"
echo "passed: $pass  failed: $fail"
[ "$fail" -eq 0 ]
