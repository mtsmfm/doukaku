class Doukaku {
  private input: string;

  constructor(input: string) {
    this.input = input;
  }

  parse(input: string) {
    return this.input.match(/\w{2}/g);
  }

  solve() {
    let board = [
      new Map(),

    ]
    this.parse(this.input);
    return '';
  }
}

let solve = function(input) {
  let doukaku = new Doukaku(input);

  return doukaku.solve();
}

let test = function(input, expected) {
  let actual = solve(input);

  if (expected === actual) {
    console.log('passed');
  } else {
    console.log('failed');
    console.log(`expect : ${expected} but got ${actual}`);
  }
}

/*0*/ test( "1a2t3s2s", "11" );
