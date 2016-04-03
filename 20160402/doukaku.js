var Doukaku = (function () {
    function Doukaku(input) {
        this.input = input;
    }
    Doukaku.prototype.parse = function (input) {
        return this.input.match(/\w{2}/g);
    };
    Doukaku.prototype.solve = function () {
        var board = [
            new Map(),
        ];
        this.parse(this.input);
        return '';
    };
    return Doukaku;
}());
var solve = function (input) {
    var doukaku = new Doukaku(input);
    return doukaku.solve();
};
var test = function (input, expected) {
    var actual = solve(input);
    if (expected === actual) {
        console.log('passed');
    }
    else {
        console.log('failed');
        console.log("expect : " + expected + " but got " + actual);
    }
};
test("1a2t3s2s", "11");
